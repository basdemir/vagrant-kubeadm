VAGRANTFILE_API_VERSION = "2"

$k8s_count=3
$k8s_memory=4096
$k8s_cpus=2
$startingIp=50

def hostPrefix()
  return "k8s-0"
end

def ipPrefix()
  return "192.168.104."
end

def workerIP(num)
  return "#{ipPrefix()}#{num+$startingIp}"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false

  config.vm.box = "bento/ubuntu-18.04"
  (1..$k8s_count).each do |i|
    config.vm.define vm_name = "#{hostPrefix()}%d" % i do |node|
      node.vm.network :private_network, :ip => "#{workerIP(i)}"
      node.vm.hostname = vm_name
      node.vm.provider "virtualbox" do |v|
        if i == 1                       
          v.memory = 4096
          v.cpus = $k8s_cpus
        elsif i == 2                       
          v.memory = 4096
          v.cpus = $k8s_cpus
        else                            
          v.memory = $k8s_memory
          v.cpus = $k8s_cpus
        end                             
      end
      node.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y zsh nano vim git mlocate ldap-utils gnutls-bin ssl-cert tmux

      systemctl stop ufw
      systemctl disable ufw
      SHELL
      node.vm.provision :shell, :path => "vagrantscripts/grubupdate.sh"
      node.vm.provision :shell, :path => "vagrantscripts/bootstrap.sh", :args => "#{workerIP(i)}"
      node.vm.provision :shell, :path => "vagrantscripts/setLocale.sh"
      # Change the vagrant user's shell to use zsh
      node.vm.provision :shell, inline: "chsh -s /usr/bin/zsh vagrant"
      node.vm.provision :shell, :path => "vagrantscripts/shellVimExtras.sh"
      node.vm.provision :shell, :path => "vagrantscripts/shellVimExtras.sh", privileged: false
      # You can disable above scripts if you use custom VM image which include necessary installations.
      node.vm.provision :shell, :path => "vagrantscripts/minimal.sh", :args => ["#{workerIP(i)}", "#$startingIp", "#$k8s_count", "#{ipPrefix()}", "#{hostPrefix()}"]
    end
  end
end
