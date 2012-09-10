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

