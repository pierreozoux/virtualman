module Virtualman
  module Interactive
    module Helper
      require 'fileutils'
      require 'erb'

      extend self

      def choose source
        
        list = Array.new
        self.configuration.options[source].each do |option|
          list << option["name"]
        end
        list << "exit"

        choice = Menu.unic_run(list)

        exit 0 if choice == "exit"

        self.configuration.options[source].each_with_index do |option,index|
          if option["name"] == choice
            return self.configuration.options[source][index]
          end
        end

      end

      #Source can be either source_vms or clonned_vms
      def choose_vm source
        vm_choice = choose source
        return Vm.new("#{vm_choice["name"]}")
         
      end

      def clone_vm
        puts "----Clone_VM----"
        puts "Which VM do you want to clone?"

        vm_choice = choose "source_vms"
        vm_to_clone = Vm.new("#{vm_choice["name"]}")

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
            return false
          end

          vm.manage("startvm", option)

          Kernel.print "Waiting for the VM to get an IP"
          while !vm.ip
            Kernel.print "."
            Kernel.sleep (1)
          end
          Kernel.print "\n"
        end

        return vm.running?
      end

      

      def check_chmod_script
        script = "/Applications/VirtualBox.app/Contents/MacOS/VBoxAutostartDarwin.sh"
        permission = Kernel.sprintf("%o", File.world_readable?(script) )
        if permission != "744"
          puts "Changing file permission of #{script}, to allow it to be executable"
          puts "Thanks to provide your admin password."
          File.chmod(0744, script)
        end
      end

      def integrate_template filename, path, template_string, *variables
        template = ERB.new(template_string, 0, "%<>")

        templated = template.result(binding)

        File.open("/tmp/#{filename}", 'w') { |file| file.write(templated) }

        if File.exist?(path+filename)
          diff = `diff #{path}#{filename} /tmp/#{filename}`
          result = $?
          if result != 0
            puts "We are trying to install the previous file but there are differences"
            puts "here are the differences"
            puts "#{diff}"
            puts "Do you want to override the original?"
            puts "yes/[no]"

            answer = Menu.ask

            if answer != "yes"
              return false
            end
          else
            return true
          end
        end

        puts "Installing the file #{path}#{filename}..."
        puts "Please povide your password :"

        output = `sudo cp /tmp/#{filename} #{path}#{filename}`
        result = $?
        if result == 0
          return true
        else
          Kernel.abort(output)
        end
      end

      def check_plist_file
        puts "Checking plist file..."
        plist_file = "org.virtualbox.vboxautostart.plist"
        plist_path = "/Library/LaunchDaemons/"

        plist_template = %q{
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Disabled</key>
      <false/>
      <key>KeepAlive</key>
      <false/>
      <key>Label</key>
      <string>org.virtualbox.vboxautostart</string>
      <key>ProgramArguments</key>
      <array>
        <string>/Applications/VirtualBox.app/Contents/MacOS/VBoxAutostartDarwin.sh</string>
        <string>--start</string>
        <string>/etc/vbox/autostart.cfg</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>debug</key>
      <true/>
    </dict>
    </plist>
    }    

        if self.integrate_template(plist_file, plist_path, plist_template)
          puts "loading the plist file"
          puts "Thanks to provide your admin password."
          `sudo launchctl load #{plist_path}#{plist_file}`
        end
      end


      def check_conf_file
        puts "Checking conf file..."
        conf_file = "autostart.cfg"
        conf_path = "/etc/vbox/"

        conf_template = %q{
    # Default policy is to deny starting a VM, the other option is "allow".
    default_policy = deny

    # <%= variables[0] %> is allowed to start virtual machines but starting them
    # will be delayed for 10 seconds
    <%= variables[0] %> = {
        allow = true
        startup_delay = 10
    }
    }.gsub(/^  /, '')

        username = `whoami`.strip

        integrate_template(conf_file, conf_path, conf_template, username)
      end

      def init_bootify

        #check plist file
    		check_plist_file

    		#Check chmod of the bash script
        check_chmod_script

    		#Check the conf file
        check_conf_file

    	end
    end
  end
end
