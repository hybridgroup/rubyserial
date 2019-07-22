# Copyright (c) 2014-2016 The Hybrid Group
# Copyright (c) 2019 Patrick Plenefisch


##
# Low-level API. May change between minor releases. For stability, see {Serial} or {SerialPort}.
class RubySerial::Builder
  ##
  # Creates an instance of the given parent class to be a serial port with the given configuration
  #
  # @example
  #   RubySerial::Builder.build(SerialIO, RubySerial::Configuration.from(device: "/dev/ttyS0"))
  #     #=> [#<SerialIO:/dev/ttyS0>, 3, #<struct RubySerial::Configuration device="/dev/ttyS0", baud=9600, data_bits=8, parity=:none, stop_bits=1, hupcl=false, enable_blocking=nil, clear_config=nil>]
  #
  # @param [Class] parent A class that is_a? IO and has included the {RubySerial::Includes} module
  # @param [RubySerial::Configuration] config The details of the serial port to open
  # @return [parent, Integer, RubySerial::Configuration] A new instance of parent, the file descriptor, and the current configuration of the serial port
  # @raise [Errno::ENOENT] If not a valid file
  # @raise [RubySerial::Error] If not a TTY device (only on non-windows platforms), or any other general error
  def self.build(parent, config)
    fd = IO::sysopen(config.device, File::RDWR | File::NOCTTY | File::NONBLOCK)

    # enable blocking mode. I'm not sure why we do it this way, with disable and then re-enable. History suggests that it might be a mac thing
    if config.enable_blocking
      fl = ffi_call(:fcntl, fd, RubySerial::Posix::F_GETFL, :int, 0)
      ffi_call(:fcntl, fd, RubySerial::Posix::F_SETFL, :int, ~RubySerial::Posix::O_NONBLOCK & fl)
    end

    # Update the terminal settings
    out_config = reconfigure(fd, config)
    out_config.device = config.device

    file = parent.send(:for_fd, fd, File::RDWR | File::SYNC)
    file.send :_rs_posix_init, fd

    return [file, fd, out_config]
  end

  # @api private
  # @!visibility private
  # Reconfigures the given (platform-specific) file handle with the provided configuration. See {RubySerial::Includes#reconfigure} for public API
  def self.reconfigure(fd, req_config)
    # Update the terminal settings
    config = RubySerial::Posix::Termios.new
    ffi_call(:tcgetattr, fd, config)
    out_config = edit_config(config, req_config, min: {nil => nil, true => 1, false => 0}[req_config.enable_blocking])
    ffi_call(:tcsetattr, fd, RubySerial::Posix::TCSANOW, config)
    out_config
  end

  private

  # Calls the given FFI target, and raises an error if it fails
  def self.ffi_call target, *args
    res = RubySerial::Posix.send(target, *args)
    if res == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    end
    res
  end

  # Sets the given config value (if provided), and returns the current value
  def self.set config, field, flag, value, map = nil
    return get((config[field] & flag), map) if value.nil?
    trueval = if map.nil?
      if !!value == value # boolean values set to the flag
        value ? flag : 0
      else
        value
      end
    else
      map[value]
    end
    raise RubySerial::Error, "Values out of range: #{value}" unless trueval.is_a? Integer
    # mask the whole field, and set new value
    config[field] = (config[field] & ~flag) | trueval
    value
  end

  def self.get value, options
    return value != 0 if options.nil?
    options.key(value)
  end

  # Updates the configuration object with the requested configuration
  def self.edit_config(config, req, min: nil)
    actual = RubySerial::Configuration.from(clear_config: req.clear_config)

    if req.clear_config
      # reset everything except for flow settings
      config[:c_iflag] &= (RubySerial::Posix::IXON | RubySerial::Posix::IXOFF | RubySerial::Posix::IXANY | RubySerial::Posix::CRTSCTS)
      config[:c_iflag] |= RubySerial::Posix::IGNPAR
      config[:c_oflag] = 0
      config[:c_cflag] = RubySerial::Posix::CREAD | RubySerial::Posix::CLOCAL
      config[:c_lflag] = 0
    end

    config[:cc_c][RubySerial::Posix::VMIN] = min unless min.nil?

    unless req.baud.nil?
      # Masking in baud rate on OS X would corrupt the settings.
      if RubySerial::ON_LINUX
        set config, :c_cflag, RubySerial::Posix::CBAUD, req.baud, RubySerial::Posix::BAUD_RATES
      end

      config[:c_ospeed] = config[:c_ispeed] = RubySerial::Posix::BAUD_RATES[req.baud]
    end
    actual.baud = get config[:c_ispeed], RubySerial::Posix::BAUD_RATES

    actual.data_bits = set config, :c_cflag, RubySerial::Posix::CSIZE, req.data_bits, RubySerial::Posix::DATA_BITS
    actual.parity = set config, :c_cflag, RubySerial::Posix::PARITY_FIELD, req.parity, RubySerial::Posix::PARITY
    actual.stop_bits = set config, :c_cflag, RubySerial::Posix::CSTOPB, req.stop_bits, RubySerial::Posix::STOPBITS
    actual.hupcl = set config, :c_cflag, RubySerial::Posix::HUPCL, req.hupcl

    return actual
  end
end

# The module that must be included in the parent class (such as {SerialIO}, {Serial}, or {SerialPort}) for {RubySerial::Builder} to work correctly. These methods are thus on all RubySerial objects.
module RubySerial::Includes
  # Reconfigures the serial port with the given new values, if provided. Pass nil to keep the current settings.
  # @return [RubySerial::Configuration) The currently configured values for this serial port.
  def reconfigure(hupcl: nil, baud: nil, data_bits: nil, parity: nil, stop_bits: nil)
    RubySerial::Builder.reconfigure(@_rs_posix_fd, RubySerial::Configuration.from(hupcl: hupcl, baud: baud, data_bits: data_bits, parity: parity, stop_bits: stop_bits))
  end

  # TODO: dts set on linux?
  private
  def _rs_posix_init(fd)
    @_rs_posix_fd = fd
  end
end
