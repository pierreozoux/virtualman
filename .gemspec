Gem::Specification.new do |s|
  s.name        = 'virtualman'
  s.version     = '2.0.0'
  s.executables << 'virtualman'
  s.date        = '2012-11-15'
  s.summary     = "A simple way to manage your Virtual Machines under VirtualBox."
  s.description = "An interactive tool, and library to manage quickly your VMs"
  s.authors     = ["Pierre Ozoux"]
  s.email       = 'pierre.ozoux@gmail.com'
  s.files       = [
    "lib/virtualman.rb",
    "lib/virtualman/interactive/configuration.rb",
    "lib/virtualman/interactive/REPL.rb",
    "lib/virtualman/interactive/menu.rb",
    "lib/virtualman/vm.rb",
    "lib/virtualman/vmlister.rb",
    "lib/virtualman/interactive/helper.rb",
    "bin/virtualman"
  ]
  s.homepage    =
    'http://rubygems.org/gems/virtualman'
end
