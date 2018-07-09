Vagrant.configure("2") do |config|
    config.vm.provision "shell",
      inline: "sudo yum install -y rsync"
end
