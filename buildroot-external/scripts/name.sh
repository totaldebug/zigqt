#!/bin/bash

function zigqtos_image_name() {
    echo "${BINARIES_DIR}/${HASSOS_ID}_${BOARD_ID}-$(zigqtos_version).${1}"
}

function zigqtos_rauc_compatible() {
    echo "${HASSOS_ID}-${BOARD_ID}"
}

function zigqtos_version() {
    if [ -z "${VERSION_DEV}" ]; then
        echo "${VERSION_MAJOR}.${VERSION_BUILD}"
    else
        echo "${VERSION_MAJOR}.${VERSION_BUILD}.${VERSION_DEV}"
    fi
}
