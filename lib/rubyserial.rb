# Copyright (c) 2014-2016 The Hybrid Group
# Copyright (c) 2019 Patrick Plenefisch

require 'rbconfig'
require 'ffi'

##
# Low-level API. May change between minor releases. For stability, see {Serial} or {SerialPort}.
# To build serial ports with this API, see {RubySerial::Builder}
module RubySerial
  # @!visibility private
  ON_WINDOWS = RbConfig::CONFIG['host_os'] =~ /mswin|windows|mingw/i
  # @!visibility private
  ON_LINUX = RbConfig::CONFIG['host_os'] =~ /linux/i

  # Error thrown for most RubySerial-specific operations. Originates
  # from ffi errors.
  class Error < IOError
  end
end

require 'rubyserial/configuration'

# Load the appropriate RubySerial::Builder
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

# Mid-level API. A simple no-fluff serial port interface. Is an IO object.
class SerialIO < IO
  include RubySerial::Includes
  ##
  # Creates a new {SerialIO} object for the given serial port configuration
  # @param [RubySerial::Configuration] config The configuration to open
  # @param [Class] parent The parent class to instantiate. Must be a subclass of {SerialIO}
  # @return [SerialIO] An intance of parent
  # @raise [Errno::ENOENT] If not a valid file
  # @raise [RubySerial::Error] If not a valid TTY device (only on non-windows platforms), or any other general FFI error
  # @raise [ArgumentError] If arguments are invalid
  def self.new(config, parent=SerialIO)
    serial, fd, _ = RubySerial::Builder.build(parent, config)
    serial.send :name=, config.device
    serial.send :fd=, fd
    serial
  end

  # @!visibility private
  # Don't doc Object methods
  def inspect
    "#<#{self.class.name}:#{name}>" # TODO: closed
  end

  # @return [String] The name of the serial port
  attr_reader :name

  private
  attr_writer :name, :fd
  attr_reader :fd
end

# SerialPort gem style interface. Roughly compatible with the SerialPort gem. Recommended. High-level API, and stable.
class SerialPort < IO
  include RubySerial::Includes
  ##
  # Creates a new {SerialPort} instance with an API roughly compatible with the SerialPort gem.
  # @example
  #   SerialPort.new("/dev/ttyS0", "baud" => 9600, "data_bits" => 8, "stop_bits" => 1, "parity" => :none) #=> #<SerialPort:fd 3>
  #   SerialPort.new("/dev/ttyS0", 9600, 8, 1, :none) #=> #<SerialPort:fd 4>
  # @param [String] device The serial port name to open
  # @return [SerialPort] An opened serial port
  # @raise [Errno::ENOENT] If not a valid file
  # @raise [RubySerial::Error] Any other general FFI error
  # @raise [ArgumentError] If not a valid TTY device (only on non-windows platforms), or if arguments are invalid
  #
  # @overload new(device, baud=nil, data_bits=nil, stop_bits=nil, parity=nil)
  #   @param [Integer] baud The baud to open the serial port with, or nil to use the current baud
  #   @param [Integer] data_bits The number of data_bits to open the serial port with, or nil to use the current data_bits
  #   @param [Integer] stop_bits The number of stop_bits to open the serial port with, or nil to use the current stop_bits
  #   @param [Symbol] parity The parity to open the serial port with, or nil to use the current parity. Valid values are: `:none`, `:even`, and `:odd`
  #
  # @overload new(device, hash)
  #   @param [Hash<String, Object>] hash The given parameters, but as stringly-keyed values in a hash
  #   @option hash [Integer] "baud" The baud. Optional
  #   @option hash [Integer] "data_bits" The number of data bits. Optional
  #   @option hash [Integer] "stop" The number of stop bits. Optional
  #   @option hash [Symbol] "parity" The parity. Optional
  def self.new(device, *params)
    raise ArgumentError, "Not Implemented. Please use a full path #{device}" if device.is_a? Integer
    baud, *listargs = *params
    baud, *listargs = baud["baud"], baud["data_bits"], baud["stop_bits"], baud["parity"] if baud.is_a? Hash and listargs == []
    data, stop, par = *listargs

    args = RubySerial::Configuration.from(device: device, baud: baud, enable_blocking: true, data_bits: data, parity: par, stop_bits: stop, clear_config: true)

    begin
      serial, _, config = RubySerial::Builder.build(SerialPort, args)
      serial.send :name=, device
      serial.instance_variable_set :@config, config
      serial
    rescue RubySerial::Error => e
      if e.message == "ENOTTY"
        raise ArgumentError, "not a serial port"
      else
        raise
      end
    end
  end

  ##
  # Creates a new {SerialPort} instance with an API roughly compatible with the SerialPort gem.
  # With no associated block, {.open} is a synonym for {.new}. If the optional code block is given,
  # it will be passed io as an argument, and the {SerialPort} will automatically be closed when the block
  # terminates. In this instance, {.open} returns the value of the block.
  # @see .new
  # @example
  #   SerialPort.open("/dev/ttyS0", "baud" => 9600, "data_bits" => 8, "stop_bits" => 1, "parity" => :none) { |s|
  #     s #=> #<SerialPort:fd 3>
  #   }
  #   SerialPort.open("/dev/ttyS0", 9600, 8, 1, :none) { |s|
  #     s #=> #<SerialPort:fd 4>
  #   }
  #
  # @raise [Errno::ENOENT] If not a valid file
  # @raise [RubySerial::Error] Any other general FFI error
  # @raise [ArgumentError] If not a valid TTY device (only on non-windows platforms), or if arguments are invalid
  #
  # @overload open(device, baud=nil, data_bits=nil, stop_bits=nil, parity=nil)
  #   Creates a new {SerialPort} and returns it.
  #   @return [SerialPort] An opened serial port
  #   @param [Integer] baud The baud to open the serial port with, or nil to use the current baud
  #   @param [Integer] data_bits The number of data_bits to open the serial port with, or nil to use the current data_bits
  #   @param [Integer] stop_bits The number of stop_bits to open the serial port with, or nil to use the current stop_bits
  #   @param [Symbol] parity The parity to open the serial port with, or nil to use the current parity. Valid values are: `:none`, `:even`, and `:odd`
  # @overload open(device, hash)
  #   Creates a new {SerialPort} and returns it.
  #   @return [SerialPort] An opened serial port
  #   @param [Hash<String, Object>] hash The given parameters, but as stringly-keyed values in a hash
  #   @option hash [Integer] "baud" The baud. Optional
  #   @option hash [Integer] "data_bits" The number of data bits. Optional
  #   @option hash [Integer] "stop" The number of stop bits. Optional
  #   @option hash [Symbol] "parity" The parity. Optional
  # @overload open(device, baud=nil, data_bits=nil, stop_bits=nil, parity=nil)
  #   Creates a new {SerialPort} and pass it to the provided block, closing automatically.
  #   @return [Object] What the block returns
  #   @yieldparam io [SerialPort] An opened serial port
  #   @param [Integer] baud The baud to open the serial port with, or nil to use the current baud
  #   @param [Integer] data_bits The number of data_bits to open the serial port with, or nil to use the current data_bits
  #   @param [Integer] stop_bits The number of stop_bits to open the serial port with, or nil to use the current stop_bits
  #   @param [Symbol] parity The parity to open the serial port with, or nil to use the current parity. Valid values are: `:none`, `:even`, and `:odd`
  # @overload open(device, hash)
  #   Creates a new {SerialPort} and pass it to the provided block, closing automatically.
  #   @return [Object] What the block returns
  #   @yieldparam io [SerialPort] An opened serial port
  #   @param [Hash<String, Object>] hash The given parameters, but as stringly-keyed values in a hash
  #   @option hash [Integer] "baud" The baud. Optional
  #   @option hash [Integer] "data_bits" The number of data bits. Optional
  #   @option hash [Integer] "stop" The number of stop bits. Optional
  #   @option hash [Symbol] "parity" The parity. Optional
  def self.open(device, *params)
    arg = SerialPort.new(device, *params)
    return arg unless block_given?
    begin
      yield arg
    ensure
      arg.close
    end
  end

  NONE = :none
  EVEN = :even
  ODD = :odd

  # @return [String] the name of the serial port
  attr_reader :name

  # @!attribute hupcl
  # @return [Boolean] the value of the hupcl flag (posix) or DtrControl is set to start high (windows). Note that you must re-open the port twice to have it take effect
  def hupcl= value
    value = !!value
    @config = reconfigure(hupcl: value)
    value
  end

  def hupcl
    @config.hupcl
  end

  # @!attribute baud
  # @return [Integer] the baud of this serial port
  def baud= value
    @config = reconfigure(baud: value)
    value
  end

  def baud
    @config.baud
  end

  # @!attribute data_bits
  # @return [Integer] the number of data bits (typically 8 or 7)
  def data_bits= value
    @config = reconfigure(data_bits: value)
    value
  end

  def data_bits
    @config.data_bits
  end

  # @!attribute parity
  # @return [Symbol] the parity, one of `:none`, `:even`, or `:odd`
  def parity= value
    @config = reconfigure(parity: value)
    value
  end

  def parity
    @config.parity
  end

  # @!attribute stop_bits
  # @return [Integer] the number of stop bits (either 1 or 2)
  def stop_bits= value
    @config = reconfigure(stop_bits: value)
    value
  end

  def stop_bits
    @config.stop_bits
  end

  private
  attr_writer :name
end

# Custom rubyserial Serial interface. High-level API, and stable.
class Serial < SerialIO

  # Creates a new {Serial} instance,
  # @example
  #   Serial.new("/dev/ttyS0", 9600, 8, :none, 1) #=> #<Serial:/dev/ttyS0>
  # @param [String] address The serial port name to open
  # @param [Integer] baud_rate The baud to open the serial port with, or nil to use the current baud
  # @param [Integer] data_bits The number of data_bits to open the serial port with, or nil to use the current data_bits
  # @param [Integer] stop_bits The number of stop_bits to open the serial port with, or nil to use the current stop_bits
  # @param [Boolean] enable_blocking If we should enable blocking IO. By default all IO is nonblocking
  # @param [Symbol] parity The parity to open the serial port with, or nil to use the current parity. Valid values are: `:none`, `:even`, and `:odd`
  # @return [SerialPort] An opened serial port
  # @raise [Errno::ENOENT] If not a valid file
  # @raise [RubySerial::Error] If not a valid TTY device (only on non-windows platforms), or any other general FFI error
  # @raise [ArgumentError] If arguments are invalid
  def self.new(address, baud_rate=9600, data_bits=8, parity=:none, stop_bits=1, enable_blocking=false)
    super(RubySerial::Configuration.from(
        device: address,
        baud: baud_rate,
        data_bits: data_bits,
        parity: parity,
        stop_bits: stop_bits,
        enable_blocking: enable_blocking,
        clear_config: true), Serial)
  end

  # Returns a string up to `length` long. It is not guaranteed to return the entire
  # length specified, and will return an empty string if no data is
  # available. If enable_blocking=true, it is identical to standard ruby IO#read
  # except for the fact that empty reads still return empty strings instead of nil
  # @note nonstandard IO behavior
  # @return String
  def read(*args)
    res = super
    res.nil? ? '' : res
  end

  # Returns an 8 bit byte or nil if no data is available.
  # @note nonstandard IO signature and behavior
  # @yieldparam line [String]
  def gets(sep=$/, limit=nil)
    if block_given?
      loop do
        yield(get_until_sep(sep, limit))
      end
    else
      get_until_sep(sep, limit)
    end
  end

  private

  def get_until_sep(sep, limit)
    sep = "\n\n" if sep == ''
    # This allows the method signature to be (sep) or (limit)
    (limit = sep; sep="\n") if sep.is_a? Integer
    bytes = []
    loop do
      current_byte = getbyte
      bytes << current_byte unless current_byte.nil?
      break if (bytes.last(sep.bytes.to_a.size) == sep.bytes.to_a) || ((bytes.size == limit) if limit)
    end

    bytes.map { |e| e.chr }.join
  end
end
