#!/bin/sh

source ./config.sh

echo "* Register your client PC's SSH public key to this server"

echo "Before you run this script, check if you are NOT su."
echo "This script will be failed if you are su."
echo -n "Are you ready? [y/n] "

ANSWER1=`read_and_set`

case ${ANSWER1} in
  y)
    break
    ;;
  *)
    echo "The script was blocked."
    exit
esac

echo
mkdir ~/.ssh
echo "Directory ~/.ssh was created."
echo "Copy your client PC's public key to this server."
echo "Use below command (especially, the target filename is important because"
echo "the settings after copying will be executed automatically)"
echo
echo "$ scp pubkey username@address:~/.ssh/temp_client_key"
echo
echo -n "Is copying completed? [y/n] "

ANSWER2=`read_and_set`

echo

case ${ANSWER2} in
  n)
    echo "Please re-execute this script after the public key is copied."
    exit
    break
    ;;
  y)
    if [ ! -f ${SSH_TEMP_CLIENT_KEY} ]; then
      echo "public key not found."
      exit
    fi
    cat ${SSH_TEMP_CLIENT_KEY} >> ${SSH_AUTHORIZED_KEYS}
    chmod 600 ${SSH_AUTHORIZED_KEYS}
    rm ${SSH_TEMP_CLIENT_KEY}

    echo "SSH public key setting done."
    break
    ;;
esac
