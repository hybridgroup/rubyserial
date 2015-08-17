class Serial
  def initialize(address, baude_rate = 9600, data_bits = 8)
    file_opts = RubySerial::Posix::O_RDWR | RubySerial::Posix::O_NOCTTY | RubySerial::Posix::O_NONBLOCK
    @fd = cmd { RubySerial::Posix.open(address, file_opts) }
    @open = true

    fl = cmd { RubySerial::Posix.fcntl(@fd, RubySerial::Posix::F_GETFL, :int, 0) }
    cmd { RubySerial::Posix.fcntl(@fd, RubySerial::Posix::F_SETFL, :int, ~RubySerial::Posix::O_NONBLOCK & fl) }

    @config = build_config(baude_rate, data_bits)
    cmd { RubySerial::Posix.tcsetattr(@fd, RubySerial::Posix::TCSANOW, @config) }
  end

  def closed?
    !@open
  end

  def close
    cmd { RubySerial::Posix.close(@fd) }
    @open = false
  end

  def write(data)
    data = data.to_s
    n =  0
    while data.size > n do
      buff = FFI::MemoryPointer.from_string(data[n..-1].to_s)
      i = cmd { RubySerial::Posix.write(@fd, buff, buff.size-1) }
      n = n + i
    end

    n # return number of bytes written
  end

  def read(size)
    buff = FFI::MemoryPointer.new :char, size
    i = cmd { RubySerial::Posix.read(@fd, buff, size) }
    buff.get_bytes(0, i)
  end

  def getbyte
    buff = FFI::MemoryPointer.new :char, 1
    i = cmd { RubySerial::Posix.read(@fd, buff, 1) }
    i.zero? ? nil : buff.get_bytes(0, 1).bytes.first
  end

  def gets(sep=$/, limit=nil)
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

  private

  def cmd(&block)
    result = block.call
    if result == -1
      raise RubySerial::Exception, RubySerial::Posix::ERROR_CODES[FFI.errno]
    end
    result
  end

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
