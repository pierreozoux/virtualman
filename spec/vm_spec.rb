require 'spec_helper'

describe Virtualman::Vm do

	before do
		@vm_test = Virtualman::Vm.new "vm test"
		
		#$stdout = StringIO.new	
	end

	describe "#new" do
		it "takes one parameter and return a Vm object" do
			@vm_test.should be_an_instance_of Virtualman::Vm
		end
	end

	describe "#name" do
		it "returns the correct name" do
			@vm_test.name.should eql "vm test"
		end
	end

	describe "#manage" do
		it "returns a well formatted command" do
			@vm_test.manage("guestproperty enumerate").strip.should eql "VBoxManage guestproperty enumerate \"vm test\"  2>&1"
			@vm_test.manage("modifyvm","--test1","--test2").should eql "VBoxManage modifyvm \"vm test\" --test1 --test2 2>&1"
			Kernel.should_receive(:abort)
			@vm_test.manage("abort")
		end
	end

end
