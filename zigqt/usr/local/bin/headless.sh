#!/bin/sh

VERSION="1.0"

# Redirect stdout and errors to console as rc.local does not log anything
exec 1>/dev/console 2>&1

logger -st ${0##*/} "Zigqt v$VERSION by totaldebug"
echo "Zigqt v$VERSION by totaldebug - https://github.com/totaldebug/zigqt" >> /etc/motd

ovlpath=$( find /media -type d -path '*/.*' -prune -o -type f -name *.apkovl.tar.gz -exec dirname {} \; | head -1 )

## Setup wifi
if [ -f "${ovlpath}/wpa_supplicant.conf" ]; then
	logger -st ${0##*/} "Wifi setup found !"
	apk add wpa_supplicant
	cp "${ovlpath}/wpa_supplicant.conf" /etc/wpa_supplicant/wpa_supplicant.conf
else
	logger -st ${0##*/} "Wifi setup not found skipping!"
fi

if ! cp "${ovlpath}/interfaces" /etc/network/interfaces; then
	# set default interfaces if not specified by interface file on boot storage
	logger -st ${0##*/} "No interfaces file supplied, building default interfaces..."
	for dev in $(ls /sys/class/net)
	do
		case ${dev%%[0-9]*} in
			lo)
					cat <<-EOF >> /etc/network/interfaces
					auto $dev
					iface $dev inet loopback
					EOF
					;;
			eth)
					cat <<-EOF >> /etc/network/interfaces
					auto $dev
					iface $dev inet static
					    address 192.168.1.250
					    netmask 255.255.255.0
					    gateway 192.168.1.1
					EOF
					;;
			wlan)
					[ -f /etc/wpa_supplicant/wpa_supplicant.conf ] && cat <<-EOF >> /etc/network/interfaces
					auto $dev
					iface $dev inet dhcp
					EOF
					;;
			usb)
					cat <<-EOF >> /etc/network/interfaces
					auto $dev
					iface $dev inet static
					    address 10.42.0.2/24
					    gateway 10.42.0.1
					EOF
		esac
	done
fi


echo "Using following network interfaces:"
cat /etc/network/interfaces


echo "zigqt" > /etc/hostname
hostname -F /etc/hostname

# Start Network Services
grep -q "wlan" /etc/network/interfaces && [ -f /etc/wpa_supplicant/wpa_supplicant.conf ] && rc-service wpa_supplicant start
rc-service networking start

# mount 2nd drive and overlay for var
logger -st ${0##*/} "Making directories and mounting persistent drives."
mkdir -p /etc/zigbee2mqtt

echo "/dev/mmcblk0p2 /media/mmcblk0p2 ext4 rw,relatime 0 0" >> /etc/fstab
mount -a
mkdir -p /media/mmcblk0p2/var
mkdir -p /media/mmcblk0p2/etc/zigbee2mqtt
mkdir -p /media/mmcblk0p2/workdir
echo "overlay /var overlay lowerdir=/var,upperdir=/media/mmcblk0p2/var,workdir=/media/mmcblk0p2/workdir 0 0" >> /etc/fstab
echo "overlay /etc/zigbee2mqtt overlay lowerdir=/etc/zigbee2mqtt,upperdir=/media/mmcblk0p2/etc/zigbee2mqtt,workdir=/media/mmcblk0p2/workdir 0 0" >> /etc/fstab
mount -a

logger -st ${0##*/} "Drives mounted."

if [ -f "${ovlpath}/secret.yaml" ] && [ ! -f "/etc/zigbee2mqtt/secret.yaml" ]; then
	logger -st ${0##*/} "No secret file, copying custom zigbee2mqtt secret file."
	cp "${ovlpath}/secret.yaml" /etc/zigbee2mqtt/secret.yaml
fi

if [ -f "${ovlpath}/configuration.yaml" ] && [ ! -f "/etc/zigbee2mqtt/configuration.yaml" ]; then
	logger -st ${0##*/} "No configuration file, copying custom zigbee2mqtt config file."
	cp "${ovlpath}/configuration.yaml" /etc/zigbee2mqtt/configuration.yaml
fi


# Add default required packages from /etc/apk/world
logger -st ${0##*/} "Installing required packages."
apk add
apk update && apk upgrade


# Add log dir for Zigbee2MQTT if logging to file
install -d -m750 -o zigbee2mqtt -g zigbee2mqtt /var/log/zigbee2mqtt
chown -R zigbee2mqtt:zigbee2mqtt /var/lib/zigbee2mqtt

# Start serivces
logger -st ${0##*/} "Starting services."
rc-service zigbee2mqtt restart
rc-service dbus restart
rc-service avahi-daemon restart

# Setup SSH
/sbin/setup-sshd -c openssh
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
cat <<EOF >> /etc/ssh/sshd_config
PermitEmptyPasswords yes
PermitRootLogin yes
EOF
rc-service sshd restart
mv /etc/ssh/sshd_config.orig /etc/ssh/sshd_config

if [ -f "${ovlpath}/unattended.sh" ]; then
	install -m755 "${ovlpath}/unattended.sh" /tmp/unattended.sh
	/tmp/unattended.sh >/dev/console 2>&1 &
	logger -st ${0##*/} "/tmp/unattended.sh script launched in the background with PID \$!"
fi

logger -st ${0##*/} "!! Done !!"
