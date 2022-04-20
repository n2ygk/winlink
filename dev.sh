#!/bin/bash
set -x
# the one true editor:
apt-get update
apt-get install -y emacs
#apt-get install -y golang-mode
echo "(add-hook 'before-save-hook #'gofmt-before-save)" >~vagrant/.emacs
# following to build from source:
wget -q https://golang.org/dl/go1.17.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz
echo "export PATH=/usr/local/go/bin:$PATH:~/.go/bin" >> ~vagrant/.profile
echo "export GOPATH=~/.go" >> ~vagrant/.profile
/usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
cd ~/vagrant/src/pat
git checkout develop
git pull
sudo systemctl stop pat@vagrant
./make.bash libax25
./make.bash
sudo install -c pat /usr/bin/pat
sudo systemctl start pat@vagrant
