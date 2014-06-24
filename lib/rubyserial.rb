$:.unshift(File.dirname(__FILE__))
require 'rubyserial/serial'
require 'rbconfig'
include RbConfig

if RUBY_PLATFORM == 'java'
  raise "Jruby not yet supported"
end

case CONFIG['host_os']
   when /linux/i
    require 'rubyserial/linux'
   when /mswin|windows/i
    raise "windows not implemented"  
    #require 'rubyserial/windows'
   when /darwin/i
    raise "osx not implemented"  
    #require 'rubyserial/osx'
   else
    raise "Unknown environment"  
end