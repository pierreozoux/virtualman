virtualman
==========

A simple way to manage your Virtual Box appliances.

### Usage

Put this in your script (virtual.rb)
	
	require 'virtualman'

	vms=VmLister.new
	vms.populate!

	puts "List of Vms"
	vms.list

	puts "List of running Vms"
	vms.running?.list

	#Get the IP of your running VMs (need Guest Additions installed in your VMs)

	vms.ip

	vms.running?.backup! "/path/to/your/backup/folder"

And enjoy it!

	$ gem install virtualman
	$ ruby virtual.rb

	List of Vms
	"vm1"
	"vm2"
	"vm3"

	List of running Vms
	"vm2"

	VBoxManage guestproperty enumerate "vm2" | grep IP | cut -d , -f 2 | cut -d ' ' -f 3
	192.168.1.100

	VBoxManage controlvm "vm2" poweroff
	0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

	VBoxManage export "vm2" -o /path/to/your/folder/vm2_20120816T1202.ova
	0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
	Successfully exported 1 machine(s).
	VBoxManage startvm "vm2" --type headless
	Waiting for VM "vm2" to power on...
	VM "vm2" has been successfully started.

With the manage method, possibilites are endless! Enjoy it!

### Caution

Be careful with the method VmLister.backup! as it will shutdown your VM and restart it after the export. I needed that to export the appliance, and then in case of failure I can import in any other VirtualBox.. If you have a better option, please let me know :)