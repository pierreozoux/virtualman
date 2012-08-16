virtualman
==========

A simple way to manage your Virtual Box appliances.

### Usage

Install the gem

	$ gem install virtualman

Fire IRB

	$ irb

Play with your VMs :

	irb> vms=VmLister.new

	irb> vms.populate!

	=> ["\"vm1"", "\"vm2\"", "\"vm3\""]

	irb> vms.running?

	=> ["\"vm2\""]

	irb> vms.running?.backup! "/path/to/your/backup/folder"

	VBoxManage controlvm "vm2" poweroff
	0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

	VBoxManage export "vm2" -o /path/to/your/folder/vm2_20120816T1202.ova
	0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
	Successfully exported 1 machine(s).
	VBoxManage startvm "vm2" --type headless
	Waiting for VM "vm2" to power on...
	VM "vm2" has been successfully started.

Get the IP of your running VMs (need Guest Additions installed in your VMs)

	irb> vms.running?.manage "guestproperty enumerate", "| grep IP | cut -d , -f 2 | cut -d ' ' -f 3"

	VBoxManage guestproperty enumerate "vm2" | grep IP | cut -d , -f 2 | cut -d ' ' -f 3
	=>192.168.1.100

With the manage command, possibilites are endless! Enjoy it!

### Caution

Be careful with the method Vm.Lister.backup! as it will shutdown your VM and restart it after the export. I needed that to export the appliance, and then in case of failure I can import in any other VirtualBox.. If you have a better option, please let me know :)