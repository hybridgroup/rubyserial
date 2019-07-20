# Copyright (c) 2014-2016 The Hybrid Group

class RubySerial::Builder
  def self.build(address: , parent: IO, baud: 9600, data_bits: 8, parity: :none, stop_bits: 1, blocking: true, clear_config: true)
    fd = IO::sysopen(address, File::RDWR | File::NOCTTY | File::NONBLOCK)

    # enable blocking mode
    if blocking
    fl = ffi_call(:fcntl, fd, RubySerial::Posix::F_GETFL, :int, 0)
    ffi_call(:fcntl, fd, RubySerial::Posix::F_SETFL, :int, ~RubySerial::Posix::O_NONBLOCK & fl)
    end

    # Update the terminal settings
    reconfigure(fd, clear_config, min: (blocking ? 1 : 0), baud: baud, data_bits: data_bits, parity: parity, stop_bits: stop_bits)

    file = parent.send(:for_fd, fd, File::RDWR | File::SYNC)
    file._posix_fd = fd
    unless file.tty?
      raise ArgumentError, "not a serial port: #{address}"
    end
    [file, address, fd]
  end

  def self.reconfigure(fd, clear_config, hupcl: nil, baud: nil, data_bits: nil, parity: nil, stop_bits: nil, min: nil)
    # Update the terminal settings
    config = RubySerial::Posix::Termios.new
    ffi_call(:tcgetattr, fd, config)
    edit_config(config, clear_config, baud_rate: baud, data_bits: data_bits, parity: parity, stop_bits: stop_bits, hupcl: hupcl, min: min)
    ffi_call(:tcsetattr, fd, RubySerial::Posix::TCSANOW, config)
  end

  private

  def self.ffi_call target, *args
  res = RubySerial::Posix.send(target, *args)
    if res == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    end
    res
  end

  def self.set config, field, flag, value, map = nil
    return if value.nil?
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
  end

  def self.edit_config(config, clear, min: nil, baud_rate: nil, data_bits: nil, parity: nil, stop_bits: nil, hupcl: nil)
    if clear
      # reset everything except for flow settings
      config[:c_iflag] &= (RubySerial::Posix::IXON | RubySerial::Posix::IXOFF | RubySerial::Posix::IXANY | RubySerial::Posix::CRTSCTS)
      config[:c_iflag] |= RubySerial::Posix::IGNPAR
      config[:c_oflag] = 0
      config[:c_cflag] = RubySerial::Posix::CREAD | RubySerial::Posix::CLOCAL
      config[:c_lflag] = 0
    end

    config[:cc_c][RubySerial::Posix::VMIN] = min unless min.nil?

    unless baud_rate.nil?
      # Masking in baud rate on OS X would corrupt the settings.
      if RubySerial::ON_LINUX
        set config, :c_cflag, RubySerial::Posix::CBAUD, baud_rate, RubySerial::Posix::BAUD_RATES
      end

      config[:c_ospeed] = config[:c_ispeed] = RubySerial::Posix::BAUD_RATES[baud_rate]
    end

    set config, :c_cflag, RubySerial::Posix::CSIZE, data_bits, RubySerial::Posix::DATA_BITS
    set config, :c_cflag, RubySerial::Posix::PARITY_FIELD, parity, RubySerial::Posix::PARITY
    set config, :c_cflag, RubySerial::Posix::CSTOPB, stop_bits, RubySerial::Posix::STOPBITS
    set config, :c_cflag, RubySerial::Posix::HUPCL, hupcl

    config
  end
end

# Module that must be included in the parent class for RubySerial::Builder to work correctly
module RubySerial::Includes
  def reconfigure(clear_config, hupcl: nil, baud: nil, data_bits: nil, parity: nil, stop_bits: nil, min: nil)
    RubySerial::Builder.reconfigure(@_rs_fd, clear_config, hupcl: hupcl, baud: baud, data_bits: data_bits, parity: parity, stop_bits: stop_bits, min: min)
  end

  def _posix_fd= fd
    @_rs_fd = fd
  end
end
