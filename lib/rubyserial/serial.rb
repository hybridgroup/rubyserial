class Serial
  def initialize(address, baude_rate=9600, data_bits=8)
    @serial = RubySerial::SerialPort.new(address, baude_rate, data_bits)
  end

  def method_missing(method_name, *arguments, &block)
    @serial.send(method_name, *arguments, &block)
  end
end