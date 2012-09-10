#require 'lib/virtualman'

def choosed_vm(array,vm_name)
	array.each_with_index do |vm,index|
		if vm["name"] == vm_name
			return array[index]
		end
	end
end

def choose options *attribute_to_print
	options_array = load_conf[options]
	if attribute_to_print.empty?
		return Menu.unic_run(options_array)
	else
		list = Array.new
		options_array.each do |vm|
			list << vm[attribute_to_print]
		end
		return Menu.unic_run(list)
	end
end

def clone_vm
	puts "----Clone_VM----"
	puts "Which VM do you want to clone?"

	vm_choice = choose "source_vms" "name"

	puts "How do you want to name your freshly spawned VM?"
	vm_name = Menu.ask

	vm_to_clone_info = choosed_vm(source_vms,vm_choice)

	vm_to_clone = Vm.new("\"#{vm_to_clone_info["name"]}\"")
	options = "--snapshot '#{vm_to_clone_info["snapshot"]}' --name #{vm_name} --register"
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

	vm_name = choose "cloned_vms" "name"

	selected_vm = Vm.new(vm_name)

	puts "Which role do you want to give?"

	role = choose "roles"

	if start_vm(selected_vm)
		cmd = "ssh #{user}@#{selected_vm.ip}"
		`#{cmd}`
	end

	puts "Thanks!"
end

def ssh_cloned
	puts "----SSH to cloned VM----"
	puts "Which VM do you want to ssh?"

	vm_name = choose "cloned_vms" "name"

	selected_vm = Vm.new(choice)

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