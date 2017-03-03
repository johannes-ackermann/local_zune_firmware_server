pwd = File.dirname(File.expand_path(__FILE__))

base_vm_path = ENV.has_key?('BASE_VM_PATH') ? ENV['BASE_VM_PATH'] : pwd
vm_path = ENV.has_key?('VM_PATH') ? ENV['VM_PATH'] : pwd

require "#{base_vm_path}/ansible/ruby/deep_merge.rb"
require "#{base_vm_path}/ansible/ruby/get_vm_variables_from_ansible.rb"
require "#{base_vm_path}/ansible/ruby/which.rb"
require "#{base_vm_path}/ansible/ruby/get_ansible_version.rb"

Vagrant.require_version ">= 1.7"

required_plugins = ['vagrant-hostmanager', 'vagrant-triggers']

required_plugins.each do |plugin|
  if !Vagrant.has_plugin?(plugin)
    abort("Plugin '#{plugin}' not found. Please install it using 'vagrant plugin install #{plugin}'.")
  end
end

default_playbook_name = "playbook"
playbook_name = ENV['PLAYBOOK'] ? ENV['PLAYBOOK'] : default_playbook_name

yaml_config = get_vm_variables_from_ansible(vm_path, playbook_name)
vm_config = yaml_config["vagrant_local"]["vm"]

ENV['VAGRANT_DEFAULT_PROVIDER'] = vm_config["provider"]

def override_base_box(override, vm_config, provider)
  if vm_config.has_key?("provider_specific") &&
    vm_config["provider_specific"].has_key?(provider) &&
    vm_config["provider_specific"][provider].has_key?("base_box")

    override.vm.box = vm_config["provider_specific"][provider]["base_box"]
  end
end

def override_shared_folder(override, vm_config, provider)
  asf = vm_config["app_shared_folder"]
  sync_type = asf["sync_type"]

  if vm_config.has_key?("provider_specific") &&
    vm_config["provider_specific"].has_key?(provider) &&
    vm_config["provider_specific"][provider].has_key?("app_shared_folder") &&
    vm_config["provider_specific"][provider]["app_shared_folder"].has_key?("sync_type")

    sync_type = vm_config["provider_specific"][provider]["app_shared_folder"]["sync_type"]
  end

  if asf.has_key?("bindfs") && asf["bindfs"]
    override.vm.synced_folder asf["source"], "/mnt/asf", id: "asf", type: sync_type
  else
    override.vm.synced_folder asf["source"], asf["target"], type: sync_type
  end
end

def override_network(override, vm_config, provider)
  ip = vm_config["ip"]

  if vm_config.has_key?("provider_specific") &&
    vm_config["provider_specific"].has_key?(provider) &&
    vm_config["provider_specific"][provider].has_key?("ip")

    ip = vm_config["provider_specific"][provider]["ip"]
  end

  if ip
    override.vm.network :private_network, ip: ip
  end
end

Vagrant.configure("2") do |config|
  if defined? config_hook
    config_hook.each do |f|
      f.call(config, vm_config)
    end
  end

  if Vagrant.has_plugin?('vagrant-hostmanager')
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false
    config.hostmanager.aliases = vm_config["aliases"]
  end

  config.vm.box_check_update = false

  config.vm.provider :virtualbox do |v, override|
    v.name = vm_config["name"]
    v.customize [
      "modifyvm", :id,
      "--name", vm_config["name"],
      "--memory", vm_config["memory"],
      "--natdnshostresolver1", "on",
      "--cpus", vm_config["cpus"],
    ]

    override_base_box(override, vm_config, "virtualbox")
    override_shared_folder(override, vm_config, "virtualbox")
    override_network(override, vm_config, "virtualbox")
  end

  config.vm.provider :parallels do |v, override|
    v.name = vm_config["name"]
    v.memory = vm_config["memory"]
    v.cpus = vm_config["cpus"]
    v.optimize_power_consumption = false

    override_base_box(override, vm_config, "parallels")
    override_shared_folder(override, vm_config, "parallels")
    override_network(override, vm_config, "parallels")
  end

  config.vm.provider :lxc do |v, override|
    v.backingstore = "dir"
    override_base_box(override, vm_config, "lxc")
    override_shared_folder(override, vm_config, "lxc")
    override_network(override, vm_config, "lxc")
  end

  config.vm.box = vm_config["base_box"]
  config.vm.hostname = vm_config["hostname"]

  config.ssh.forward_agent = true
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  if ENV.has_key?('ANSIBLE_TAGS') && !ENV['ANSIBLE_TAGS'].empty?
    ansible_tags = ENV['ANSIBLE_TAGS'].split(',')
  else
    ansible_tags = []
  end

  if which('ansible-playbook') && Gem::Version.new(get_ansible_version()) >= Gem::Version.new('2.0.0')
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "#{vm_path}/ansible/#{playbook_name}.yml"
      ansible.tags = ansible_tags.empty? ? nil : ansible_tags
    end
    config.vm.provision "ansible", run: "always" do |ansible|
      ansible.playbook = "#{vm_path}/ansible/#{playbook_name}.yml"
      ansible.tags = ["internal_always"]
    end
  else
    config.vm.provision :shell,
      keep_color: true,
      path: "#{base_vm_path}/ansible/provision.sh",
      args: [playbook_name] + (ansible_tags.empty? ? [] : [ansible_tags.join(',')])
    config.vm.provision :shell,
      keep_color: true,
      path: "#{base_vm_path}/ansible/provision.sh",
      args: [playbook_name, "internal_always"],
      run: "always"
  end
end

if ENV["CONFIG"] == "1"
  puts yaml_config.to_yaml
end
