#!/bin/bash
# AUTHOR: GRAOUI ABDERRAHMANE
# THIS IS THE MAIN SCRIPT, RUN THIS AS ROOT

set -e  # Exit on unhandled errors

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Load OS info
source /etc/os-release

# Check OS compatibility
if ! ([[ "$ID" == "ubuntu" || "$ID" == "debian" ]] || [[ "$ID_LIKE" == *"debian"* ]]); then
  echo "This system is not Debian or Ubuntu based. Exiting..." >&2
  exit 72
fi

# Make sure .env file exists
if [ ! -f ./.env ]; then
  echo ".env file not found! Aborting..."
  exit 1
fi

# Install dependencies
if ! dpkg -l dialog >/dev/null 2>&1; then
  echo "Installing dependencies..."
  apt update
  apt install dialog -y || { echo "Installation failed"; exit 1; }
fi

# Function for prompt
confirm_kerberos_ssh() {
  dialog --title "WARNING!!!" \
    --backtitle "Apache Hadoop Install script" \
    --yesno "This installation option depends on an existing installation. Is Kerberos and SSH keys set up and working?" 7 60

  return $?
}

# Function for installing a DataNode
install_datanode() {
  local node="$1"
  if confirm_kerberos_ssh; then
    echo "Installing for $node..."
    cd hadoop_install/
    bash ./hadoopusr_setup.sh && bash ./hadoop_install.sh && bash ./dn_nm_config.sh "$node"
    cd ../
  else
    echo "Aborted by user."
  fi
}

# Main dialog menu
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Apache Hadoop Install script"
TITLE="Main Menu"
MENU="What would you like to install on this machine?"

OPTIONS=(1 "MasterNode"
         2 "DataNode"
         3 "Kerberos + OpenLDAP + Docker + Authentik Server + AlpineSSH"
         4 "Docker + Secure Web Application Gateway + Authentik Worker/Redis/PostgreSQL + AlpineSSH"
         5 "Exit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
  1)
    if confirm_kerberos_ssh; then
      echo "Installing for MasterNode..."
      cd hadoop_install/
      bash ./hadoopusr_setup.sh && bash ./hadoop_install.sh && bash ./nn_rm_config.sh
      cd ../
    else
      echo "Aborted by user."
    fi
    ;;

  2)
    HEIGHT=15
    WIDTH=40
    CHOICE_HEIGHT=4
    BACKTITLE="Apache Hadoop Install script"
    TITLE="Datanode Select"
    MENU="Choose a DataNode to install"

    DN_OPTIONS=(1 "DataNode 1"
                2 "DataNode 2"
                3 "Return")

    DN_CHOICE=$(dialog --clear \
                        --backtitle "$BACKTITLE" \
                        --title "$TITLE" \
                        --menu "$MENU" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${DN_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

    clear
    case $DN_CHOICE in
      1) install_datanode "DataNode 1" ;;
      2) install_datanode "DataNode 2" ;;
      3) echo "Returning to main menu." ;;
    esac
    ;;

  3)
    echo "Installing for Kerberos Stack..."
    cd krb_install/
    bash ./kerberos.sh && bash ./ldap.sh
    cd ../
    cd docker_install/
    bash install_docker.sh krb
    cd ../
    ;;

  4)
    echo "Installing for Docker Web Stack..."
    cd docker_install/
    bash install_docker.sh proxy
    cd ../
    ;;

  5)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting..."
    exit 1
    ;;
esac
