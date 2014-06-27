$:.unshift(File.dirname(__FILE__))
require 'rbconfig'
require 'ffi'
include RbConfig

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