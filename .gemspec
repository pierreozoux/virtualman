Gem::Specification.new do |s|
  s.name        = 'virtualman'
  s.version     = '1.1.3'
  s.executables << 'virtualman'
  s.date        = '2012-09-11'
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
    "bin/virtualman"
  ]
  s.homepage    =
    'http://rubygems.org/gems/virtualman'
end
