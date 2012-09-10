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

  # Returns a boolean whether the VM is running or not
  def running?
  	!`VBoxManage showvminfo #{name} | grep State | grep running`.empty?
  end

  # A general method to interact with the VM.
  # action is the kind of action to request to VBoxManage
  # *param is a list of options
  def manage(action, *param)
    puts "VBoxManage #{action} #{@name} #{param.join(" ")}"
    puts `VBoxManage #{action} #{@name} #{param.join(" ")}`
  end

  # A method to stop properly a vm
  # It assumes that you have the name of the VM on your personnal hosts file or DNS
  # It can be modified to use GuestAdditions instead
  def stop!
    $stdout.sync = true
    if self.running?
      `ssh root@#{self.name.delete "\""} "shutdown -h now"`
      puts "Waiting for complete shutdown of #{self.name}"
      while self.running?
        print "."
        sleep (1)
      end
    end

  end

  # return the ip of the VM if it is running. O if it is not.
  def ip
    if self.running?
      options = "enumerate #{self.name} | grep IP | cut -d , -f 2 | cut -d : -f 2"
      cmd_ip = "VBoxManage guestproperty #{options}"
      ip = `#{cmd_ip}`.strip
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
end
