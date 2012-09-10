Gem::Specification.new do |s|
  s.name        = 'virtualman'
  s.version     = '1.1.0'
  s.executables << 'clone_vm'
  s.executables << 'virtualman'
  s.executables << 'ssh_cloned'
  s.executables << 'clone_cooking'
  s.date        = '2012-09-06'
  s.summary     = "A simple way to manage your Virtual Machines under VirtualBox."
  s.description = "It is for writing scripts for UNIX-like systems to handle your VirtualBox appliance."
  s.authors     = ["Pierre Ozoux"]
  s.email       = 'pierre.ozoux@gmail.com'
  s.files       = [
    "lib/virtualman.rb",
    "lib/virtualman/conf.rb",
    "lib/virtualman/interractive.rb",
    "lib/virtualman/menu.rb",
    "lib/virtualman/vm.rb",
    "lib/virtualman/vmlister.rb",
    "bin/clone_vm",
    "bin/virtualman"
  ]
  s.homepage    =
    'http://rubygems.org/gems/virtualman'
end
