# DJ Toolbox Scripts

Management scripts for bootstrapping and deploying a Raspberry Pi to create a
headless toolbox for DJs. It can be interacted with using buttons connected to
GPIO pins.

### Features
- Recording mixes to FLAC files
- SFTP access to recorded mixes
- Graceful shutdown of Raspberry Pi
- Networking using a VLAN

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

```
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

```
$ ssh raspberrypi.local
```

This again assumes your computer supports multicast DNS and the Raspberry Pi
can be reached on its default hostname.

See also the Networking section below.

### SFTP access
Recordings can be accessed by the created user over SFTP with port 2222.

### Networking
A VLAN interface is configured to allow the DJ toolbox and other DJ gear to be
isolated from other VLANs. The DJ toolbox has a static IP address on the VLAN
interface and runs a DHCP server to provide IP addresses to other devices.

Assuming the VLAN does not have access to the Internet, APT is configured to
use a SOCKS proxy over the SSH connection to install and upgrade packages. This
requires the SSH client to have access to the Internet and connect with a
reverse SSH tunnel.

#### Configuring VLANs in Linux
1. Install `vlan` package

2. Define the following network interface for each VLAN:
   ```
   iface vlan<id> inet dhcp
     vlan-raw-device <ethernet_interface>
   ```
   Where `<ethernet_interface>` is the physical ethernet interface to configure
   VLAN with ID `<id>` for.

3. Bring VLAN interface up:
   ```
   # ifup vlan<id>
   ```
   Where `<id>` is the VLAN ID.

#### Configuring VLANs in Windows
1. Enable Windows features:
   - Hyper-V Services
   - Hyper-V Module for Windows Powershell

2. Create new VM Switch:
   ```PowerShell
   > New-VMSwitch -name VLAN-VMSwitch -NetAdapterName <ethernet_interface> -AllowManagementOS $true
   ```
   Where `<ethernet_interface>` is the physical ethernet interface to configure
   VLANs for.

3. Rename automatically created VM network adapter for untagged traffic:
   ```PowerShell
   > Rename-VMNetworkAdapter -ManagementOS -Name NoVLAN -NewName UntaggedVLAN
   ```

4. Add VM network adapters for tagged traffic:
   ```PowerShell
   > Add-VMNetworkAdapter -ManagementOS -SwitchName Vlan-VMSwitch -Name VLAN<id> -Passthru | Set-VMNetworkAdapterVlan -Access -VlanId <id>
   ```
   Where `<id>` is the VLAN ID.

VM network adapters can be retrieved using `Get-NetAdapter` and removed using
`Remove-VMNetworkAdapter`. VM switches can be retrieved using `Get-VMSwitch`
and removed using `Remove-VMSwitch`.
