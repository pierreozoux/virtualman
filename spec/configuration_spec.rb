require 'spec_helper'

describe Virtualman::Interactive::Configuration do

	before :each do
		create_fake_confile
		STDOUT.stub!(:puts)
		@vm_cloned = double(Virtualman::Vm)
		@vm_cloned.stub!(:name).and_return("added_vm")

		@config = Virtualman::Interactive::Configuration.new
	end

	describe "#new" do
		it "should return the right path" do
			@config.filepath.should eql "/tmp/.virtualman.rc.yaml"
		end

		it "should return the right array of options" do
			@config.options["source_vms"][0]["name"].should eql "Debian"
			@config.options["source_vms"][0]["snapshot"].should eql "test with space"
			@config.options["source_vms"][1]["name"].should eql "2nd vm"
			@config.options["role_path"].should eql "http://role/path/"
			@config.options["cookbook_path"].should eql "/cookbook/path"
			@config.options["roles"][0]["name"].should eql "role0"
			@config.options["roles"][1]["name"].should eql "role1"
		end

		it "should abort if no config file" do
			File.delete("/tmp/.virtualman.rc.yaml")
			STDERR.stub!(:puts)

			Kernel.should_receive(:abort).with("No configuration file found here ~/.vm_to_clone.rc.yaml")
			@config = Virtualman::Interactive::Configuration.new
		end
		
	end

	describe "#record_conf" do
		before do
			File.delete("/tmp/.virtualman.rc.yaml")
		end

		it "should create the good conf file from options" do
			@config.record_conf("")
			@recreated_config = Virtualman::Interactive::Configuration.new
			@recreated_config.options.should eql @config.options
		end
	end

	describe "#add_cloned_vm" do

		it "should create the Hash cloned_vms" do
			@config.options["cloned_vms"].should be nil
			@config.add_cloned_vm(@vm_cloned)
			@config.options["cloned_vms"].any?.should be true
			@config.options["cloned_vms"][0]["name"].should eql "added_vm"
		end

		it "should add the vm_cloned" do
			@config.add_cloned_vm(@vm_cloned)

			@config.options["cloned_vms"].should_not be nil
			@config.add_cloned_vm(@vm_cloned)
			@config.options["cloned_vms"][1]["name"].should eql "added_vm"
		end
	end

	describe "#delete_cloned_vm" do
		before do
			@config.add_cloned_vm(@vm_cloned)
		end

		it "should delete the vm" do
			@config.options["cloned_vms"][0]["name"].should eql "added_vm"
			@config.delete_cloned_vm(@vm_cloned)
			@config.options["cloned_vms"][0].should be nil
		end
	end
end