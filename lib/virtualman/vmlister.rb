# Create an array that contains all the #Vm from VirtualBox
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

  # Get the IP of each running vm.
  def ip
    self.each {|vm| puts vm.ip}
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