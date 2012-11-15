require_relative "../lib/virtualman/vm"
require_relative "../lib/virtualman/vmlister"
require_relative "../lib/virtualman/interactive/menu"
require_relative "../lib/virtualman/interactive/configuration"
require_relative "../lib/virtualman/interactive/helper"
require_relative "../lib/virtualman/interactive/REPL"

require 'fileutils'
require 'yaml'
require 'stringio'

def create_fake_confile

	ENV.stub!(:[]).with('HOME').and_return("/tmp")

	conf_string= %q{---
source_vms:
- name: Debian
  snapshot: test with space
- name: 2nd vm
  snapshot: test2
role_path: http://role/path/
cookbook_path: /cookbook/path
roles:
- name : role0
- name : role1
}
	File.open("/tmp/.virtualman.rc.yaml", 'w') { |file| file.write(conf_string) }
end

module Kernel
	def `(cmd)
		if cmd =~ /abort/
			system('this_commanddoesnt exist test >/dev/null 2>&1')
			return cmd
		elsif cmd =~ /diff/
			system("#{cmd} > /dev/null 2>&1")
			return cmd
		elsif cmd =~ /whoami/
			return "PierreOzoux\n"
		elsif cmd =~ /sudo/
			cmd.gsub!("sudo","")
			system(cmd)
			return true
		else 	
			system('echo test >/dev/null 2>&1')
			return cmd
		end
	end

	def sleep foo
	end
end
