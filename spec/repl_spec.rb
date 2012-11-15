require 'spec_helper'

describe Virtualman::Interactive::REPL do
	before :each do
		create_fake_confile
		@repl = Virtualman::Interactive::REPL.new
		STDOUT.stub!(:puts)
	end

	describe "#new" do
		it "should create the REPL object" do
			@repl.should_not be nil
			@repl.configuration.should be_an_instance_of Virtualman::Interactive::Configuration
			@repl.configuration.options["source_vms"][0]["name"].should eql "Debian"
		end
	end

	describe "#clone" do
		it "should clone a vm" do
			Virtualman::Interactive::REPL.any_instance.should_receive(:clone_vm).once
			Virtualman::Interactive::REPL.any_instance.should_receive(:start_vm).once
			Virtualman::Interactive::Configuration.any_instance.should_receive(:add_cloned_vm).once

			@repl.clone
		end
	end

	describe "#cook" do
		it "should cook a vm" do
			@vm = Virtualman::Vm.new("test")
			Virtualman::Interactive::REPL.any_instance.should_receive(:choose_vm).and_return(@vm)
			Virtualman::Interactive::REPL.any_instance.should_receive(:choose).and_return({"name"=>"test"})
			Virtualman::Interactive::REPL.any_instance.should_receive(:start_vm).and_return(true)
			Virtualman::Vm.any_instance.should_receive(:ip).and_return("1.1.1.1")

			Kernel.should_receive(:system).with("ssh root@1.1.1.1 '/usr/local/bin/chef-solo -j http://role/path/test.json -r /cookbook/path'")

			@repl.cook
		end
	end

	describe "#ssh" do
		before :each do
			@vm = Virtualman::Vm.new("test")
			Virtualman::Interactive::REPL.any_instance.should_receive(:choose_vm).and_return(@vm)
			Virtualman::Interactive::REPL.any_instance.should_receive(:start_vm).and_return(true)
			Virtualman::Vm.any_instance.should_receive(:ip).and_return("1.1.1.1")
		end

		it "should ssh to the right VM with root" do
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("")
			Kernel.should_receive(:exec).with("ssh root@1.1.1.1")
			@repl.ssh
		end

		it "should ssh to the right VM with blabla" do
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("blabla")
			Kernel.should_receive(:exec).with("ssh blabla@1.1.1.1")
			@repl.ssh
		end
	end

	describe "#delete" do
		before :each do
			@vm = Virtualman::Vm.new("test")
			Virtualman::Interactive::REPL.any_instance.should_receive(:choose_vm).and_return(@vm)
		end

		it "should delete the VM when asked" do
			Virtualman::Vm.any_instance.should_receive(:stop!)
			Virtualman::Vm.any_instance.should_receive(:manage).with("unregistervm","--delete")
			Virtualman::Interactive::Configuration.any_instance.should_receive(:delete_cloned_vm)
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("yes")
			@repl.delete
		end

		it "should not delete the VM when the answer is different than yes" do 
			Virtualman::Vm.any_instance.should_not_receive(:stop!)
			Virtualman::Vm.any_instance.should_not_receive(:manage).with("unregistervm","--delete")
			Virtualman::Interactive::Configuration.any_instance.should_not_receive(:delete_cloned_vm)
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("blabla")
			@repl.delete
		end

	end


	describe "#add" do

		it "should add the right VM" do
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("/a/right/path/to/vm.ova")
			Virtualman::Interactive::Configuration.any_instance.should_receive(:add_cloned_vm) do |arg|
  			arg.name.should eql "vm"
			end
			@repl.add

		end

		it "should not add the VM in case of error" do
			Virtualman::Interactive::Configuration.any_instance.should_not_receive(:add_cloned_vm)
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("a wrong path tp abort")
			@repl.add
		end

	end

	describe "#bootify" do
		
		it "should add the vm to th boot sequence" do
			@vm = Virtualman::Vm.new("test")
			Virtualman::Interactive::REPL.any_instance.should_receive(:init_bootify)
			Virtualman::Interactive::REPL.any_instance.should_receive(:choose_vm).and_return(@vm)
			Virtualman::Vm.any_instance.should_receive(:manage)
			Virtualman::Vm.any_instance.should_receive(:stop!)
			Virtualman::Interactive::REPL.any_instance.should_receive(:start_vm)
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("yes")

			@repl.bootify
		end

	end

end
