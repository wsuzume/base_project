function change_setting () {
  TARGET=$1
  KEYWORD=$2
  VALUE=$3

  EXIST=`grep "^${KEYWORD}" ${TARGET}`
  EXIST_COMMENT=`grep "^#${KEYWORD}" ${TARGET}`

  if [ ${#EXIST} -ne 0 ]; then
    sed -i '/^'${KEYWORD}'/c '${KEYWORD}' '${VALUE}'' ${TARGET}
  elif [ ${#EXIST_PERMIT_COMMENT} -ne 0 ]; then
    sed -i '/^#'${KEYWORD}'/c '${KEYWORD}' '${VALUE}'' ${TARGET} 
  else
    echo -e "${KEYWORD} ${VALUE}" >> ${TARGET}
  fi
}

function read_and_set () {
    read ANSWER

    case ${ANSWER} in
        y)
          echo "y"
          break
          ;;
        n)
          echo "n"
          break
          ;;
        *)
          echo "Cannot understand \"${ANSWER}\"."
          exit
          break
          ;;
    esac
}

function ask () {
    for i in `seq 1 (${#} - 1)`    #引数の数だけループさせる
    do
      echo ${1}    #第一引数を表示
      shift        #shift
    done

    echo -n ${1}
}

SSH_TEMP_CLIENT_KEY="${HOME}/.ssh/temp_client_key"
SSH_AUTHORIZED_KEYS="${HOME}/.ssh/authorized_keys"

SSH_CONFIG="/etc/ssh/sshd_config"
SSH_CONFIG_BACKUP="/etc/ssh/sshd_config_backup"

FW_SSH_CONFIG="/usr/lib/firewalld/services/ssh.xml"
FW_SSH_CONFIG_BACKUP="/etc/firewalld/services/ssh_backup.xml"
