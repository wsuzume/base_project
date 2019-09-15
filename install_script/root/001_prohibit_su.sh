#!/bin/sh

echo "===Install script 1st stage==="

SU_FILE="/etc/pam.d/su"
SU_BACKUP_FILE="/etc/pam.d/su_backup"

echo "* Prohibit su command except wheel users"
if [ -f ${SU_BACKUP_FILE} ]; then
  echo -n "Backup file is already exists. Continue anyway? [y/n] "
  read ANSWER
else
  ANSWER="y"
fi

case ${ANSWER} in
  y)
    cp -i ${SU_FILE} ${SU_BACKUP_FILE}
    echo -e "\n#This is written by install script" >> ${SU_FILE}
    echo -e "auth\t\trequired\tpam_wheel.so use_uid" >> ${SU_FILE}
    echo -e "${SU_FILE} is overwritten as below.\n\n"
    echo -e "------------------------------------------------------"
    cat ${SU_FILE}
    echo -e "------------------------------------------------------"
    echo -e "\n\n"
    break
    ;;
  n)
    echo -e "Process was canceled."
    break
    ;;
  *)
    echo -e "Cannot understand \"${ANSWER}\"."
    break
    ;;
esac

