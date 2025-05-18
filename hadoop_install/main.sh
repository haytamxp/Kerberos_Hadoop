#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE
# THIS IS THE MAIN SCRIPT, RUN THIS AS ROOT

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Make sure file named .env exists in current directory
if [ ! -f ./.env ]; then
    echo ".env file not found! Aborting..."
    exit
fi

echo "Select if you are installing the Master Node or a Data Node :\n  [1] Master Node\n  [2] Data Node\n  [0] Exit\nSelection : "
read mode
case mode in 
  1)
    echo "Installing for MasterNode..."
    sh hadoop_install.sh && sh nn_rm_config.sh
    ;;

  2)
    echo "Installing for DataNode..."
    sh hadoop_install.sh && sh dn_nm_config.sh
    ;;
  
esac

echo "Exiting..."
exit
