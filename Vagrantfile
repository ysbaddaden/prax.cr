DEBIAN_SCRIPT = <<SHELL
# global dependencies
apt-get update
apt-get --yes upgrade
apt-get --yes install build-essential llvm-3.5-dev rpm

# crystal dependencies
#apt-get --yes install libpcre3-dev libevent-dev liblzma-dev
#apt-get --yes install libgc-dev libunwind8-dev libpcl-dev

# prax dependencies
apt-get --yes install libssl-dev

# crystal
apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
echo "deb http://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list
apt-get --yes install crystal

# ruby (tests + packaging)
apt-get --yes install ruby2.0 ruby2.0-dev
ln -sf /usr/bin/erb2.0 /usr/bin/erb
ln -sf /usr/bin/gem2.0 /usr/bin/gem
ln -sf /usr/bin/irb2.0 /usr/bin/irb
ln -sf /usr/bin/rake2.0 /usr/bin/rake
ln -sf /usr/bin/rdoc2.0 /usr/bin/rdoc
ln -sf /usr/bin/ri2.0 /usr/bin/ri
ln -sf /usr/bin/ruby2.0 /usr/bin/ruby
ln -sf /usr/bin/testrb2.0 /usr/bin/testrb

gem install bundler
cd /vagrant && bundle install

apt-get clean
SHELL

REDHAT_SCRIPT = <<SHELL
# global dependencies
yum install epel-release
#yum -y groupinstall "Development Tools"
yum -y install llvm

# crystal dependencies
# ...

# prax dependencies
# ...

# crystal
# ...

# ruby
# ...

#gem install bundler
#cd /vagrant && bundle install

#yum clean
SHELL

Vagrant.configure("2") do |config|
  config.ssh.forward_agent = true
  config.vm.box_check_update = false

  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    #vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.define "ubuntu" do |box|
    box.vm.hostname = "prax-ubuntu"
    box.vm.box = "ubuntu/trusty64"
    box.vm.provision "shell", inline: DEBIAN_SCRIPT

    box.vm.provider :lxc do |lxc, override|
      override.vm.box = "fgrehm/trusty64-lxc"
      lxc.container_name = config.vm.hostname
    end
  end

  config.vm.define "centos" do |box|
    box.vm.hostname = "prax-centos"
    #box.vm.box = ""
    box.vm.provision "shell", inline: REDHAT_SCRIPT

    box.vm.provider :lxc do |lxc, override|
      override.vm.box = "frensjan/centos-7-64-lxc"
      lxc.container_name = config.vm.hostname
    end
  end
end
