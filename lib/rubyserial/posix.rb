require 'ffi'

class Serial
  def initialize(address, baude_rate=9600, data_bits=8)
    file_opts = RubySerial::Posix::O_RDWR | RubySerial::Posix::O_NOCTTY
    @fd = RubySerial::Posix.open(address, file_opts)
    if @fd == -1 
      raise "Error opening file"
    else
      @open = true
    end
    fl = RubySerial::Posix.fcntl(@fd, RubySerial::Posix::F_GETFL, :int, 0)
    RubySerial::Posix.fcntl(@fd, RubySerial::Posix::F_SETFL, :int, ~RubySerial::Posix::O_NONBLOCK & fl)
    @config   = build_config(baude_rate, data_bits)
    RubySerial::Posix.tcsetattr(@fd, RubySerial::Posix::TCSANOW, @config)
  end

  def closed?
    !@open
  end

  def close
    @open = false
    RubySerial::Posix.close(@fd)
  end

  def write data
    n =  0
    while data.size > n do 
      buff = FFI::MemoryPointer.from_string(data[n..-1].to_s)
      i = RubySerial::Posix.write(@fd, buff, buff.size)
      if i == -1 
        puts "error writing"
      else
        n = n+i
      end
    end
  end

  def read size
      buff = FFI::MemoryPointer.new :char, size
      i = RubySerial::Posix.read(@fd, buff, size)
      if i == -1 
        puts "error reading"
      end
    return buff.get_bytes(0, i)
  end

  private

  def build_config(baude_rate, data_bits)
    config = RubySerial::Posix::Termios.new

    config[:c_iflag]  = RubySerial::Posix::IGNPAR
    config[:c_ispeed] = RubySerial::Posix::BAUDE_RATES[baude_rate]
    config[:c_ospeed] = RubySerial::Posix::BAUDE_RATES[baude_rate]
    config[:c_cflag]  = RubySerial::Posix::DATA_BITS[data_bits] |
      RubySerial::Posix::CREAD |
      RubySerial::Posix::CLOCAL |
      RubySerial::Posix::BAUDE_RATES[baude_rate]

    config[:cc_c][RubySerial::Posix::VMIN] = 0

    config
  end
end