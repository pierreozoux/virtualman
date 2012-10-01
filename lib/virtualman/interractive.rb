require 'open3'

def choosed_option(array,choice,attribute_to_check)
	array.each_with_index do |option,index|
		if option[attribute_to_check] == choice
			return array[index]
		end
	end
end

def choose options, *attribute_to_check
	options_array = load_conf[options]
	if attribute_to_check.empty?
		return Menu.unic_run(options_array)
	else
		list = Array.new
		options_array.each do |option|
			list << option[attribute_to_check[0]]
		end
		choice = Menu.unic_run(list)
		return choosed_option(options_array,choice,attribute_to_check[0])
	end
end

def clone_vm
	puts "----Clone_VM----"
	puts "Which VM do you want to clone?"

	vm_choice = choose "source_vms", "name"
	vm_to_clone = Vm.new("\"#{vm_choice["name"]}\"")

	puts "How do you want to name your freshly spawned VM?"
	vm_name = Menu.ask

	options = "--snapshot '#{vm_choice["snapshot"]}' --name #{vm_name} --register"
	vm_to_clone.manage("clonevm", options)

	vm_cloned = Vm.new("\"#{vm_name}\"")
	return vm_cloned
end

def start_vm(vm)
	if !vm.running?
		puts "Do you want to start the VM? headless?"
		puts "(default is no)"
		puts "yes/headless/[no]"

		answer = Menu.ask

		if answer == "headless"
			option = "--type headless"
			puts "The VM is booting headless"
		elsif answer == "yes"
			option = ""
			puts "The VM is booting"
		else
			puts "The vm will not be started"
			return vm
		end

		vm.manage("startvm", option)

		print "Waiting for the VM to get an IP"
		while !vm.ip
			print "."
			sleep (1)
		end
		print "\n"
	end

	return vm.running?
end

def clone
	cloned_vm = clone_vm
	start_vm(cloned_vm)
	record_conf(cloned_vm)
end

def cook
	puts "----Cook a clone!----"
	puts "Which VM do you want to cook?"
	role_path = load_conf["role_path"]
	cookbook_path = load_conf["cookbook_path"]

	vm_choice = choose "cloned_vms", "name"

	selected_vm = Vm.new(vm_choice["name"])

	puts "Which role do you want to give?"

	role = choose "roles"

	user="root"

	if start_vm(selected_vm)
		cmd = "ssh #{user}@#{selected_vm.ip} '/usr/local/bin/chef-solo -j #{role_path}#{role}.json -r #{cookbook_path}'"
		p cmd
		system(cmd)
	end

	puts "Thanks!"
end

def ssh_cloned
	puts "----SSH to cloned VM----"
	puts "Which VM do you want to ssh?"

	vm_choice = choose "cloned_vms", "name"

	selected_vm = Vm.new(vm_choice["name"])

	puts "With which user? [root]"
	user = Menu.ask

	if user.empty?
		user = "root"
	end

	if start_vm(selected_vm)
		cmd = "ssh #{user}@#{selected_vm.ip}"
		exec (cmd)
	end	
end

def delete_clone
	puts "----Delete a cloned VM----"
	puts "Which VM delete?"

	vm_choice = choose "cloned_vms", "name"

	selected_vm = Vm.new(vm_choice["name"])

	puts "!!YOU ARE ABOUT TO DELETE PEMANENTLY DELETE #{vm_choice["name"]}!!"
	puts "Are you sure? (yes/[no])"

	choice = Menu.ask

	if choice == "yes"
		selected_vm.stop!

		selected_vm.manage("unregistervm","--delete")

		record_conf(selected_vm, "delete")
	end
end
