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
usermod -G root -a gpsd
# GPSD config still not right
sed -i.bak -e 's:DEVICES="":DEVICES="/dev/ttyACM0":' \
	   -e 's:USBAUTO.*$:USBAUTO="false":' /etc/default/gpsd
echo 'GPSD_SOCKET="/run/gpsd.sock"' >> /etc/default/gpsd
sed -i.bak -e 's/BindIPv6Only=yes/BindIPv6Only=no/' /lib/systemd/system/gpsd.socket
echo "wl2k N2YGK 9600 255 7 Winlink" >/etc/ax25/axports
/usr/share/pat/ax25/install-systemd-ax25-unit.bash
echo 'TNC_INIT_CMD="/usr/bin/tmd710_tncsetup -B 1 -S $DEV -b $HBAUD' >>/etc/default/ax25
chown -R vagrant ~vagrant/.local
systemctl enable gpsd
systemctl enable ax25
systemctl enable pat@vagrant
