require 'spec_helper'

describe Virtualman::Vm do
	before :each do
		@vm_test = Virtualman::Vm.new "vm_test"
		@vm_running = Virtualman::Vm.new "vm_running"
		@vm_not_running = Virtualman::Vm.new "vm_not_running"

		@VBrunning = "blabla\nhbivbr\nrunning"

		@vm_running.stub(:manage).with("showvminfo").and_return(@VBrunning,@VBrunning,@VBrunning,"blabla\nhbivbr\npowered off")

		@vm_running.stub(:manage).with("guestproperty enumerate").and_return("blabla\nhbivbr\nName: /VirtualBox/GuestInfo/Net/0/V4/IP, value: 192.168.1.1, timestamp: 135229")			
	  @vm_not_running.stub(:manage).with("showvminfo").and_return("blabla\nhbivbr\npowered off")

	  $stdout = StringIO.new
	end

	describe "#running" do
		it "returns the correct status" do
			@vm_running.running?.should eql true
			@vm_not_running.running?.should eql false
		end
	end

	describe "#ip" do
		it "returns an ip if the VM is running" do
			
		  @vm_running.ip.should eql "192.168.1.1"
		end
		it "returns 0 if the VM is not running" do
		  @vm_not_running.ip.should eql false
		end
	end

	describe "#stop!" do
		it "stops the vm if it is running" do
			@vm_running.should_receive(:running?).and_return(true, true,false)
			Virtualman::Vm.any_instance.should_receive(:`).with("ssh root@192.168.1.1 \"shutdown -h now\"")
			@vm_running.stop!
		end

		it "doesn't stop the vm if it is running" do
			@vm_running.should_receive(:running?).and_return(false)
			Virtualman::Vm.any_instance.should_not_receive(:`)
			@vm_running.stop!
		end
	end

end
