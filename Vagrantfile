# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-cachier vagrant-vbguest )
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/debian11"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  config.vm.network "forwarded_port", guest: 8080, host: 8080

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.synced_folder "~/Library/Application Support/pat/mailbox", "/home/vagrant/.local/share/pat/mailbox"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable USB Controller on VirtualBox
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "on"]
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["usbfilter", "add", "0",
        "--target", :id,
        "--name", "Belkin USB PDA Adapter",
        "--vendorid", "050D",
        "--productid", "0109"]
    # "3D Sound" audio device
    # vb.customize ["usbfilter", "add", "1",
    #     "--target", :id,
    #     "--name", "Generic USB Audio Device",
    #     "--product", "Generic USB Audio Device"]
    # TODO: change this for my specific USB serial port
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    wget -q https://github.com/la5nta/pat/releases/download/v0.12.1/pat_0.12.1_linux_amd64.deb
    dpkg -i pat*.deb
    apt-get install -y usbutils
    apt-get install -y minicom
    apt-get install -y ax25-tools
    apt-get install -y ax25-apps
    apt-get install -y tmd710-tncsetup
    usermod -G dialout -a vagrant
    echo "wl2k N2YGK 9600 255 7 Winlink" >/etc/ax25/axports
    /usr/share/pat/ax25/install-systemd-ax25-unit.bash
    echo 'TNC_INIT_CMD="/usr/bin/tmd710_tncsetup -B 1 -S $DEV -b $HBAUD' >>/etc/default/ax25
    systemctl enable ax25
    systemctl start ax25
    systemctl status ax25 -l
    su vagrant -c "pat updateforms"
    systemctl enable pat@vagrant
    systemctl start pat@vagrant
    systemctl status pat@vagrant -l
    # following to build from source:
    wget -q https://golang.org/dl/go1.17.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz
    echo "export PATH=/usr/local/go/bin:$PATH:~/.go/bin" >> ~vagrant/.profile
    echo "export GOPATH=~/.go" >> ~vagrant/.profile
    /usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
    mkdir ~vagrant/src
    cd ~vagrant/src
    git clone https://github.com/la5nta/pat.git
    chown -R vagrant ~vagrant/.local
  SHELL
  config.vm.provision "pat-config", type: "file", source: "~/Library/Application Support/pat/config.json", destination: "~vagrant/.config/pat/config.json"
  config.vm.provision "minicom", type: "file", source: "minirc.dfl", destination: "/etc/minicom/minirc.dlf"

end
