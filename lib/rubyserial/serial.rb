class Serial

  def initialize(address, baude_rate=9600, data_bits=8)
    case CONFIG['host_os']
    when /linux/i
      require 'rubyserial/linux'
      @serial = RubySerial::LinuxSerialPort.new(address, baude_rate, data_bits)
    when /mswin|windows/i
      raise "windows not implemented"
      #require 'rubyserial/windows'
      #@serial = RubySerial::WindowsSerialPort.new(address, baude_rate, data_bits)
    when /darwin/i
      require 'rubyserial/osx'
      @serial = RubySerial::OSXSerialPort.new(address, baude_rate, data_bits)
    else
      raise "Unknown environment"
    end

  end

  def method_missing(method_name, *arguments, &block)
    @serial.send(method_name, *arguments, &block)
  end

end
