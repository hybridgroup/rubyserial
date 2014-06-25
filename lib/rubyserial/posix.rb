class Serial
  def initialize(address, baude_rate=9600, data_bits=8)
    file_opts = File::RDWR | File::NOCTTY | File::NONBLOCK
    @fd       = IO::sysopen(address, file_opts)
    @file     = IO.open(@fd, "r+")
    @config   = build_config(baude_rate, data_bits)

    RubySerial::Posix.tcsetattr(@fd, RubySerial::Posix::TCSANOW, @config)
  end

  private

  def method_missing(method_name, *arguments, &block)
    @file.send(method_name, *arguments, &block)
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
    config[:cc_c][RubySerial::Posix::VTIME] = 10

    config
  end
end
