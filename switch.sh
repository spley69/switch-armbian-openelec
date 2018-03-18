#!/bin/bash

# Global config
declare -A config
config=(
    ["nodm_configLocation"]="/xxx/xx/sas"
    ["armbian_maliDriverLocation"]="mali"
    ["armbian_umpDriverLocation"]="ump"
    ["openelec_maliDriverLocation"]="mali"
    ["openelec_umpDriverLocation"]="ump"
    )

#h3disp id resulution = openelec profile
declare -A resolutionConfig
resolutionConfig=(
    ["10"]="0"
    ["32"]="1"
    )

Main() {
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    local system=$1
    local videoMode=$2

    if [ ! ${system} ] || [ ! ${videoMode} ]; then
        echo "No parameters\n"
        DisplayHelp
        exit -1
    fi

#TODO: check config locations of files

    # switch armbian/openelec
    case ${system} in
        1|armbian) # Armbian
            SetArmbian
            ;;
        2|openelec) # Openelec - kodi
            SetOpenelec
            ;;
        *) # help
            DisplayHelp
            ;;
    esac

    (SetResolution ${videoMode}) || exit $?

    }

GetOpenelecProfile() {
    local videoMode=$1

    for mode in "${!resolutionConfig[@]}"; do
        # echo "${videoMode} MODE: ${mode}, PRO: ${resolutionConfig[$mode]}"
        if [ ${mode} == ${videoMode} ]; then
            echo ${resolutionConfig[$mode]}
            break
        fi
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

SetOpenelec() {
    echo "setOpenelec";

    (SetOpenelecProfile ${videoMode}) || exit $?

    (SetNondm 0) || exit $?
    }

SetResolution() {
    echo "ChangeResolution: $1";
}

SetOpenelecProfile() {
    local videoMode=$1

    local OpenelecProfile=$(GetOpenelecProfile ${videoMode})
    if [ ! ${OpenelecProfile} ]; then
        echo "error: no config for id resolution: ${videoMode}"
        return -1
    fi
}

DisplayHelp() {
    echo ""HELP
}
Main "$@"