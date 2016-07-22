# Copyright (c) 2014-2016 The Hybrid Group

require 'rbconfig'
require 'ffi'

module RubySerial
  ON_WINDOWS = RbConfig::CONFIG['host_os'] =~ /mswin|windows|mingw/i
  ON_LINUX = RbConfig::CONFIG['host_os'] =~ /linux/i
  class Exception < Exception
  end
end

if RubySerial::ON_WINDOWS
  require 'rubyserial/windows_constants'
  require 'rubyserial/windows'
else
  if RubySerial::ON_LINUX
    require 'rubyserial/linux_constants'
  else
    require 'rubyserial/osx_constants'
  end
  require 'rubyserial/posix'
end
