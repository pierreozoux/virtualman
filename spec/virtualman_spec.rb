require 'spec_helper'

describe Vm do
	before :each do
		@vm_test = Vm.new "vm_test"

		@vm_running = double('vm_running')
		@vm_running.stub(:running?).and_return(true)

		@vm_not_running = double('vm_not_running')
		@vm_not_running.stub(:running?).and_return(false)
	end

	describe "#new" do
		it "takes one parameter and return a Vm object" do
			@vm_test.should be_an_instance_of Vm
		end
	end

	describe "#name" do
		it "returns the correct name" do
			@vm_test.name.should eql "vm_test"
		end
	end

	describe "#running" do
		it "returns the correct status" do
			@vm_running.running?.should eql true
			@vm_not_running.running?.should eql false
		end
	end
end

describe VmLister do
	before :each do
		@vm_list = VmLister.new

		@vm_list.stub(:perform_list).and_return(["vm_running","vm_not_running"])

		@vm_list.populate!

		@vm_list[0].stub(:running?).and_return(true)
		@vm_list[1].stub(:running?).and_return(false)


	end

	describe "#new" do
		it "returns a VmLister object" do
			@vm_list.should be_an_instance_of VmLister
		end
	end

	describe "#populate" do
		it "contains 2 Vm objects with the right name" do
			@vm_list[0].should be_an_instance_of Vm
			@vm_list[1].should be_an_instance_of Vm

			@vm_list[0].name.should eql "vm_running"
			@vm_list[1].name.should eql "vm_not_running"
		end
	end

	describe "#running?" do
		it "return a VmLister object with 1 Vm" do
			vms_running = @vm_list.running?
			vms_running[0].should be_an_instance_of Vm
			vms_running[1].should eql nil
		end
	end


end
