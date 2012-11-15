require 'yaml'

module Virtualman
	module Interactive
		class Configuration

			attr_reader :options, :filepath

			def initialize
				@filepath = File.join(ENV['HOME'],'.virtualman.rc.yaml')

				if File.exists? @filepath
				  @options = YAML.load_file(@filepath)
				else
					STDERR.puts("No configuration file found here ~/.vm_to_clone.rc.yaml")
					STDERR.puts("Thanks to create this file before continuing!")
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
					Kernel.abort("No configuration file found here ~/.vm_to_clone.rc.yaml")
				end
			end

			def record_conf(msg)
				File.open(@filepath, "w") {|f| f.write(@options.to_yaml) }
				puts "#{msg} to your configuration file"
			end

			def add_cloned_vm(vm_cloned)
				if @options["cloned_vms"] != nil
					@options["cloned_vms"] << {"name" => vm_cloned.name}
				else
					@options.merge!({"cloned_vms" => [{"name" => vm_cloned.name}]})
				end
				record_conf("VM #{vm_cloned.name} has been saved")			
			end
			
			def delete_cloned_vm(vm_cloned)
				@options["cloned_vms"].reject!{|vm| vm == {"name" => vm_cloned.name.gsub(/\"/,'')} }
				record_conf("VM #{vm_cloned.name} has been deleted")
			end

		end
	end
end
