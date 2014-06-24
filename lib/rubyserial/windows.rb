require 'ffi'

module RubySerial
 extend FFI::Library
  ffi_lib FFI::Library::LIBC

  class SerialPort
    def initialize(address, baude_rate, data_bits)
      # implemtation here
    end 

    def method_missing(method_name, *arguments, &block)
     # @file.send(method_name, *arguments, &block)
    end
  end
end