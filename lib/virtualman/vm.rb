module Virtualman
  # Implement a way to interact with the VirtualBox command line tool.
  # Each #Vm is a Class that contains the #name of the VM. With that 
  # name you can then interact with it through VBoxManage for example

  class Vm

    # This attribute contains the name of the VM in VirtualBox.
    attr_reader :name

    # A #Vm is just described by it's name.
    # *type is for further needs
    def initialize(vm_name, *type)
    	@name = vm_name
    end

    # A general method to interact with the VM.
    # action is the kind of action to request to VBoxManage
    # *param is a list of options
    def manage(action, *param)
      #puts "VBoxManage #{action} #{@name} #{param.join(" ")}"
      output = `VBoxManage #{action} \"#{@name}\" #{param.join(" ")} 2>&1`
      if $?.exitstatus != 0
        Kernel.abort(output)
      else
        return output
      end
    end

    # Returns a boolean whether the VM is running or not
    def running?
      return !self.manage("showvminfo").split("\n").grep(/running/).empty?
    end

    # return the ip of the VM if it is running. O if it is not or if the ip is not correct.
    def ip
      if self.running?
        ip = self.manage("guestproperty enumerate").split("\n").grep(/IP/)[0].split(",")[1].sub(/^ value: /, '')
        if ip.match /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/
          return ip
        else
          return false
        end
      else
        puts "The VM is not running, cannot determine IP"
        return false
      end
    end

    # A method to stop properly a vm
    # It assumes that you can access to the VM with root and ssh_keys
    def stop!
      if self.running?
        `ssh root@#{self.ip} "shutdown -h now"`
        print "Waiting for complete shutdown of #{self.name}"
        while self.running?
          print "."
          sleep (1)
        end
        sleep (5)
        print("\n")
      end
    end
  end
end
