#!/bin/sh

source ./config.sh

echo "This script file must be executed after su command."
echo -n "Are you ready? [y/n] "
ANSWER1=`read_and_set`

case ${ANSWER1} in
  n)
    echo "The script was blocked."
    exit
    break
    ;;
esac

echo
echo "* Install semanage"
yum -y install policycoreutils-python

echo
echo "* SSH configuration"

SSH_PORT_NUMBER=""

echo -n "Do you want to change ${SSH_CONFIG}? [y/n] "
ANSWER_SSH_CONFIG=`read_and_set`

case ${ANSWER_SSH_CONFIG} in
  n)
    echo "SSH configuration was skipped."
    break
    ;;
esac

RESTORE_SSH_CONFIG=0
if [ -f ${SSH_CONFIG_BACKUP} ]; then
  RESTORE_SSH_CONFIG=1
fi

case ${ANSWER_SSH_CONFIG} in
  y)
    if [ ${RESTORE_SSH_CONFIG} -eq 1 ]; then
      rm ${SSH_CONFIG}
      cp -i ${SSH_CONFIG_BACKUP} ${SSH_CONFIG}
    else
      cp -i ${SSH_CONFIG} ${SSH_CONFIG_BACKUP}
    fi

    echo -n "Change port number (just Enter for no change): "
    read SSH_PORT_NUMBER

    echo -e "These settings were changed.\n"

    # Port
    if [ ${#SSH_PORT_NUMBER} -ne 0 ]; then
      change_setting ${SSH_CONFIG} Port ${SSH_PORT_NUMBER}
      grep "^Port" ${SSH_CONFIG}
      SSH_PORT_USE_DEFAULT=0
    else
      SSH_PORT_NUMBER="22"
      SSH_PORT_USE_DEFAULT=1
    fi

    # PermitRootLogin
    change_setting ${SSH_CONFIG} PermitRootLogin no
    grep "^PermitRootLogin" ${SSH_CONFIG}

    # PasswordAuthentication
    change_setting ${SSH_CONFIG} PasswordAuthentication no
    grep "^PasswordAuthentication" ${SSH_CONFIG}

    # ChallengeResponseAuthentication
    change_setting ${SSH_CONFIG} ChallengeResponseAuthentication no
    grep "^ChallengeResponseAuthentication" ${SSH_CONFIG}

    # PermitEmptyPasswords
    change_setting ${SSH_CONFIG} PermitEmptyPasswords no
    grep "^PermitEmptyPasswords" ${SSH_CONFIG}

    # SyslogFacility
    change_setting ${SSH_CONFIG} SyslogFacility AUTHPRIV
    grep "^SyslogFacility" ${SSH_CONFIG}

    # LogLevel
    change_setting ${SSH_CONFIG} LogLevel VERBOSE
    grep "^LogLevel" ${SSH_CONFIG}

    # TCP Port Forwarding
    #change_setting ${SSH_CONFIG} AllowTcpForwarding no
    #grep "^AllowTcpForwarding" ${SSH_CONFIG}

    # AllowStreamLocalForwarding
    #change_setting ${SSH_CONFIG} AllowStreamLocalForwarding no
    #grep "^AllowStreamLocalForwarding" ${SSH_CONFIG}

    # GatewayPorts
    #change_setting ${SSH_CONFIG} GatewayPorts no
    #grep "^GatewayPorts" ${SSH_CONFIG}

    # PermitTunnel
    #change_setting ${SSH_CONFIG} PermitTunnel no
    #grep "^PermitTunnel" ${SSH_CONFIG}

    echo

    echo "Edit \"AllowUsers\" if you need."
    echo
    break
    ;;
esac


echo "Press any key to continue ... "
read BUFFER
echo

echo
echo "* Firewall configuration"

# activate firewalld
FW_INACTIVE=`systemctl status firewalld.service | grep inactive`
if [ ${#FW_INACTIVE} -ne 0 ]; then
  echo "firewalld is inactive."
  echo -n "Activating firewalld ... "
  systemctl start firewalld.service
  echo "[done]"
fi

echo "This is your firewalld setting."
echo

firewall-cmd --list-all

#if [ ${SSH_PORT_USE_DEFAULT} -eq 1 ];
  echo -n "Do you want to change firewall settings?"
  echo -n "( If you changed the SSH port number, you MUST choose 'y' ) [y/n] "
  ANSWER_FW_CONFIG=`read_and_set`
#fi

case ${ANSWER_FW_CONFIG} in
  n)
    echo "firewalld configuration was skipped."
    break
    ;;
esac

RESTORE_FW_CONFIG=0
if [ -f ${FW_SSH_CONFIG_BACKUP} ]; then
  RESTORE_FW_CONFIG=1
fi


case ${ANSWER_FW_CONFIG} in
  y)
    echo -n "Changing firewall setting for HTTP ... "
    firewall-cmd --add-service=http --zone=public --permanent
    #firewall-cmd --add-port=80/tcp --zone=public --permanent
    echo "[done]"
    echo -n "Changing firewall setting for HTTPS ... "
    firewall-cmd --add-service=https --zone=public --permanent
    #firewall-cmd --add-port=443/tcp --zone=public --permanent
    echo "[done]"

    if [ ${SSH_PORT_USE_DEFAULT} -ne 1 ]; then
      if [ ${RESTORE_FW_CONFIG} -eq 1 ]; then
        rm ${FW_SSH_CONFIG}
        cp -i ${FW_SSH_CONFIG_BACKUP} ${FW_SSH_CONFIG}
      else
        cp -i ${FW_SSH_CONFIG} ${FW_SSH_CONFIG_BACKUP}
      fi

      FW_SSH_CONFIG_ANOTHER_PORT="/etc/firewalld/services/ssh-${SSH_PORT_NUMBER}.xml"
      cp -i ${FW_SSH_CONFIG} ${FW_SSH_CONFIG_ANOTHER_PORT}

      echo -n "Changing firewall setting for SSH new port number ... "
      firewall-cmd --permanent --remove-service=ssh
      sed -i '/port protocol/c \ \ <port protocol="tcp" port="'${SSH_PORT_NUMBER}'"/>' ${FW_SSH_CONFIG_ANOTHER_PORT}
      firewall-cmd --permanent --add-service=ssh-${SSH_PORT_NUMBER}
      firewall-cmd --add-port=${SSH_PORT_NUMBER}/tcp --zone=public --permanent
      echo "[done]"
      echo "Changing SELinux setting ... "
      set -x
      semanage port --list | grep ssh
      semanage port --add --type ssh_port_t --proto tcp ${SSH_PORT_NUMBER}
      semanage port --list | grep ssh
      set +x
      echo "[done]"
      echo "firewall setting for SSH is changed as below."
      echo
      cat ${FW_SSH_CONFIG_ANOTHER_PORT}
    fi

    break
    ;;
esac

case ${ANSWER_FW_CONFIG} in
  y)
    echo "Auto reloading firewalld ... "
    systemctl enable firewalld.service
    firewall-cmd --reload
    echo "firewalld was reloaded."
    echo "firewalld active ports"
    firewall-cmd --list-ports --zone=public --permanent
    echo "SELinux SSH active ports"
    semanage port --list | grep ssh
    break
    ;;
esac

case ${ANSWER_SSH_CONFIG} in
  y)
    echo "Auto reloading sshd ... "
    SSHD_INACTIVE=`systemctl status sshd.service | grep inactive`
    if [ ${#SSHD_INACTIVE} -ne 0 ]; then
      systemctl start sshd.service
    else
      systemctl restart sshd.service
    fi
    systemctl enable sshd.service
    break
    ;;
esac
