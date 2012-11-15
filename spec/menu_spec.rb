require 'spec_helper'

describe Virtualman::Interactive::Menu do
	before :each do
		@lines=["clone","cook","ssh"]
		Virtualman::Interactive::Menu.stub!(:print)
	end

	describe "#unic_prompt" do
		it "prints correctly" do
			STDOUT.should_receive(:puts).with("1. clone")
			STDOUT.should_receive(:puts).with("2. cook")
			STDOUT.should_receive(:puts).with("3. ssh")

			Virtualman::Interactive::Menu.unic_prompt(@lines)
		end
	end

	describe "#unic_answer" do
		it "chooses correctly" do
			Virtualman::Interactive::Menu.unic_answer(@lines,"1").should eql "clone"
			Virtualman::Interactive::Menu.unic_answer(@lines,"2").should eql "cook"
			Virtualman::Interactive::Menu.unic_answer(@lines,"3").should eql "ssh"
		end
		it "aborts correctly for a string" do
			Kernel.should_receive(:abort).with("blabla is an invalid choice.")
			
			Virtualman::Interactive::Menu.unic_answer(@lines,"blabla")
		end
		it "aborts correctly for a wrong number" do
			Kernel.should_receive(:abort).with("4 is an invalid choice.")
			
			Virtualman::Interactive::Menu.unic_answer(@lines,"4")
		end
	end

	describe "#unic_run" do
		before do
			STDOUT.stub!(:puts)
		end
		it "hould return the right choice" do
			Kernel.should_receive(:abort).with("4 is an invalid choice.")
			Kernel.should_receive(:abort).with("blabla is an invalid choice.")
			STDIN.should_receive(:gets).and_return("1","2","3","4","blabla")
			Virtualman::Interactive::Menu.unic_run(@lines).should eql "clone"
			Virtualman::Interactive::Menu.unic_run(@lines).should eql "cook"
			Virtualman::Interactive::Menu.unic_run(@lines).should eql "ssh"
			Virtualman::Interactive::Menu.unic_run(@lines)
			Virtualman::Interactive::Menu.unic_run(@lines)
		end
	end

end
