# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-cachier vagrant-vbguest )
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian11"
  config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.synced_folder "~/Library/Application Support/pat/mailbox", "/home/vagrant/.local/share/pat/mailbox"
  config.vm.synced_folder ".", "/vagrant"
  config.vm.synced_folder "~/src", "/home/vagrant/src"
  config.vm.synced_folder "~/.gnupg", "/home/vagrant/.gnupg"
  # Enable USB Controller on VirtualBox
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "on"]
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]
    vb.customize ["usbfilter", "add", "0",
        "--target", :id,
        "--name", "Belkin USB PDA Adapter",
        "--vendorid", "050D",
        "--productid", "0109"]
    vb.customize ["usbfilter", "add", "1",
        "--target", :id,
        "--name", "VFAN GPS",
        "--vendorid", "1546",
        "--productid", "01A7"]
    # TODO: "3D Sound" audio device use vendorid/productid
    # vb.customize ["usbfilter", "add", "2",
    #     "--target", :id,
    #     "--name", "Generic USB Audio Device",
    #     "--product", "Generic USB Audio Device"]
  end

  config.vm.provision "install",
                      type: "shell",
                      path: "install.sh"
  config.vm.provision "pat-config",
                      type: "file",
                      source: "~/Library/Application Support/pat/config.json",
                      destination: "~vagrant/.config/pat/config.json"
  config.vm.provision "minicom",
                      type: "file",
                      source: "minirc.dfl",
                      destination: "~vagrant/.minirc.dfl"
  config.vm.provision "gitconfig",
                      type: "file",
                      source: "~/.gitconfig",
                      destination: "~vagrant/.gitconfig",
                      run: "always"
  config.vm.provision "ssh",
                      type: "file",
                      source: "~/.ssh/id_rsa",
                      destination: "~vagrant/.ssh/id_rsa",
                      run: "always"
  config.vm.provision "start-pat",
                      type: "shell",
                      path: "start-pat.sh",
                      run: "always"
  # this will fail if the serial port is not connected.
  config.vm.provision "start-ax25",
                      type: "shell",
                      path: "start-ax25.sh",
                      run: "always"
  config.vm.provision "start",
                      type: "shell",
                      path: "start.sh",
                      run: "never"
  config.vm.provision "dev",
                      type: "shell",
                      path: "dev.sh",
                      run: "never"
  config.vm.post_up_message = <<-EoF
    Use 'vagrant provision --provision-with dev' to install PAT source code.
    Use 'vagrant provision --provision-with start' to restart ax25, and pat.
    Use 'You may have to replug the USB GPS to get it to be recognized.
  EoF
end
