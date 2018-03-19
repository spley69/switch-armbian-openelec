#!/bin/bash

# Global config
declare -A config
config=(
    ["nodm_configLocation"]="/xxx/xx/sas"
    ["armbian_maliDriverLocation"]="/lib/modules/$(uname -r)/driver/gpu/mali/mali_armbian.ko"
    ["armbian_umpDriverLocation"]="ump"
    ["kodi_maliDriverLocation"]="mali"
    ["kodi_umpDriverLocation"]="ump"
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

    (SetResolution ${videoMode} ${fbMode}) || exit $?
    }

ParseOptions() {
    while getopts 's:k:v:f:' option ; do
    case ${option} in
        s)
            # System to set armbian/openelec
            export system=${OPTARG}
            ;;
        k)
            # Kodi profile id to set
            export kodiProfile=${OPTARG}
            ;;
        v)
            # Video mode to set [see: h3disp -m option]
            export videoMode=${OPTARG}
            ;;
        f)
            # Frame buffer config to set [see: h3disp -f option]
            export fbMode=${OPTARG}
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

    (SetNondm 1) || exit $?
    }

SetKodi() {
    echo "setKodi";
    local kodiProfile=$1

    (SetKodiProfile ${kodiProfile}) || exit $?

    (SetNondm 0) || exit $?
    }

SetResolution() {
    local videoMode=$1
    local fbMode=$2
    echo "SetResolution: ${videoMode} fbmode: ${fbMode}";
}

SetKodiProfile() {
    local kodiProfile=$1
    echo "SetKodiProfile: ${kodiProfile}"
}

DisplayHelp() {
    echo ""HELP
}
Main "$@"