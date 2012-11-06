virtualman
==========

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/pierreozoux/virtualman)

A simple way to manage your Virtual Box appliances.

## Usage

### From command line!

	$ virtualman
	----VirtualMan----
	Please select an action to do with your VM.
	1. clone
	2. cook
	3. ssh
	4. add
	5. delete
	6. bootify
	7. exit

	Specify your choice
	Choose: 

This interactive mode allows you to manage your VM in an easy way. Configure it (as debcribed bellow) and enjoy it! Clone a VM, cook it, access it with ssh, add your VM to your boot sequence (MacOS)... And even more to with your ideas!


#### Config file 
in your home path : (.virtualman.rc.yaml)

	source_vm:
	- name: 			Debian
	  snapshot: 	ready to clone!
	- name: 			Gentoo
	  snapshot: 	almost ready
	role_path: http://path/to/your/role/fodler
	cookbook_path: http://path/to/your/cookbooks.tar.gz
	roles:
	- devtest
	- jenkins
	- build_pkg

### From your ruby script

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

With the manage method, possibilites are endless! Enjoy it!

## Caution

Be careful with the method VmLister.backup! as it will shutdown your VM and restart it after the export. I needed that to export the appliance, and then in case of failure I can import in any other VirtualBox.. If you have a better option, please let me know :)

## To Do

* Do an automated Config file.
* Configure a White list (of all VM) for clone.
* Configure a black list (of all VM) for ssh.
* Add the possibility to use knife or chef-server
* Record scripts (with a monkey patch of exec command?)