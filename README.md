# Pat on my Mac

This is my [pat](https://github.com/la5nta/pat) Winlink configuration on my Mac.
Since MacOS broke support for serial USB devices a long time ago, this configures a
VirtualBox Debian Linux machine using vagrant, connected to my Kenwood TM-D710 mobile
rig via Linux ax.25 in KISS mode. See the [Vagrantfile](./Vagrantfile) for details.

## Set up gpsd

It's supposed to just work as it's configured with udev hotplug but apparently
ipv6 is not configured properly so I had to do this:

```
sed -i.bak -e 's/^BindIPv6Only=yes/#BindIPv6Only=yes/' \
           -e 's/^ListenStream=[::1]:2947/#ListenStream=[::1]:2947/' /lib/systemd/system/gpsd.socket
```

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







