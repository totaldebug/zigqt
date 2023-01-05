#!/bin/bash
# shellcheck disable=SC1090,SC1091
set -e

SCRIPT_DIR=${BR2_EXTERNAL_ZIGQTOS_PATH}/scripts
BOARD_DIR=${2}

. "${BR2_EXTERNAL_ZIGQTOS_PATH}/meta"
. "${BOARD_DIR}/meta"

. "${SCRIPT_DIR}/rootfs-layer.sh"
. "${SCRIPT_DIR}/name.sh"
. "${SCRIPT_DIR}/rauc.sh"


# tasks
fix_rootfs

# Write os-release
# shellcheck disable=SC2153
(
    echo "NAME=\"${ZIGQTOS_NAME}\""
    echo "VERSION=\"$(zigqtos_version) (${BOARD_NAME})\""
    echo "ID=${ZIGQTOS_ID}"
    echo "VERSION_ID=$(zigqtos_version)"
    echo "PRETTY_NAME=\"${ZIGQTOS_NAME} $(zigqtos_version)\""
    echo "CPE_NAME=cpe:2.3:o:zigqt:${ZIGQTOS_ID}:$(zigqtos_version):*:${DEPLOYMENT}:*:*:*:${BOARD_ID}:*"
    echo "HOME_URL=https://totaldebug.uk/"
    echo "VARIANT=\"${ZIGQTOS_NAME} ${BOARD_NAME}\""
    echo "VARIANT_ID=${BOARD_ID}"
) > "${TARGET_DIR}/usr/lib/os-release"

# Write machine-info
(
    echo "CHASSIS=${CHASSIS}"
    echo "DEPLOYMENT=${DEPLOYMENT}"
) > "${TARGET_DIR}/etc/machine-info"

# Pass VERSION as an environment variable (eg: export from a top-level Makefile)
# If VERSION is unset, fallback to the Buildroot version
RAUC_VERSION=${VERSION:-${BR2_VERSION_FULL}}

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Mount persistent data partitions
if [ -e ${TARGET_DIR}/etc/fstab ]; then
	# For configuration data
	# WARNING: data=journal is safest, but potentially slow!
	grep -qE 'LABEL=Data' ${TARGET_DIR}/etc/fstab || \
	echo "LABEL=Data /data ext4 defaults,data=journal,noatime 0 0" >> ${TARGET_DIR}/etc/fstab

	# For bulk data (eg: firmware updates)
	grep -qE 'LABEL=Upload' ${TARGET_DIR}/etc/fstab || \
	echo "LABEL=Upload /upload ext4 defaults,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
fi

# Copy custom cmdline.txt file
install -D -m 0644 ${BR2_EXTERNAL_BR2RAUC_PATH}/board/raspberrypi/cmdline.txt ${BINARIES_DIR}/custom/cmdline.txt


# Setup RAUC
write_rauc_config
install_rauc_version_file
install_rauc_certs
#install_bootloader_config

# Customize login prompt with login hints
cat <<- EOF >> ${TARGET_DIR}/etc/issue
	Default username:password is [zigqt:<empty>]
	Root login disabled, use sudo su -
	With great power comes great responsibility!
	eth0: \4{eth0}
EOF


# Fix overlay presets
"${HOST_DIR}/bin/systemctl" --root="${TARGET_DIR}" preset-all

