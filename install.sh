#!/bin/bash
# scripted setup invoked from Vagrantfile.
# runs as root.
wget -q https://github.com/la5nta/pat/releases/download/v0.12.1/pat_0.12.1_linux_amd64.deb
dpkg -i pat*.deb
apt-get install -y usbutils
apt-get install -y minicom
apt-get install -y ax25-tools
apt-get install -y ax25-apps
apt-get install -y tmd710-tncsetup
apt-get install -y gpsd
usermod -G dialout -a vagrant
# not sure if this is required
# usermod -G root -a gpsd
# apparently ipv6 is not configured (properly):
sed -i.bak -e 's/^BindIPv6Only=yes/#BindIPv6Only=yes/' \
           -e 's/^ListenStream=\[::1\]:2947/#ListenStream=[::1]:2947/' /lib/systemd/system/gpsd.socket
# winlink/pat:
echo "wl2k N2YGK 9600 255 7 Winlink" >/etc/ax25/axports
/usr/share/pat/ax25/install-systemd-ax25-unit.bash
echo 'TNC_INIT_CMD="/usr/bin/tmd710_tncsetup -B 1 -S $DEV -b $HBAUD' >>/etc/default/ax25
chown -R vagrant ~vagrant/.local
# pat.dpkg installs the ax25.service
# customize ax25 to hotplug start/stop when the USB serial adapter is plugged in:
cp /vagrant/ax25.service /lib/systemd/system/
systemctl enable ax25
systemctl enable pat@vagrant
