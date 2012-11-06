Gem::Specification.new do |s|
  s.name        = 'virtualman'
  s.version     = '1.1.8'
  s.executables << 'virtualman'
  s.date        = '2012-11-05'
  s.summary     = "A simple way to manage your Virtual Machines under VirtualBox."
  s.description = "An interactive tool to manage quickly your VMs"
  s.authors     = ["Pierre Ozoux"]
  s.email       = 'pierre.ozoux@gmail.com'
  s.files       = [
    "lib/virtualman.rb",
    "lib/virtualman/configuration.rb",
    "lib/virtualman/interractive.rb",
    "lib/virtualman/menu.rb",
    "lib/virtualman/vm.rb",
    "lib/virtualman/vmlister.rb",
    "bin/virtualman"
  ]
  s.homepage    =
    'http://rubygems.org/gems/virtualman'
end
