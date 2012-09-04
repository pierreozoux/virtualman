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
end

# Create an array tht contains all the #Vm from VirtualBox
# And implement methods to play with it as a whole.
class VmLister < Array

  # Return an array with the list returned by the command "VBoxManage list vms"
  # The argument *type will be used later (to specify a remote host for instance)
  def perform_list(*type)
    vm_list = `VBoxManage list vms`.split(/\n/).collect {|e| e[/".*"/]}
    return vm_list
  end

  # Populate the array with the method perform_list
  # The argument *type will be used later (to specify a remote host for instance)
  def populate!(*type)
    self.perform_list.each {|vm| self << Vm.new(vm)}
  end

  # A simple lister
  def list
    self.each {|vm| puts "#{vm.name}"}
  end

  # This methods returns a #VmLister object but just with the running VMs of the list.
  def running?
    running_vms = VmLister.new
    self.collect {|vm| running_vms << vm if vm.running?}
    return running_vms
  end

  # A general method to interact with the VBoxManage tool
  # the block param could be useful for advanced links between your script and this class
  def manage(action, *param, &block)
    self.each do |vm|
      block_param = block.call(vm.name) if block_given?

      vm.manage(action, param, block_param)
    end
  end

  # A method to automatically export the list of VMs
  def backup!(folder)
    self.each {|vm| vm.stop!}
    sleep (5)

    self.each do |vm|
      filename = Time.now().strftime("#{vm.name.delete "\""}_%Y%m%dT%H%M")
      vm.manage("export","-o #{folder}/#{filename}.ova")
      sleep(5)
    end

    self.each {|vm| vm.manage("startvm", "--type headless")}
  end
end