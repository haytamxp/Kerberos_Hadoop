#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE
# THIS IS THE MAIN SCRIPT, RUN THIS AS ROOT

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Load OS info
source /etc/os-release

# Check ID or ID_LIKE
if ! ([[ "$ID" == "ubuntu" || "$ID" == "debian" ]] || [[ "$ID_LIKE" == *"debian"* ]]); then
  echo "This system is not Debian or Ubuntu based. Exiting..." >&2
  exit 72
fi

# Make sure file named .env exists in current directory
if [ ! -f ./.env ]; then
    echo ".env file not found! Aborting..."
    exit
fi

# Install dependencies
if ! dpkg -l dialog >/dev/null 2>&1 ; then
  echo "Installing dependencies..."
	apt update
	apt install dialog -y || echo "Installation failed" && exit -1
fi


HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Apache Hadoop Install script"
TITLE="Main Menu"
MENU="What would you like to install on this machine?"

OPTIONS=(1 "MasterNode"
         2 "DataNode"
         3 "Kerberos + OpenLDAP"
         4 "Exit")

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
    echo "Installing for MasterNode..."
    bash ./hadoopusr_setup.sh && bash ./hadoop_install.sh && bash ./nn_rm_config.sh
    ;;

  2)
    HEIGHT=15
    WIDTH=40
    CHOICE_HEIGHT=4
    BACKTITLE="Apache Hadoop Install script"
    TITLE="Datanode Select"
    MENU=""

    OPTIONS=(1 "DataNode 1"
            2 "DataNode 2"
            3 "Return")

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
      echo "Installing for DataNode 1..."
      bash ./hadoopusr_setup.sh && bash ./hadoop_install.sh && bash ./dn_nm_config.sh dn1
      ;;
    2)
      echo "Installing for DataNode 2..."
      bash ./hadoopusr_setup.sh && bash ./hadoop_install.sh && bash ./dn_nm_config.sh dn2
      ;;
    3)
      return
      ;;
    esac
  3)
    echo "Exiting..."
    exit
    ;;
  4)
    echo "Exiting..."
    exit
    ;;
esac
