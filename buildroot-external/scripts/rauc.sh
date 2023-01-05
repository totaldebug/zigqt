#!/bin/bash
set -e


function write_rauc_config() {
    RAUC_COMPATIBLE="$(zigqt_rauc_compatible)"

    sed -i "/compatible/s/=.*\$/=${RAUC_COMPATIBLE}/" ${TARGET_DIR}/etc/rauc/system.conf
}

function install_rauc_version_file(){
    # Create rauc version file
    echo "${RAUC_VERSION}" > ${TARGET_DIR}/etc/rauc/version
}

function install_rauc_certs() {
    if [ "${DEPLOYMENT}" == "production" ]; then
        cp "${BR2_EXTERNAL_ZIGQTOS_PATH}/ota/rel-ca.pem" "${TARGET_DIR}/etc/rauc/keyring.pem"
    else
        cp "${BR2_EXTERNAL_ZIGQTOS_PATH}/ota/dev-ca.pem" "${TARGET_DIR}/etc/rauc/keyring.pem"
    fi
}
