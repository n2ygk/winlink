#!/bin/bash
# following to build from source:
wget -q https://golang.org/dl/go1.17.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz
echo "export PATH=/usr/local/go/bin:$PATH:~/.go/bin" >> ~vagrant/.profile
echo "export GOPATH=~/.go" >> ~vagrant/.profile
/usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
mkdir ~vagrant/src
cd ~vagrant/src
git clone https://github.com/la5nta/pat.git
