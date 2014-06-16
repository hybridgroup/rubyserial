$:.push File.expand_path("../lib", __FILE__)
require "rubyserial/version"

Gem::Specification.new do |s|
  s.name = "rubyserial"
  s.version = RubySerial::VERSION
  s.summary = "Pure ruby serialport gem"
  s.description = "Pure ruby serialport gem"
  s.homepage    = "https://github.com/hybridgroup/rubyserial"
  s.authors = ["Theron Boerner", "Javier Cervantes"]
  s.platform    = Gem::Platform::RUBY

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end