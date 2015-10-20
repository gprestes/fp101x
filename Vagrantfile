# -*- mode: ruby -*-
# vi: set ft=ruby :

# first: find the local settings file.  Refer to the file for specifics.
# if it doesn't exist, create from the default.
require 'yaml'

VAGRANT_DIR   = File.dirname(__FILE__)
PROVIDER_DIR  = 'provisioning'
yml_file  = File.join(VAGRANT_DIR, PROVIDER_DIR, 'vagrant.yml')
unless File.exist?(yml_file)
  example = File.join(PROVIDER_DIR, 'vagrant.yml.example')
  FileUtils.cp(example, yml_file)
end
settings = YAML.load_file yml_file

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box  = 'ubuntu/trusty64'

  # http://stackoverflow.com/questions/17845637/vagrant-default-name
  config.vm.define 'fp101x'

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # port 3000 == rails
  config.vm.network 'forwarded_port', guest: 3000, host: 3000

  # private network required for NFS to work
  # NFS required for Rails to perform acceptably
  # config.vm.network       "private_network", type: "dhcp"
  config.vm.network 'private_network', ip: '192.168.12.22'
  # disable default share because it hoses our /vagrant/fp101x under 1.6
  config.vm.synced_folder '.', '/vagrant', disabled: true

  settings['folders'].each do |host, guest|
    host_path = File.join(VAGRANT_DIR, host)
    config.vm.synced_folder host_path, guest, type: 'nfs'
  end

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

  config.vm.provider 'virtualbox' do |vb|
    # For recognized OSs, use all CPUs
    case RbConfig::CONFIG['host_os']
    when /darwin/
      vb.cpus = `sysctl -n hw.ncpu`.to_i
    when /linux/
      vb.cpus = `nproc`.to_i
    end
    vb.memory = '2048'
  end

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end
  settings['provisioners'].each do |script|
    full_path = File.join(VAGRANT_DIR, script)
    config.vm.provision 'shell', privileged: false, path: full_path
  end
end

