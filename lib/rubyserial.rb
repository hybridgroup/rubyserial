$:.unshift(File.dirname(__FILE__))
require 'rbconfig'
require 'ffi'
include RbConfig

if RUBY_PLATFORM == 'java'
  raise "Jruby not yet supported"
end

module RubySerial
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
end

require 'rubyserial/termios'
require 'rubyserial/generic'
require 'rubyserial/serial'
