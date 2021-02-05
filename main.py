import digitalocean
import inquirer
import json
import os
import requests
import subprocess
import sys
import time

STATUS_COMPLETE = "completed"
SIZE_1G = "s-1vcpu-1gb"
NEW_SSH_KEY = "NEW_SSH_KEY"

def _err(msg):
    print("[-] {}".format(msg))
    os._exit(1)


class DO(object):
    def __init__(self, token):
        self.token = token

    def _get(self, uri):
        url = "https://api.digitalocean.com/v2/{}".format(uri)
        r = requests.get(url, headers=dict(Authorization="Bearer {}".format(self.token)))
        if r.text == "":
            _err("Can not fetch {}".format(uri))
        return json.loads(r.text)

    def get_images(self):
        uri = "images?type=distribution"
        return self._get(uri)['images']

    def get_regions(self):
        uri = "regions"
        return self._get(uri)['regions']


class Creator(DO):
    def __init__(self, token):
        super().__init__(token)
        self.regions = []
        self.img = None
        self.get_metadata()
    
    def get_metadata(self):
        print("[+] Fetching regions")
        regions = [r['slug'] for r in self.get_regions() if r['available'] and SIZE_1G in r['sizes']]
        print("[+] Fetching images")
        self.img = [i for i in self.get_images() if i['distribution'] == 'Debian'][0]
        self.regions = [r for r in self.img['regions'] if r in regions]
        print("[+] Fetching SSH pub keys")
        self.keys = digitalocean.Manager(token=self.token).get_all_sshkeys()

    def add_sshkey(self, name, fp):
        print("[+] Adding SSH key to your DO account")
        user_ssh_key = open(os.path.expanduser(fp), 'r').read()
        key = digitalocean.SSHKey(token=self.token,
                     name=name,
                     public_key=user_ssh_key)
        key.create()
        return key

    def create(self, name, region, ssh_key):
        print("[+] Creating droplet")
        droplet = digitalocean.Droplet(
            token=self.token,
            name=name,
            region=region,
            image=self.img['slug'],
            size_slug=SIZE_1G,
            ssh_keys=[ssh_key],
            backups=False)
        droplet.create()
        return droplet

    def install_wg(self, ipv4):
        print("[+] Installing WireGuard\n")
        ssh = subprocess.Popen("scp ./user-data.sh root@{}:/tmp".format(ipv4), shell=True)
        out, err = ssh.communicate()
        if err:
            _err(err)
        ssh = subprocess.Popen("ssh root@{} -- /tmp/user-data.sh &".format(ipv4), shell=True)
        out, err = ssh.communicate()
        if err:
            _err(err)
        print(out)


def main():
    print("""
__        ______ _       ____   ___  
\ \      / / ___(_)_ __ |  _ \ / _ \ 
 \ \ /\ / / |  _| | '_ \| | | | | | |
  \ V  V /| |_| | | | | | |_| | |_| |
   \_/\_/  \____|_|_| |_|____/ \___/ 

                            by @novitoll                                     

   Spawns a 1GB droplet with Debian distr in DigitalOcean and installs WireGuard VPN there.

    """)
    questions = [
        inquirer.Text('token',
                        message="Paste a R/W token for DO API",
                    ),
    ]
    answers = inquirer.prompt(questions)
    creator = Creator(answers['token'])

    questions = [
        inquirer.List('region',
                    message="What region do you want to spin a droplet for VPN?",
                    choices=creator.regions,
                ),
        inquirer.Text('name',
                    message="Give a name for your droplet",
                ),
        inquirer.List('ssh_key',
                    message="Choose SSH key for root@ user in your droplet",
                    choices=creator.keys + [NEW_SSH_KEY],
                ),
    ]
    answers = inquirer.prompt(questions)
    name = answers['name']
    region = answers['region']
    ssh_key = answers['ssh_key']

    if ssh_key == NEW_SSH_KEY:
        questions = [
            inquirer.Path('ssh_key',
                        message="Enter a local filepath to your public SSH key for root@ user of droplet",
                        path_type=inquirer.Path.FILE,
                    ),
        ]
        answers = inquirer.prompt(questions)
        ssh_key = creator.add_sshkey(name, answers['ssh_key'])

    droplet = creator.create(name, region, ssh_key)
    ipv4 = None

    while True:        
        load = droplet.load()
        ipv4 = load.ip_address
        if not ipv4:
            print("[!] Waiting for droplet gets IPv4..")
            time.sleep(10)
            continue
        print("[+] IPv4 is {}".format(ipv4))
        break

    print("[!] Waiting for 30 secs to let the droplet deploy")
    time.sleep(30)
    creator.install_wg(ipv4)

    print("[!] STDOUT from user-data.sh\n")

if __name__ == "__main__":
    main()
