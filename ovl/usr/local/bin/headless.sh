#!/bin/sh

## Setup wifi
if [ -f "/etc/wpa_supplicant/wpa_supplicant.conf" ]; then
	logger -st ${0##*/} "Wifi setup found !"
	apk add wpa_supplicant
	rc-service wpa_supplicant start
else
	logger -st ${0##*/} "Wifi setup not found skipping!"
fi

if ! [ -f "/etc/network/interfaces" ]; then
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
					iface $dev inet dhcp
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

					cat <<-EOF > /etc/resolv.conf
					nameserver 1.1.1.1
					nameserver 1.0.0.1
					EOF
					;;
		esac
	done
fi

if [ -f "/etc/avahi/avahi-daemon.conf" ]; then
	logger -st ${0##*/} "mDNS setup found !"
	apk add avahi-daemon
	rc-service dbus start
    rc-service avahi-daemon start
else
	logger -st ${0##*/} "Wifi setup not found skipping!"
fi

echo "Using following network interfaces:"
cat /etc/network/interfaces


echo "z2mqtt-hub" > /etc/hostname
hostname -F /etc/hostname
rc-service networking start
rm /var/run/ifstate

# Setup SSH
apk add openssh

/sbin/setup-sshd -c openssh
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
cat <<EOF >> /etc/ssh/sshd_config
PermitEmptyPasswords yes
PermitRootLogin yes
EOF
service sshd restart
mv /etc/ssh/sshd_config.orig /etc/ssh/sshd_config

# Simulate a daemon
sleep infinity
