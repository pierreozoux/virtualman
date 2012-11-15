require 'spec_helper'

describe Virtualman::VmLister do
	before :each do
		@vm_list = Virtualman::VmLister.new

		@vm_list.stub(:perform_list).and_return(["vm_running","vm_not_running"])

		@vm_list.populate!

		@vm_list[0].stub(:running?).and_return(true)
		@vm_list[1].stub(:running?).and_return(false)


	end

	describe "#new" do
		it "returns a VmLister object" do
			@vm_list.should be_an_instance_of Virtualman::VmLister
		end
	end

	describe "#populate" do
		it "contains 2 Vm objects with the right name" do
			@vm_list[0].should be_an_instance_of Virtualman::Vm
			@vm_list[1].should be_an_instance_of Virtualman::Vm

			@vm_list[0].name.should eql "vm_running"
			@vm_list[1].name.should eql "vm_not_running"
		end
	end

	describe "#running?" do
		it "returns a VmLister object with 1 Vm" do
			vms_running = @vm_list.running?
			vms_running[0].should be_an_instance_of Virtualman::Vm
			vms_running[1].should eql nil
		end
	end


end
