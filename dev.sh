#!/bin/bash
# the one true editor:
apt-get install -y emacs
apt-get install -y golang-mode
echo "(add-hook 'before-save-hook #'gofmt-before-save)" >~vagrant/.emacs
# following to build from source:
wget -q https://golang.org/dl/go1.17.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz
echo "export PATH=/usr/local/go/bin:$PATH:~/.go/bin" >> ~vagrant/.profile
echo "export GOPATH=~/.go" >> ~vagrant/.profile
/usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
# ~/src is now cross-mounted, so no need to do this cloning etc.
# mkdir ~vagrant/src
# cd ~vagrant/src
# clone my development fork
# git clone git@github.com:n2ygk/pat.git
# cd pat
# git remote add upstream git@github.com:la5nta/pat.git
# cd ~/vagrant/src
# chown -R vagrant .
