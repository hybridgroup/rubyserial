# Copyright (c) 2014-2016 The Hybrid Group

require 'rbconfig'
require 'ffi'

module RubySerial
  ON_WINDOWS = RbConfig::CONFIG['host_os'] =~ /mswin|windows|mingw/i
  ON_LINUX = RbConfig::CONFIG['host_os'] =~ /linux/i
  class Error < IOError
  end
end

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

# Generic IO interface
class SerialIO < IO
  include RubySerial::Includes
  def self.new(address, baud_rate=9600, data_bits=8, parity=:none, stop_bits=1, parent: SerialIO, blocking: true)
    serial, name, fd = RubySerial::Builder.build(parent: parent, address: address, baud: baud_rate, data_bits: data_bits, parity: parity, stop_bits: stop_bits, blocking: blocking)
    serial.send :name=, name
    serial.send :fd=, fd
    serial
  end

  # TODO: reconfigure, etc

  def inspect
    "#<#{self.class.name}:#{name}>"
  end

  attr_reader :name

  private
  attr_writer :name, :fd
  attr_reader :fd
end

# serial-port-style interface
class SerialPort < IO
  include RubySerial::Includes
  def self.new(device, *params)
    raise "NNNNNNN" if device.is_a? Integer
    listargs = *params
    listargs = listargs["baud"], listargs["data_bits"], listargs["stop_bits"], listargs["parity"] if listargs.is_a? Hash
    baud, data, stop, par = *listargs

    args = {parent: SerialPort,
      address: device,
      baud: baud,
      blocking: true}

    # use defaults, not nil
    args[:data_bits] = data if data
    args[:parity] = par if par
    args[:stop_bits] = stop if stop

    serial, name, fd = RubySerial::Builder.build(**args)
    serial.send :name=, name
    serial.send :fd=, fd
    serial
  end

  def self.open(*args)
    arg = SerialPort.new(*args)
    begin
      yield arg
    ensure
      arg.close
    end
  end
  NONE = :none
  SPACE = :space
  MARK = :mark
  EVEN = :even
  ODD = :odd

  def hupcl= value
    value = !!value
    reconfigure(false, hupcl: value)
    value
  end

  def baud= value
    reconfigure(false, baud: value)
  end
  def data_bits= value
    reconfigure(false, data_bits: value)
  end
  def parity= value
    reconfigure(false, parity: value)
  end
  def stop_bits= value
    reconfigure(false, stop_bits: value)
  end

  def reconfigzure(**kwargs)
    RubySerial::Builder.reconfigure(@fd, false, **kwargs)
    kwargs.to_a[0][1]
  end

  private
  attr_writer :name, :fd

end

# rubyserial-style interface
class Serial < SerialIO
  def self.new(address, baud_rate=9600, data_bits=8, parity=:none, stop_bits=1)
    super(address, baud_rate, data_bits, parity, stop_bits, parent: Serial, blocking: false)
  end

  def read(*args)
    res = super
    res.nil? ? '' : res
  end

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
