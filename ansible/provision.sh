#!/usr/bin/env bash

if [ ! -f /root/ansible_ready ]; then
  # Update Repositories
  sudo apt-get update

  # Install bc
  sudo apt-get install bc

  # Determine Ubuntu Version
  . /etc/lsb-release

  # Decide on package to install for `add-apt-repository` command
  #
  # USE_COMMON=1 when using a distribution over 12.04
  # USE_COMMON=0 when using a distribution at 12.04 or older
  USE_COMMON=$(echo "$DISTRIB_RELEASE > 12.04" | bc)

  if [[ "$USE_COMMON" -eq "1" ]];
  then
    sudo apt-get install -y software-properties-common
  else
    sudo apt-get install -y python-software-properties
  fi

  # Add Ansible Repository & Install Ansible
  sudo add-apt-repository -y ppa:ansible/ansible
  sudo apt-get update
  sudo apt-get install -y ansible && sudo touch /root/ansible_ready

  # Copy vagrant's public key to allow ssh key authentication
  cat /vagrant/ansible/files/authorized_keys >> /home/vagrant/.ssh/authorized_keys

  # Provide localhost for ansible
  echo 'localhost' > /etc/ansible/hosts
  chmod 666 /etc/ansible/hosts
fi

if [ -z "$2" ]; then
  cd /vagrant && sudo -u vagrant HOME=/home/vagrant /usr/bin/python2 -u /usr/bin/ansible-playbook /vagrant/ansible/$1.yml --connection=local
else
  cd /vagrant && sudo -u vagrant HOME=/home/vagrant /usr/bin/python2 -u /usr/bin/ansible-playbook /vagrant/ansible/$1.yml --tags "$2" --connection=local
fi
