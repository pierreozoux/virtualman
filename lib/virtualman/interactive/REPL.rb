module Virtualman
	module Interactive
		class REPL
			attr_reader :configuration

			include Virtualman::Interactive::Helper

	    def initialize
	      @configuration = Virtualman::Interactive::Configuration.new
	    end

			def clone
				cloned_vm = self.clone_vm
				self.start_vm(cloned_vm)
				self.configuration.add_cloned_vm(cloned_vm)
			end

			def cook
				puts "----Cook a clone!----"
				puts "Which VM do you want to cook?"
				role_path = self.configuration.options["role_path"]
				cookbook_path = self.configuration.options["cookbook_path"]

				selected_vm = self.choose_vm "cloned_vms"

				puts "Which role do you want to give?"

				role = self.choose "roles"

				user="root"

				if self.start_vm(selected_vm)
					cmd = "ssh #{user}@#{selected_vm.ip} '/usr/local/bin/chef-solo -j #{role_path}#{role["name"]}.json -r #{cookbook_path}'"
					puts cmd
					Kernel.system(cmd)
				end

				puts "Thanks!"
			end

			def ssh
				puts "----SSH to cloned VM----"
				puts "Which VM do you want to ssh?"

				selected_vm = self.choose_vm "cloned_vms"

				puts "With which user? [root]"
				user = Menu.ask

				if user.empty?
					user = "root"
				end

				if self.start_vm(selected_vm)
					cmd = "ssh #{user}@#{selected_vm.ip}"
					Kernel.exec(cmd)
				end	
			end

			def delete
				puts "----Delete a cloned VM----"
				puts "Which VM delete?"

				selected_vm = self.choose_vm "cloned_vms"

				puts "!!YOU ARE ABOUT TO DELETE PEMANENTLY DELETE #{selected_vm.name}!!"
				puts "Are you sure? (yes/[no])"

				choice = Menu.ask

				if choice == "yes"
					selected_vm.stop!

					selected_vm.manage("unregistervm","--delete")

					self.configuration.delete_cloned_vm(selected_vm)
				else
					puts "VM not deleted!"
				end
			end

			def add
				puts "----Add a VM----"
				puts "Give the path of the OVA file you want to add"
				puts "(An OVA file represents a Virtual Machine)"

				path = Menu.ask

				cmd = "VBoxManage import #{path}"
				puts cmd
				`#{cmd}`

				if $?.exitstatus == 0
					added_vm = Vm.new(File.basename("#{path}",".*"))
					self.configuration.add_cloned_vm(added_vm)
				else
					puts "There was an error during the import"
				end
			end

			def bootify
				puts "----Start a VM at boot----"
				puts "Initializing bootify...."
				self.init_bootify
				puts "Whcih VM do you want to add to your boot sequence?"

				selected_vm = self.choose_vm "cloned_vms"

				puts "We need to shutdown the VM to add to the boot list."
				puts "Do you want to procedd now? (yes/[no])"

				choice = Menu.ask

				if choice == "yes"
					selected_vm.stop!
					selected_vm.manage("modifyvm", "--autostart-enabled on", "--autostart-delay 10")
					puts "#{selected_vm.name} added to your boot sequence."
					start_vm selected_vm
				end
			end

		end
	end
end
