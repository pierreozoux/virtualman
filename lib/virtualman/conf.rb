require 'yaml'

CONFIG_FILE = File.join(ENV['HOME'],'.virtualman.rc.yaml') 

def load_conf
	if File.exists? CONFIG_FILE
	  config_options = YAML.load_file(CONFIG_FILE)
	else
		STDERR.puts "No configuration file found here ~/.vm_to_clone.rc.yaml"
		STDERR.puts "Config file example:"
		STDERR.puts "---"
		STDERR.puts "source_vm:"
		STDERR.puts " - name: 			Debian"
		STDERR.puts "   snapshot: 	ready to clone!"
		STDERR.puts " - name: 			Gentoo"
		STDERR.puts "   snapshot: 	almost ready"
		STDERR.puts "role_path: http://path/to/your/role/fodler"
		STDERR.puts "cookbook_path: http://path/to/your/cookbooks.tar.gz"
		STDERR.puts "roles:"
		STDERR.puts "- devtest"
		STDERR.puts "- devtest_jenkins"
		STDERR.puts "- build_pkg_devtest_jenkins"
	end
	return config_options
end

def record_conf(vm_cloned, *param)
	conf = load_conf()

	if param[0] == "delete"
		verb = "deleted"
		conf["cloned_vms"].reject!{|vm| vm == {"name" => vm_cloned.name} }
	else
		verb = "saved"

		if conf["cloned_vms"]
			conf["cloned_vms"] << {"name" => vm_cloned.name}
		else
			conf.merge!({"cloned_vms" => {"name" => vm_cloned.name}})
		end
	end

	File.open(CONFIG_FILE, "w") {|f| f.write(conf.to_yaml) }
	puts "VM #{vm_cloned.name} #{verb} in your configuration file"

end
