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

if CONFIG['host_os'] =~ /mswin|windows/i
  require 'rubyserial/windows'
else
  if CONFIG['host_os'] =~ /linux/i
    require 'rubyserial/linux_constants'
  else
    require 'rubyserial/osx_constants'
  end
  require 'rubyserial/posix'
end