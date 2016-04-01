#!/usr/bin/env bash

trap ctrl_c INT
function ctrl_c()
{
        printf "trapped Ctrl+C"
}

if [[ $PAM_TYPE == "close_session" ]]; then
        echo "User logged out."
        exit 0
fi

if [[ -z "$PAM_RHOST" ]]; then
        PAM_RHOST="localhost"
fi

if [[ -z "$PAM_RUSER" ]]; then
        PAM_RUSER="[UNKNOWN]"
fi

DATE=$(date)

# PUSHOVER APP TOKEN
# PUSHOVER USER
# source login-notification-pushover.bash