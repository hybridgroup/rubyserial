$:.unshift(File.dirname(__FILE__))
require 'rubyserial/serial'
require 'rbconfig'
include RbConfig

if RUBY_PLATFORM == 'java'
  raise "Jruby not yet supported"
end

if CONFIG['host_os'] =~ /mswin|windows|mingw/i
  require 'rubyserial/windows'
else
  if CONFIG['host_os'] =~ /linux/i
    require 'rubyserial/linux_constants'
  else
    require 'rubyserial/osx_constants'
  end
  require 'rubyserial/posix'
end