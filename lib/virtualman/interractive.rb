require 'open3'
require 'erb'

module Interractive
include Configuration

	def choosed_option(array,choice,attribute_to_check)
		array.each_with_index do |option,index|
			if option[attribute_to_check] == choice
				return array[index]
			end
		end
	end

	def choose options, *attribute_to_check
		options_array = Configuration.load_conf[options]
		if attribute_to_check.empty?
			return Menu.unic_run(options_array)
		else
			list = Array.new
			options_array.each do |option|
				list << option[attribute_to_check[0]]
			end
			list << "exit"

			choice = Menu.unic_run(list)

			exit 0 if choice == "exit"

			return choosed_option(options_array,choice,attribute_to_check[0])
		end
	end

	def choose_vm source
		vm_choice = choose source, "name"
		vm_choosed = Vm.new("\"#{vm_choice["name"]}\"")
		return vm_choosed
	end

	def clone_vm
		puts "----Clone_VM----"
		puts "Which VM do you want to clone?"

		vm_choice = choose "source_vms", "name"
		vm_to_clone = Vm.new("\"#{vm_choice["name"]}\"")

		puts "How do you want to name your freshly spawned VM?"
		vm_name = Menu.ask

		options = "--snapshot \"#{vm_choice["snapshot"]}\" --name \"#{vm_name}\" --register"
		vm_to_clone.manage("clonevm", options)

		vm_cloned = Vm.new(vm_name)
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

		selected_vm = choose_vm "cloned_vms"

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

	def ssh
		puts "----SSH to cloned VM----"
		puts "Which VM do you want to ssh?"

		selected_vm = choose_vm "cloned_vms"

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

	def delete
		puts "----Delete a cloned VM----"
		puts "Which VM delete?"

		selected_vm = choose_vm "cloned_vms"

		puts "!!YOU ARE ABOUT TO DELETE PEMANENTLY DELETE #{selected_vm.name}!!"
		puts "Are you sure? (yes/[no])"

		choice = Menu.ask

		if choice == "yes"
			selected_vm.stop!

			selected_vm.manage("unregistervm","--delete")

			record_conf(selected_vm, "delete")
		end
	end

	def add
		puts "----Add a VM----"
		puts "Give the path of the OVA file you want to add"
		puts "(An OVA file represents a Virtual Machine)"

		path = Menu.ask

		cmd = "VBoxManage import #{path}"
		p cmd
		system(cmd)

		if $?.exitstatus == 0
			added_vm = Vm.new(File.basename("#{path}",".*"))
			record_conf(added_vm)
		end
	end

	def bootify
		puts "----Start a VM at boot----"
		puts "Whcih VM do you want to add to your boot sequence?"

		selected_vm = choose_vm "cloned_vms"

		# Create template.
		template_plist = %q{
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>org.virtualman.<%= vmname %></string>
  <key>ProgramArguments</key>
  <array>
    <string>VBoxManage</string>
    <string>startvm</string>
    <string><%= vmname %></string>
    <string>--type</string>
    <string>headless</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>UserName</key>
  <string><%= username %></string>
  <key>debug</key>
  <true/>
</dict>
</plist>
		}.gsub(/^  /, '')

		plist = ERB.new(template_plist, 0, "%<>")

		# Set up template data.

		vmname = selected_vm.name.gsub(/\"/,'')
		username = `whoami`.strip

		# Produce result.

		vm_plist = plist.result(binding)

		plist_filename = "org.virtualman.#{vmname}.plist"
		tmp_file = "/tmp/#{plist_filename}"
		path = "/Library/LaunchDaemons/"

		File.open(tmp_file, 'w') { |file| file.write(vm_plist) }

		`sudo cp #{tmp_file} #{path};sudo launchctl load #{path}#{plist_filename}`

		puts "#{vmname} added to your boot sequence."
	end

end
