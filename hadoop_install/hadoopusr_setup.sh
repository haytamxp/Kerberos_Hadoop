#!/bin/bash
# AUTHOR : GRAOUI ABDERRAHMANE


UsernGroupList = ("hadoopadmin" "hdfs" "hive" "HTTP" "yarn" "mapred")

# Only run this script if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# 0. Source sshpubkey

# Make sure file named .secretenv exists in current directory
if [ ! -f ./.secretenv ]; then
    echo ".secretenv file not found! Aborting..."
    exit
fi

source .secretenv

for userngroup in "${UsernGroupList[@]}"; do
  if id $userngroup >/dev/null 2>&1; then
    echo "$userngroup already exists, aborting..."
    break
  fi


  # 1. Create the user
  adduser --disabled-password --gecos "" $userngroup

  # 2. Set SSH public key (adjust path or use echo as needed)
  mkdir -p /home/$userngroup/.ssh
  echo $SSH_PUB_KEY > /home/$userngroup/.ssh/authorized_keys
  chmod 700 /home/$userngroup/.ssh
  chmod 600 /home/$userngroup/.ssh/authorized_keys
  chown -R $userngroup:$userngroup /home/$userngroup

  # 3. Lock down all other home directories
  for dir in /home/*; do
      inlist=false
      user=$(basename "$dir")
      for listitem in "{$UsernGroupList[@]}"; do
        if [[ "$user" == "$listitem" ]]; then
          inlist=true
          break
        fi
      done

      if ! $found; then
        chmod 700 "$dir"
      fi
  done

  # 4. Deny sudo and docker access
  deluser $userngroup sudo 2>/dev/null || true
  deluser $userngroup docker 2>/dev/null || true

  usermod -aG hadoopadmin $userngroup

  # 5. Restrict docker.sock (make sure not group-accessible to this user)
  chmod 660 /var/run/docker.sock
  chown root:docker /var/run/docker.sock

  # 6. Deny all sudo use explicitly
  echo "$userngroup ALL=(ALL:ALL) !ALL" > /etc/sudoers.d/99-$userngroup-nosudo
  chmod 440 /etc/sudoers.d/99-$userngroup-nosudo

  echo "✅ $userngroup is ready to SSH in"

done

# 7. Allow hadoopadmin to access sudo -u to the other users
cat << EOF >> "/etc/sudoers.d/95-hadoopadmin-allow-sudo-to-hdp"
hadoopadmin ALL=(hdfs) NOPASSWD: ALL
hadoopadmin ALL=(yarn) NOPASSWD: ALL
hadoopadmin ALL=(mapred) NOPASSWD: ALL
hadoopadmin ALL=(hive) NOPASSWD: ALL
hadoopadmin ALL=(HTTP) NOPASSWD: ALL
EOF
