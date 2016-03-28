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

### TELEGRAM SETTINGS ###
TELEGRAM_TOKEN=194823705:AAF2q7oFk0D1-DNn9GOh6zDkcBLFN7Q18C4
TELEGRAM_USERID=32862227
TELEGRAM_MESSAGE=$HOSTNAME "Login notification : User <b>$PAM_USER</b> opened a session from <b>$PAM_RUSER@$PAM_RHOST</b> through <b>$PAM_SERVICE</b> at <i>$DATE</i>."
### ENDOF TELEGRAM SETTINGS ###

curl --data "chat_id=$TELEGRAM_USERID&parse_mode=html" --data-urlencode "text=$TELEGRAM_MESSAGE"  "https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendMessage"  > /dev/null 2>&1 &
