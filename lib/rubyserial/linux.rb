require_relative 'linux_constants'

module RubySerial

  include RubySerial::LinuxConstants

  class LinuxSerialPort < GenericSerialPort

    def platform_initialize(address, baude_rate, data_bits)
      RubySerial::ioctl(@fd, TCSETS, @config)
    end

  end

end
