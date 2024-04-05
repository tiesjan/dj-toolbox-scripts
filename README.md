# DJ Toolbox Scripts

Management scripts for bootstrapping and deploying a Raspberry Pi to create a
headless toolbox for DJs. It can be interacted with using buttons connected to
GPIO pins.

### Features
- Recording mixes to FLAC files
- SFTP access to recorded mixes
- Graceful shutdown of Raspberry Pi

### Bootstrapping
Bootstrapping is done by running the `bootstrap-rpi.bash` script against the
root of the Raspberry Pi boot filesystem, with the SD card mounted on your
computer. It will guide you through these steps:

1. Create a user with the provided password. The username is taken from the
   user on the computer you run the script on. This will ease logging in over
   SSH later on.
2. Enable the SSH server on the Raspberry Pi.

### Deploying
Deploying is done using Ansible playbooks. Configuration can be changed in the
`vars.yml` file. The playbook can be issued using the following command:

```sh
$ ansible-playbook -i raspberrypi.local, -k deploy.yml
```

This assumes your computer supports multicast DNS (mDNS) and the Raspberry Pi
can be reached on its default hostname `raspberrypi.local`. See the official
documentation on [remote access](rpi-remote-access-docs) for more info. Please
note the comma behind the hostname, which ensures the inventory is treated as a
hostname.

The `-k` option will prompt you for the password set during bootstrapping.

[rpi-remote-access-docs]: https://www.raspberrypi.com/documentation/computers/remote-access.html#resolving-raspberrypi-local-with-mdns

### SSH access
Accessing the Raspberry Pi over your network is as simple as running:

```sh
$ ssh raspberrypi.local
```

This again assumes your computer supports multicast DNS and the Raspberry Pi
can be reached on its default hostname.

### SFTP access
Recordings can be accessed by the created user over SFTP with port 2222.
