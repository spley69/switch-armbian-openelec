#!/bin/bash

# Global config
declare -A config
config=(
    ["nodm_configLocation"]="/etc/default/nodm" #NODM_ENABLED=false|true
    ["armbian_maliDriverLocation"]="/lib/modules/$(uname -r)/kernel/drivers/gpu/mali/mali/mali_armbian.ko"
    ["armbian_umpDriverLocation"]="/lib/modules/$(uname -r)/kernel/drivers/gpu/mali/ump/ump_armbian.ko"
    ["kodi_maliDriverLocation"]="/lib/modules/$(uname -r)/kernel/drivers/gpu/mali/mali/mali_openelec.ko"
    ["kodi_umpDriverLocation"]="/lib/modules/$(uname -r)/kernel/drivers/gpu/mali/ump/ump_armbian.ko"
    ["system_maliDriverLocation"]="/lib/modules/$(uname -r)/kernel/drivers/gpu/mali/mali/mali.ko"
    ["system_umpDriverLocation"]="/lib/modules/$(uname -r)/kernel/drivers/gpu/mali/ump/ump.ko"
    ["kodi_profileConfigLocation"]="/storage/.kodi/userdata/profiles.xml"
    )

Main() {
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    ParseOptions "$@"

#TODO: check config locations of files

    if [ ! ${system} ]; then
        echo "No parameters\n"
        DisplayHelp
        exit -1
    fi

    # switch armbian/kodi
    case ${system} in
        1|armbian) # Armbian
            SetArmbian
            ;;
        2|kodi) # Kodi - kodi
            SetKodi ${kodiProfile}
            ;;
        *) # help
            echo "Error: option \"-system\" Wrong value: \"${system}\""
            DisplayHelp
            ;;
    esac

    }

ParseOptions() {
    while getopts 's:k:' option ; do
    case ${option} in
        s)
            # System to set armbian/openelec
            export system=${OPTARG}
            ;;
        k)
            # Kodi profile id to set
            export kodiProfile=${OPTARG}
            ;;
    esac
    done
}

SetNondm() {
    # Set config for nondm start
    local enable=$1

    if [ ${enable} == 0 ]; then
        echo "nondm disable"
    else
        echo "nondm enable"
    fi
}

SetArmbian() {
    echo "setArmbian";

    LinkDrivers ${config[armbian_maliDriverLocation]} ${config[armbian_umpDriverLocation]} || exit $?

    (SetNondm 1) || exit $?
    }

SetKodi() {
    echo "setKodi";
    local kodiProfile=$1

    LinkDrivers ${config[kodi_maliDriverLocation]} ${config[kodi_umpDriverLocation]} || exit $?

    if [ ${kodiProfile} ]; then
        (SetKodiProfile ${kodiProfile}) || exit $?
    fi

    (SetNondm 0) || exit $?
    }

SetKodiProfile() {
    local kodiProfile=$1
    echo "Set kodi profile: ${kodiProfile} in file ${config["kodi_profileConfigLocation"]}"

    xmlstarlet ed -u "/profiles/lastloaded" -v 0 ${config["kodi_profileConfigLocation"]} || exit $?
}

LinkDrivers(){
    local maliDriver=$1
    local umpDriver=$2

    echo "driver link:"
    echo "mali: ${maliDriver} -> ${config[system_maliDriverLocation]}"
    echo "ump: ${umpDriver} -> ${config[system_umpDriverLocation]}"

    rm ${config[system_maliDriverLocation]} || exit $?
    ln -s ${maliDriver} ${config[system_maliDriverLocation]} || exit $?

    rm ${config[system_umpDriverLocation]} || exit $?
    ln -s ${umpDriver} ${config[system_umpDriverLocation]} || exit $?
}

DisplayHelp() {
    echo ""HELP
}
Main "$@"