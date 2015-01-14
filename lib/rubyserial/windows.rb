require 'ffi'

class Serial
  def initialize(address, baude_rate=9600, data_bits=8)
    file_opts = RubySerial::Win32::GENERIC_READ | RubySerial::Win32::GENERIC_WRITE
    @fd = RubySerial::Win32.CreateFileA(address, file_opts, 0, nil, RubySerial::Win32::OPEN_EXISTING, 0, nil)
    err = FFI.errno
    if err != 0
      raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[err]
    else
      @open = true
    end

    RubySerial::Win32::DCB.new.tap do |dcb|
      dcb[:dcblength] = RubySerial::Win32::DCB::Sizeof
      err = RubySerial::Win32.GetCommState @fd, dcb
      if err == 0
        raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[FFI.errno]
      end
      dcb[:baudrate] = baude_rate
      dcb[:bytesize] = data_bits
      dcb[:stopbits] = RubySerial::Win32::DCB::ONESTOPBIT
      dcb[:parity]   = RubySerial::Win32::DCB::NOPARITY
      err = RubySerial::Win32.SetCommState @fd, dcb
      if err == 0
        raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[FFI.errno]
      end
    end

    RubySerial::Win32::CommTimeouts.new.tap do |timeouts|
      timeouts[:read_interval_timeout]          = 10
      timeouts[:read_total_timeout_multiplier]  = 1
      timeouts[:read_total_timeout_constant]    = 10
      timeouts[:write_total_timeout_multiplier] = 1
      timeouts[:write_total_timeout_constant]   = 10
      err = RubySerial::Win32.SetCommTimeouts @fd, timeouts
      if err == 0
        raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[FFI.errno]
      end
    end
  end

  def read(size)
    buff = FFI::MemoryPointer.new :char, size
    count = FFI::MemoryPointer.new :uint32, 1
    err = RubySerial::Win32.ReadFile(@fd, buff, size, count, nil)
    if err == 0
      raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[FFI.errno]
    end
    buff.get_bytes(0, count.read_int)
  end

  def getbyte
    buff = FFI::MemoryPointer.new :char, 1
    count = FFI::MemoryPointer.new :uint32, 1
    err = RubySerial::Win32.ReadFile(@fd, buff, 1, count, nil)
    if err == 0
      raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[FFI.errno]
    end

    if count.read_int == 0
      nil
    else
      buff.read_string.unpack('C').first
    end
  end

  def write(data)
    buff = FFI::MemoryPointer.from_string(data.to_s)
    count = FFI::MemoryPointer.new :uint32, 1
    err = RubySerial::Win32.WriteFile(@fd, buff, buff.size-1, count, nil)
    if err == 0
      raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[FFI.errno]
    end
    count.read_int
  end

  def gets(sep=$/, limit=nil)
    sep = "\n\n" if sep == ''
    # This allows the method signature to be (sep) or (limit)
    (limit = sep; sep="\n") if sep.is_a? Integer
    bytes = []
    loop do
      current_byte = getbyte
      bytes << current_byte unless current_byte.nil?
      break if (bytes.last(sep.bytes.to_a.size) == sep.bytes) || ((bytes.size == limit) if limit)
    end

    bytes.map { |e| e.chr }.join
  end

  def close
    err = RubySerial::Win32.CloseHandle(@fd)
    if err == 0
      raise RubySerial::Exception, RubySerial::Win32::ERROR_CODES[FFI.errno]
    else
      @open = false
    end
  end

  def closed?
    !@open
  end
end
