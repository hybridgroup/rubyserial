require 'ffi'

class Serial
  def initialize(address, baude_rate=9600, data_bits=8)
    file_opts = RubySerial::Win32::GENERIC_READ | RubySerial::Win32::GENERIC_WRITE
    @serial = RubySerial::Win32.CreateFileA(address, file_opts, 0, nil,
      RubySerial::Win32::OPEN_EXISTING, 0, nil)
    @error  = Win32.error_check
    @open = true

    RubySerial::DCB.new.tap do |p|
      p[:dcblength] = RubySerial::DCB::Sizeof
      RubySerial::Win32.GetCommState @serial, p
      p[:baudrate] = baude_rate
      p[:bytesize] = data_bits
      p[:stopbits] = RubySerial::DCB::ONESTOPBIT
      p[:parity]   = RubySerial::DCB::NOPARITY
      RubySerial::Win32.SetCommState @serial, p
      @error  = Win32.error_check
    end

    RubySerial::CommTimeouts.new.tap do |timeouts|
      timeouts[:read_interval_timeout]          = 50
      timeouts[:read_total_timeout_multiplier]  = 50
      timeouts[:read_total_timeout_constant]    = 10
      timeouts[:write_total_timeout_multiplier] = 50
      timeouts[:write_total_timeout_constant]   = 10
      RubySerial::Win32.SetCommTimeouts @serial, timeouts
      @error  = Win32.error_check
    end

    @buffer = FFI::MemoryPointer.new :char, 1024
    @count = FFI::MemoryPointer.new :uint, 1
    @report = false
  end

  def read(size)
    buff = FFI::MemoryPointer.new :char, size
    count = FFI::MemoryPointer.new :uint, 1
    i = RubySerial::Win32.ReadFile(@serial, buff, size, count, nil)
    @error  = Win32.error_check
    if i == 0
      puts "read failed #{i}"
    end
    buff.get_bytes(0, count.read_uint32)
  end

  def write(data)
    buff = FFI::MemoryPointer.from_string(data.to_s)
    count = FFI::MemoryPointer.new :uint, 1
    i = RubySerial::Win32.WriteFile(@serial, buff, buff.size, count, nil)
    @error  = Win32.error_check
    if i == 0
      puts "write failed #{i}"
    end
    # puts "write count %i" % @count.read_uint32
  end

  def close
    @open = false
    RubySerial::Win32.CloseHandle(@serial)
    @error = Win32.error_check
  end

  def closed?
    !@open
  end
end
