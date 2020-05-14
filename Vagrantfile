# -*- mode: ruby -*-

BASEDIR = File.dirname(__FILE__)

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  
  ### virtualbox provider
  config.vm.provider "virtualbox" do |vb, override|
    override.vm.network "private_network", ip: "203.0.113.10"
    override.vm.hostname = "tfe.example.com"
    config.hostsupdater.aliases = ["tfe-vagrant.example.com"]

    vb.memory = "3072"

    data_disk_path = "#{BASEDIR}/disk/data-vol.vdi"
    unless File.exist?(data_disk_path)
        vb.customize [
            "createhd",
            "--filename", data_disk_path,
            "--size", 15 * 1024,
        ]
    end

    vb.customize [
        "storageattach",
        :id,
        "--storagectl", "SCSI",
        "--port", 2,
        "--device", 0,
        "--type", "hdd",
        "--medium", data_disk_path,
    ]
  end

  config.vm.provision "shell", path: "provision.sh"
end
