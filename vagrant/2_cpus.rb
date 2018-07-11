Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |v|
        v.cpus = 4
    end
end
