#!/bin/bash

if [[ $1 != "install" ]]; then
  echo "Usage: $0 install pushmethod"
  echo "Availible push methods : pushover | telegram"
else
  if [[ "$(id -u)" != "0" ]]; then
    echo "This script requires root privileges. Try appending sudo at the beginning of the command."
    echo "For example:"
    echo "sudo $0 install"
  fi
  
  if [[ $2 == "pushover" ]]; then
    echo "Enter your Pushover app key:"
    echo "(If you don't have one, you can create one at https://pushover.net/apps/build after logging in.)"
    read PUSHOVER_USER_APP_TOKEN
    echo "Enter your Pushover user key:"
    echo "(Can be viewed at https://pushover.net/ after logging in.)"
    read PUSHOVER_USER_USER_TOKEN
  
    sed -i -e "s/YOURAPPTOKEN/$PUSHOVER_USER_APP_TOKEN/g" login-notification-pushover.bash
    sed -i -e "s/YOURUSERTOKEN/$PUSHOVER_USER_USER_TOKEN/g" login-notification-pushover.bash
  
    cp login-notification-pushover.bash /usr/local/bin/login-notification-pushover.bash
    chmod +x /usr/local/bin/login-notification-pushover.bash
    echo "session optional       pam_exec.so /usr/local/bin/login-notification-pushover.bash" >> /etc/pam.d/common-session
  fi

  if [[ $2 == "telegram" ]]; then
    echo "In order to recieve notifications via telegram you must create a bot. to do so, add @BotFather and follow the instructions.\n
    Once your bot is created you will recieve a token, please enter that token here :"
    read TELEGRAM_HTTPTOKEN
    
    echo "Please start a conversation with the bot, and send it a message"
    read
    curl 'https://api.telegram.org/bot'$TELEGRAM_HTTPTOKEN'/getUpdates?limit=1' > /dev/null
    echo "Please send the bot another message then press enter"
    read
    tgname=$(
      curl 'https://api.telegram.org/bot'$TELEGRAM_HTTPTOKEN'/getUpdates?limit=1' | 
      python3 -c 'import json,sys;obj=json.load(sys.stdin);print(obj["result"][0]["message"]["from"]["first_name"] + " "+  obj["result"][0]["message"]["from"]["last_name"]);'
      )

    echo "Are you "$tgname" ? (y/n)"
    read answer
    if [[ $answer != "y" ]]; then
      echo "Exiting"
      exit
    fi
    TELEGRAM_USERID=$(
      curl 'https://api.telegram.org/bot'$TELEGRAM_HTTPTOKEN'/getUpdates?limit=1' | 
      python3 -c 'import json,sys;obj=json.load(sys.stdin);print(obj["result"][0]["message"]["from"]["id"]);'
      )
    
    sed -i -e "s/YOURUSERID/$TELEGRAM_USERID/g" login-notification-telegram.bash
    sed -i -e "s/YOURTOKEN/$TELEGRAM_HTTPTOKEN/g" login-notification-telegram.bash
  
    cp login-notification-telegram.bash /usr/local/bin/login-notification-telegram.bash
    chmod +x /usr/local/bin/login-notification-telegram.bash
    echo "session optional       pam_exec.so /usr/local/bin/login-notification-telegram.bash" >> /etc/pam.d/common-session
    echo "Setup Complete"
  fi
fi
