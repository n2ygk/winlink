#!/bin/bash
# The copied host config may bind to localhost. Vagrant's forwarded port needs
# Pat to accept connections on the guest's network interface.
mkdir -p /etc/systemd/system/pat@vagrant.service.d
cat >/etc/systemd/system/pat@vagrant.service.d/http.conf <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/pat http --addr :8080
EOF
systemctl daemon-reload
su vagrant -c "pat templates update"
systemctl restart pat@vagrant
systemctl status pat@vagrant
