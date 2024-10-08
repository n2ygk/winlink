#!/bin/bash
# scripted setup invoked from Vagrantfile.
# runs as root.

sed -i.bak -e 's/^#AddressFamily.*$/AddressFamily inet/' /etc/ssh/sshd_config
systemctl reload sshd
wget -q https://github.com/la5nta/pat/releases/download/v0.16.0/pat_0.16.0_linux_amd64.deb
dpkg -i pat*.deb
apt-get update
apt-get install -y xauth
apt-get install -y usbutils
apt-get install -y gpsd
apt-get install -y minicom
apt-get install -y ax25-tools
apt-get install -y ax25-apps
apt-get install -y tmd710-tncsetup
apt-get install -y soundmodem
apt-get install -y alsa-utils
# apt-get install -y libasound2-dev
# apt-get install -y libudev-dev
usermod -G dialout -a vagrant
# not sure if this is required
# usermod -G root -a gpsd
# apparently ipv6 is not configured (properly):
sed -i.bak -e 's/^BindIPv6Only=yes/#BindIPv6Only=yes/' \
           -e 's/^ListenStream=\[::1\]:2947/#ListenStream=[::1]:2947/' /lib/systemd/system/gpsd.socket
# winlink/pat:
echo "wl2k N2YGK 9600 255 7 Winlink" >/etc/ax25/axports
/usr/share/pat/ax25/install-systemd-ax25-unit.bash
sed -i.bak -e 's/ttyUSB0/mytnc/' /etc/default/ax25
echo 'TNC_INIT_CMD="/usr/bin/tmd710_tncsetup -B 1 -S $DEV -b $HBAUD"' >>/etc/default/ax25
chown -R vagrant ~vagrant/.local
# pat.dpkg installs the ax25.service
# customize ax25 to hotplug start/stop when the USB serial adapter is plugged in:
# this gives us a consistent name irrespective of USB port number:
cp /vagrant/95-myusb.rules /lib/udev/rules.d/
# and this references it:
cp /vagrant/ax25.service /lib/systemd/system/
systemctl daemon-reload
systemctl disable ax25
systemctl enable ax25
systemctl enable pat@vagrant
