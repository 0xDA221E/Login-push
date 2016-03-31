#!/bin/bash

function showUsage() {
    echo "Usage: $0 ACTION"
    echo "Available actions: install / uninstall"

    exit 1
}

function showError() {
    echo "Error: $1" >&2

    exit 1
}

function checkRoot() {
    if [[ "$(id -u)" != "0" ]]; then
        echo "This script requires root privileges. Try appending sudo at the beginning of the command."
        echo "Example: sudo $0 install"

        exit 1
    fi
}

function installService() {
    checkRoot

    local pushMethod=$1

    case $pushMethod in
        "telegram")
            # Telegram push method

            local httpToken

            echo "In order to recieve notifications via telegram you must create a bot. to do so, add @BotFather and follow the instructions.\n
            Once your bot is created you will recieve a token, please enter that token here :"
            read httpToken
            
            echo "Please start a conversation with the bot, and send it a message. Then Press Enter."
            read
            curl 'https://api.telegram.org/bot'$httpToken'/getUpdates?limit=1' > /dev/null
            echo "Please send the bot another message then press Enter."
            read
            local tgname=$(
              curl 'https://api.telegram.org/bot'$TELEGRAM_HTTPTOKEN'/getUpdates?limit=1' | 
              python3 -c 'import json,sys;obj=json.load(sys.stdin);print(obj["result"][0]["message"]["from"]["first_name"] + " "+  obj["result"][0]["message"]["from"]["last_name"]);'
              )

            echo "Are you "$tgname" ? (y/N)"
            read answer
            if [[ $answer != "y" ]]; then
              showError "Please retry the Telegram setup process."
            fi

            local userId=$(
              curl 'https://api.telegram.org/bot'$httpToken'/getUpdates?limit=1' | 
              python3 -c 'import json,sys;obj=json.load(sys.stdin);print(obj["result"][0]["message"]["from"]["id"]);'
              )
              
            cp login-notification-telegram.bash login-notification-telegram.bash.mod
            sed -i -e "s/YOURTELEGRAMTOKEN/$httpToken/g" login-notification-telegram.bash.mod
            sed -i -e "s/YOURTELEGRAMUSERID/$userId/g" login-notification-telegram.bash.mod
          
            cp login-notification-telegram.bash.mod /usr/local/bin/login-notification-telegram.bash
            chmod +x /usr/local/bin/login-notification-telegram.bash
            echo "session optional       pam_exec.so /usr/local/bin/login-notification-telegram.bash" >> /etc/pam.d/common-session

            ;;

        "pushover")
            # Pushover push method

            local appToken
            local userToken

            echo "Enter your Pushover app key:"
            echo "(If you don't have one, you can create one at https://pushover.net/apps/build after logging in.)"
            read appToken

            echo "Enter your Pushover user key:"
            echo "(Can be viewed at https://pushover.net/ after logging in.)"
            read userToken

            cp login-notification-pushover.bash login-notification-pushover.bash.mod
            sed -i -e "s/YOURPUSHOVERAPPTOKEN/$appToken/g" login-notification-pushover.bash.mod
            sed -i -e "s/YOURPUSHOVERUSERTOKEN/$userToken/g" login-notification-pushover.bash.mod
          
            cp login-notification-pushover.bash.mod /usr/local/bin/login-notification-pushover.bash
            chmod +x /usr/local/bin/login-notification-pushover.bash
            echo "session optional       pam_exec.so /usr/local/bin/login-notification-pushover.bash" >> /etc/pam.d/common-session

            ;;

        *)
            # Incorrect push method provided

            showError "Unknown push method"
            ;;

    esac

    echo "Installation complete."
    exit 0
}

function updateService() {
    echo "Update"
}

function uninstallService() {
    echo "Uninstall"
}

if test $# -eq 0; then
    showUsage
    exit 1
fi

action=$1

case $action in
    "install")
        # Install the service

        if test $# -ne 2; then
            showError "No push method provided."
        fi

        installService $2
        ;;
    
    "update")
        # Update the service

        updateService
        ;;

    "uninstall")
        # Uninstall the service

        uninstallService
        ;;

    *)
        # Incorrect action provided

        showUsage
        ;;
esac

exit 0
