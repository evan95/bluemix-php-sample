#!/bin/bash
echo "apt-get -qq -y install python3.6"
sudo apt-get -qq -y install python3.6
python --version
echo "apt-get -qq update"
sudo apt-get -qq update
echo "apt-get -qq -y install python-dev libssl-dev libffi-dev"
sudo apt-get -qq -y install python-dev libssl-dev libffi-dev
echo "pip install pycrypto pyyaml ansible --quiet"
sudo pip install pycrypto pyyaml ansible --quiet

echo "apt-get -qq clean"
sudo apt-get -qq clean
