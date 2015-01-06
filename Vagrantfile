# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "vagrant-w7-choco-bs"

  config.vm.box_check_update = false

  config.vm.communicator = "winrm"
  config.vm.guest = :windows

  config.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = "2048"
  end

  config.vm.provision "shell", path: "build_harbour.ps1"

end
