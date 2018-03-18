#!/bin/bash

Main() {
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    # if [ $# -eq 0 ]; then
    #     DisplayHelp ; exit 0
    # else
    #     echo "$@"
    # fi

    case $@ in
        1|armbian1080) # Armbian 1080p
            SetArmbian
            SetResolution "1080p"
            ;;
        2|armbian600) # Armbian 800x600
            SetArmbian
            SetResolution "800x600"
            ;;
        3|openelec1080) # kodi 1080p
            SetOpenelec
            SetResolution "1080p"
            SetOpenelecProfile
            ;;
        4|openelec600) # kodi 800x600
            SetOpenelec
            SetResolution "800x600"
            SetOpenelecProfile
            ;;
        *) # help
            DisplayHelp
            ;;
    esac
    }

SetArmbian() {
    echo "setArmbian";
    }

SetOpenelec() {
    echo "setOpenelec";
    }

# $1 -ressolution to set
SetResolution() {
    echo "ChangeResolution: $1";
}

SetOpenelecProfile() {
    echo "setopenelecProfile";
}

DisplayHelp() {

    echo ""HELP
}

Main "$@"