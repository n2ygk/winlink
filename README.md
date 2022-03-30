# Pat on my Mac

This is my [pat](https://github.com/la5nta/pat) Winlink configuration on my Mac.
Since MacOS broke support for serial USB devices a long time ago, this configures a
VirtualBox Debian Linux machine using vagrant, connected to my Kenwood TM-D710 mobile
rig via Linux ax.25 with a serial USB port in KISS mode. See the [Vagrantfile](./Vagrantfile) for details.

## Set up gpsd

It's supposed to just work as it's configured with udev hotplug but apparently
ipv6 is not configured properly so I had to do this:

```
sed -i.bak -e 's/^BindIPv6Only=yes/#BindIPv6Only=yes/' \
           -e 's/^ListenStream=[::1]:2947/#ListenStream=[::1]:2947/' /lib/systemd/system/gpsd.socket
```

## Set up AX25 KISS

The Pat debian package installs a default /lib/systemd/system/ax25.service but I want it to automatically
do the kissattach only when the USB serial port is plugged in.
This [Starting services on hotplug](https://unrouted.io/systemd/2017/05/21/starting-services-on-hotplug/) article
was really helpful in figuring out how to do that.

In summary, you have to find the name of your specific hotplug device and then update `ax25.service` to reference by
adding `Unit.BindsTo` and `Install.WantedBy` to reference that device.

```
root@debian11:/home/vagrant# systemctl |grep ttyUSB
  sys-devices-pci0000:00-0000:00:06.0-usb2-2\x2d1-2\x2d1:1.0-ttyUSB0-tty-ttyUSB0.device     loaded active plugged   KeyLargo/Intrepid USB
```

In this example, my device is named `sys-devices-pci0000:00-0000:00:06.0-usb2-2\x2d1-2\x2d1:1.0-ttyUSB0-tty-ttyUSB0.device`, so
here's my changed `ax25.service` which adds `BindsTo` and updates `WantedBy`.

```
[Unit]
Description=AX.25 KISS interface
After=network.target
BindsTo=sys-devices-pci0000:00-0000:00:06.0-usb2-2\x2d1-2\x2d1:1.0-ttyUSB0-tty-ttyUSB0.device

[Service]
EnvironmentFile=/etc/default/ax25
Type=forking
ExecStart=/usr/share/pat/bin/axup ${DEV} ${AXPORT} ${HBAUD}

[Install]
#WantedBy=default.target
WantedBy=sys-devices-pci0000:00-0000:00:06.0-usb2-2\x2d1-2\x2d1:1.0-ttyUSB0-tty-ttyUSB0.device
```

TODO: /etc/default/ax25 sets `DEV=/dev/ttyUSB0` so perhaps that needs to be set dynamically as well.

## Set up pat

Initial setup involves running `pat configure` on the Mac to set the various
options such as the password, etc.  Here's a snippet from my configuration:

```json
{
  "mycall": "N2YGK",
  "secure_login_password": "*REDACTED*",
  "http_addr": ":8080",
  "connect_aliases": {
    "ax25": "ax25:///WB2ZII-10",
    "telnet": "telnet://{mycall}:CMSTelnet@cms.winlink.org:8772/wl2k"
  }
}
```

## Run pat

In theory, `vagrant up` and then opening `http://localhost:8080` from the Mac
browser should do it. In practice you may need to do a few things:

```
$ vagrant ssh
  ...
$ sudo systemctl status ax25
$ sudo systemctl stop ax25
# mess with settings on Kenwood
$ sudo systemctl start ax25
$ sudo systemctl status pat@vagrant
$ sudo systemctl restart pat@vagrant
$ sudo axlisten -cart
```
![axlisten screen shot](./axlisten.png)

## Pat Mailbox

I've cross-mounted the MacOS pat mailbox directory so that any messages
sent or received under the virtualbox are preserved on the host Mac, making it safe
to `vagrant destroy` and rebuild as needed.

## Compiling and debugging pat source code

The `Vagrantfile` also installs an appropriate version of golang and the
pat git repo along with the [delve](github.com/go-delve/delve) debugger.







