require 'json'
require 'yaml'

Vagrant.configure("2") do |config|
	settings = YAML::load(File.read("zerocooljs.yaml"))
	config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
	config.vm.box = "zerocooljs/cento71Laravel"
	config.vm.hostname = "laravel.zerocooljs"
	config.vm.network :private_network, ip: settings["ip"] ||= "10.10.10.10"
	config.vm.provider "virtualbox" do |vb|
      vb.name = "zerocooljsLaravel-" + settings["name"]
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "4072"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Redhat_64"]
    end
	if (settings.has_key?("ports"))
      settings["ports"].each do |port|
        port["guest"] ||= port["to"]
        port["host"] ||= port["send"]
        port["protocol"] ||= "tcp"
      end
    else
      settings["ports"] = []
    end
	default_ports = {
      80   => 8000,
      443  => 44300,
      3306 => 33060
    }
	default_ports.each do |guest, host|
      unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
        config.vm.network "forwarded_port", guest: guest, host: host
      end
    end
	if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"]
      end
    end
	config.vm.provision "shell",
		inline: "rm -R /etc/httpd/sites-enabled && rm -R /etc/httpd/sites-available"
	config.vm.provision "shell",
		inline: "mkdir /etc/httpd/sites-enabled && mkdir /etc/httpd/sites-available"
	settings["sites"].each do |site|
		config.vm.provision "shell" do |s|
			s.path = "virtualhost.sh"
			s.args = [site["map"], site["to"], site["port"] ||= "80"]     
		end
    end
	if settings.include? 'authorize'
      config.vm.provision "shell" do |s|
        s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
        s.args = [File.read(File.expand_path(settings["authorize"]))]
      end
    end
    if settings.include? 'keys'
      settings["keys"].each do |key|
        config.vm.provision "shell" do |s|
          s.privileged = false
          s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
          s.args = [File.read(File.expand_path(key)), key.split('/').last]
        end
      end
    end
	if settings.include? 'folders'
      settings["folders"].each do |folder|
        mount_opts = []

        if (folder["type"] == "nfs")
            mount_opts = folder["mount_opts"] ? folder["mount_opts"] : ['actimeo=1']
        end

        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, mount_options: mount_opts
      end
    end
	if settings.has_key?("php_ide_config")
	    config.vm.provision "shell" do |s|
           s.inline = "export PHP_IDE_CONFIG=\"serverName=" + settings["php_ide_config"] + "\""
        end
    end
	config.vm.provision "shell" do |s|
      s.inline = "/usr/local/bin/composer self-update"
    end
	if File.exists? "after.sh" then
		config.vm.provision "shell", path: "after.sh"
	end
end