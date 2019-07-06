#!/bin/bash

# Installing Ruby
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential

# Installing MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y mongodb-org

# Starting MongoDB
sudo systemctl start mongod

# Enable autostart MongoDB
sudo systemctl enable mongod

# Cloning app
cd ~
git clone -b monolith https://github.com/express42/reddit.git

# Starting app
cd reddit
bundle install
puma -d
