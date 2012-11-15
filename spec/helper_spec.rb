require 'spec_helper'

describe Virtualman::Interactive::Helper do
	before :each do
		STDOUT.stub!(:puts)
		create_fake_confile
		@repl = Virtualman::Interactive::REPL.new
	end

	describe "#choose" do
		it "should return the right VM" do
			Virtualman::Interactive::Menu.should_receive(:unic_run).with(["Debian","2nd vm","exit"]).and_return("Debian","exit")
			@repl.choose("source_vms").should eql({"name" => "Debian", "snapshot" => "test with space"})
			lambda {@repl.choose("source_vms")}.should raise_error SystemExit
		end
		it "should return the right role" do
			Virtualman::Interactive::Menu.should_receive(:unic_run).with(["role0","role1","exit"]).and_return("role0")
			@repl.choose("roles").should eql({"name" => "role0"})
		end

	end

	describe "#choose_vm" do
		before do
			Virtualman::Interactive::Menu.should_receive(:unic_run).with(["Debian","2nd vm","exit"]).and_return("Debian")
		end

		it "should return the right VM" do
			vm_choosed = @repl.choose_vm "source_vms"
			vm_choosed.should be_an_instance_of Virtualman::Vm
			vm_choosed.name.should eql "Debian"
		end
	end

	describe "#clone_vm" do
		before do 
			Virtualman::Interactive::Menu.should_receive(:unic_run).with(["Debian","2nd vm","exit"]).and_return("Debian")
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("Clone")
			Virtualman::Vm.any_instance.should_receive(:manage).with("clonevm", "--snapshot \"test with space\" --name \"Clone\" --register").and_return(1)
		end

		it "shoudl properly clone a VM" do
			cloned_vm = @repl.clone_vm
			cloned_vm.should be_an_instance_of Virtualman::Vm
			cloned_vm.name.should eql "Clone"
		end
	end

	describe "#start_vm" do
		before do

			Virtualman::Vm.any_instance.should_receive(:ip).and_return(false,false,true,false,false,true)
			Virtualman::Vm.any_instance.should_receive(:running?).and_return(false,true,false,true,false)
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("headless","yes","blabla")
			Virtualman::Vm.any_instance.should_receive(:manage).with("startvm", "--type headless")
			Virtualman::Vm.any_instance.should_receive(:manage).with("startvm", "")
			Kernel.should_receive(:print).with(any_args()).at_least(:once)
			Kernel.should_receive(:sleep).at_least(:once)
		end

		it "should start the vm properly or not." do
			vm = Virtualman::Vm.new("2test")
			@repl.start_vm(vm).should eql true
			@repl.start_vm(vm).should eql true
			@repl.start_vm(vm).should eql false
		end

	end


	describe "#check_chmod_script" do

		before do
			Kernel.should_receive(:sprintf).and_return("533","744")
			File.should_receive(:chmod)
		end

		it "verify the mod of the script" do
			@repl.check_chmod_script
			@repl.check_chmod_script
		end
	end

	describe "#integrate_template" do
		before do
			@finename = "template"
			@path = "/tmp/dirtest/"
			@template_string = "<%= variables[0] %>"
			@variable = "test"
			FileUtils.mkdir(@path)
			Virtualman::Interactive::Menu.should_receive(:ask).and_return("no","yes")
			#FileUtils.should_receive(:cp).exactly(3).times

		end

		it "should create a template file" do
			@repl.integrate_template(@finename, @path, @template_string, @variable).should eql true
			File.readlines("/tmp/dirtest/template").grep(/test/).should eql ["test"]

			Kernel.system('echo blabla > /tmp/dirtest/template')
			@repl.integrate_template(@finename, @path, @template_string, @variable).should eql false

			@repl.integrate_template(@finename, @path, @template_string, @variable).should eql true

			@repl.integrate_template(@finename, @path, @template_string, @variable).should eql true

			Kernel.should_receive(:abort).once
			@repl.integrate_template(@finename, "abort", @template_string, @variable)
		end

		after do
			FileUtils.rm(@path+@finename)
			Dir.delete(@path)
			FileUtils.rm("/tmp/"+@finename)
		end

	end

	describe "check_plist_file" do
		before do
			Virtualman::Interactive::REPL.any_instance.should_receive(:integrate_template).and_return(false,true)

			Virtualman::Interactive::REPL.any_instance.should_receive(:`).once
		end

		it "should check the plist file" do
			@repl.check_plist_file
			@repl.check_plist_file
		end
	end

	describe "check_conf_file" do
		before do
			Virtualman::Interactive::REPL.any_instance.should_receive(:integrate_template).and_return(true)
		end

		it "should check the plist file" do
			@repl.check_conf_file
		end
	end

end