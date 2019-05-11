# Copyright (c) 2014-2016 The Hybrid Group

class Serial
  def initialize(address, baud_rate=9600, data_bits=8, parity=:none, stop_bits=1)
    file_opts = RubySerial::Posix::O_RDWR | RubySerial::Posix::O_NOCTTY | RubySerial::Posix::O_NONBLOCK
    @fd = RubySerial::Posix.open(address, file_opts)

    if @fd == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    else
      @open = true
    end

    fl = RubySerial::Posix.fcntl(@fd, RubySerial::Posix::F_GETFL, :int, 0)
    if fl == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    end

    err = RubySerial::Posix.fcntl(@fd, RubySerial::Posix::F_SETFL, :int, ~RubySerial::Posix::O_NONBLOCK & fl)
    if err == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    end

    @config = build_config(baud_rate, data_bits, parity, stop_bits)

    err = RubySerial::Posix.tcsetattr(@fd, RubySerial::Posix::TCSANOW, @config)
    if err == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    end
  end

  def closed?
    !@open
  end

  def close
    err = RubySerial::Posix.close(@fd)
    if err == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    else
      @open = false
    end
  end

  def write(data)
    data = data.to_s
    n =  0
    while data.size > n do
      buff = FFI::MemoryPointer.from_string(data[n..-1].to_s)
      i = RubySerial::Posix.write(@fd, buff, buff.size-1)
      if i == -1
        raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
      else
        n = n+i
      end
    end

    # return number of bytes written
    n
  end

  def read(size)
    buff = FFI::MemoryPointer.new :char, size
    i = RubySerial::Posix.read(@fd, buff, size)
    if i == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    end
    buff.get_bytes(0, i)
  end

  def getbyte
    buff = FFI::MemoryPointer.new :char, 1
    i = RubySerial::Posix.read(@fd, buff, 1)
    if i == -1
      raise RubySerial::Error, RubySerial::Posix::ERROR_CODES[FFI.errno]
    end

    if i == 0
      nil
    else
      buff.get_bytes(0,1).bytes.first
    end
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

  def build_config(baud_rate, data_bits, parity, stop_bits)
    config = RubySerial::Posix::Termios.new

    config[:c_iflag]  = RubySerial::Posix::IGNPAR
    config[:c_ispeed] = RubySerial::Posix::BAUD_RATES[baud_rate]
    config[:c_ospeed] = RubySerial::Posix::BAUD_RATES[baud_rate]
    config[:c_cflag]  = RubySerial::Posix::DATA_BITS[data_bits] |
      RubySerial::Posix::CREAD |
      RubySerial::Posix::CLOCAL |
      RubySerial::Posix::PARITY[parity] |
      RubySerial::Posix::STOPBITS[stop_bits]

    # Masking in baud rate on macOS would corrupt the settings.
    if RubySerial::ON_LINUX
      config[:c_cflag] = config[:c_cflag] | RubySerial::Posix::BAUD_RATES[baud_rate]
    end

    config[:cc_c][RubySerial::Posix::VMIN] = 0

    config
  end
end
