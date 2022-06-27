#!/bin/bash
set -x
# the one true editor:
sudo apt-get update
sudo apt-get install -y emacs
sudo apt-get install -y build-essential fakeroot devscripts
sudo apt-get -y build-dep soundmodem
# enable rebuilding soundmodem.deb package:
https://salsa.debian.org/debian-hamradio-team/soundmodem.git
# this gets an older version that what is distrubted!
# apt-get source soundmodem
(cd ~vagrant/src/debian; git clone https://salsa.debian.org/debian-hamradio-team/soundmodem.git)
echo 'Use "debuild -b -uc -us" to rebuild soundmodem'

#apt-get install -y golang-mode
echo "(add-hook 'before-save-hook #'gofmt-before-save)" >~vagrant/.emacs
# following to build from source:
wget -q https://golang.org/dl/go1.17.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz
echo "export PATH=/usr/local/go/bin:$PATH:~/.go/bin" >> ~vagrant/.profile
echo "export GOPATH=~/.go" >> ~vagrant/.profile
export PATH=/usr/local/go/bin:$PATH:~/.go/bin
export GOPATH=~/.go
/usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
cd ~/vagrant/src/pat
git checkout develop
git pull
sudo systemctl stop pat@vagrant
./make.bash libax25
./make.bash
sudo install -c pat /usr/bin/pat
sudo systemctl start pat@vagrant
