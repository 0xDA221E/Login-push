#!/bin/bash

if [[ $1 != "install" ]]; then
  echo "Usage: $0 install"
else
  if [[ "$(id -u)" != "0" ]]; then
    echo "This script requires root privileges. Try appending sudo at the beginning of the command."
    echo "For example:"
    echo "sudo $0 install"
  fi

  echo "Enter your Pushover app key:"
  echo "(If you don't have one, you can create one at https://pushover.net/apps/build after logging in.)"
  read PUSHOVER_USER_APP_TOKEN
  echo "Enter your Pushover user key:"
  echo "(Can be viewed at https://pushover.net/ after logging in.)"
  read PUSHOVER_USER_USER_TOKEN

  sed -i -e "s/YOURAPPTOKEN/$PUSHOVER_USER_APP_TOKEN/g" login-notification.bash
  sed -i -e "s/YOURUSERTOKEN/$PUSHOVER_USER_USER_TOKEN/g" login-notification.bash

  cp login-notification.bash /usr/local/bin/login-notification.bash
  chmod +x /usr/local/bin/login-notification.bash
  echo "session optional       pam_exec.so /usr/local/bin/login-notification.bash" >> /etc/pam.d/common-session
fi
