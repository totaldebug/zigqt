THIS IS A WORK IN PROGRESS AND NOT YET TESTED

# Deploy a Zigbee2mqtt hub using Alpine Linux on a headless system

This repo provides an overaly file to initially boot the headless system (leveraging Alpine distro's initramfs feature):

* it enables a basic ssh server to log-into from another Computer, in order to finalize system set-up.
* it installs avahi for mDNS discovery when using DHCP
* it installs zigbee2mqtt (not implemented yet)


# Install procedure:

Please follow my article here for usage instructions. (still in writing)

Tools provided here can be used on any plaform for any install modes (diskless, data disk, system disk).

1. Optional: Update files in `samples` folder.
2. Move updated files to `ovl` folder.
3. run `./make.sh`
4. copy the generated tarball `headless.apkovl.tar.gz` to the root of the boot media and boot the system.

Note: these files are linux text files: Windows/macOS users need to use text editors supporting linux text line-ending (such as notepad++).

Main execution steps are logged in `/var/log/messages`.

# How to customize further ?
This repository may be forked/cloned/downloaded.
Main script file is `headless.start`.
Execute `./make.sh` to rebuild `headless.apkovl.tar.gz`.

Side note: one nicety for bootstrapping PiZero devices, or similar which can support USB ethernet gadget networking.
Just add `dtoverlay=dwc2` in `usercfg.txt` (or `config.txt`), and plug-in USB to Computer port.
With Computer set-up to share networking with USB interface, device will appear at `10.42.0.2` onto Computer's subnet to log into !...
