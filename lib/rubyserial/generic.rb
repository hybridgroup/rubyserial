module RubySerial
  class GenericSerialPort

    def initialize(address, baude_rate, data_bits)
      file_opts = File::RDWR | File::NOCTTY | File::NONBLOCK
      @fd       = IO::sysopen(address, file_opts) 
      @file     = IO.open(@fd, "r+")
      @config   = build_config(baude_rate, data_bits)

      platform_initialize(address, baude_rate, data_bits)
    end

    private

    def method_missing(method_name, *arguments, &block)
      @file.send(method_name, *arguments, &block)
    end

    def build_config(baude_rate, data_bits)
      config = Termios.new

      config[:c_iflag]  = RubySerial::IGNPAR
      config[:c_ispeed] = RubySerial::BAUDE_RATES[baude_rate]
      config[:c_ospeed] = RubySerial::BAUDE_RATES[baude_rate]
      config[:c_cflag]  = RubySerial::DATA_BITS[data_bits] |
        RubySerial::CREAD |
        RubySerial::CLOCAL |
        RubySerial::BAUDE_RATES[baude_rate]

      config[:cc_c][RubySerial::VMIN] = 0

      config
    end

  end
end
