$:.push File.expand_path("../lib", __FILE__)
require "rubyserial/version"

Gem::Specification.new do |s|
  s.name        = "rubyserial"
  s.version     = RubySerial::VERSION
  s.summary     = "ffi ruby serialport gem"
  s.description = "ffi ruby serialport gem"
  s.homepage    = "https://github.com/hybridgroup/rubyserial"
  s.authors     = ["Theron Boerner", "Javier Cervantes"]
  s.platform    = Gem::Platform::RUBY
  s.license     = 'Apache 2.0'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

	s.add_runtime_dependency 'ffi', '~> 1.9.3'
end
