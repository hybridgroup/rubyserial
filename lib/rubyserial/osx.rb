require_relative 'osx_constants'

module RubySerial

  include OSXConstants

  class OSXSerialPort < GenericSerialPort

    def platform_initialize(address, baude_rate, data_bits)
      @config[:cc_c][RubySerial::VTIME] = 10

      RubySerial::tcsetattr(@fd, RubySerial::TCSANOW, @config)
    end

  end

end
