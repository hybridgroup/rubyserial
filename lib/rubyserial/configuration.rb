# Copyright (c) 2019 Patrick Plenefisch


module RubySerial
  # TODO: flow_control , :read_timeout, :write_timeout)
  
  # Configuration Struct passed to create a serial port, or returned back from a reconfiguration. Shows all current configurations.
  # When passed as a request, nil means no update, any other value is a request to update.
  # @example
  #   cfg = Configuration.new
  #   cfg.baud = 9600
  #   cfg[:device] = "COM1"
  #   cfg[:baud] #=> 9600
  Configuration = Struct.new(:device, :baud, :data_bits, :parity, :stop_bits, :hupcl, :enable_blocking, :clear_config)
  class Configuration
  	# Builds a Configuration object using the given keyword arguments
  	# @example
  	#   Configuration.from(baud: 9600) #=>  #<struct RubySerial::Configuration device=nil, baud=9600, data_bits=nil, parity=nil, stop_bits=nil, hupcl=nil, enable_blocking=nil, clear_config=nil>
    def self.from(**kwargs)
      kwargs.each_with_object(new) {|(arg, val),o| o[arg] = val}
    end
  end
end
