Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |v|
        v.cpus = 2
    end
end
