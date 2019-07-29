# Copyright (c) 2019 Patrick Plenefisch

require 'rubyserial'
require 'timeout'

describe "serialport api" do
  before do
    @ports = []
    if RubySerial::ON_WINDOWS
      @port = "COM1" #TODO...
      @not_a_port = nil
    else
      # Use ttys0 on a mac
      @port = "/dev/ttyS0"# SerialPort
      @not_a_port = "/dev/null"
      @not_a_file = "/dev/not_a_file"
    end
  end

	it "should support new" do
		s = SerialPort.new(@port)
		expect(s.closed?).to be false
		expect(s.name).to eq @port
		expect(s).to be_an IO
		s.close
		expect(s.closed?).to be true
	end
	
	it "should only support serial ports" do
		skip "Not supported on windows" if @not_a_port.nil?
		expect {
			s = SerialPort.new(@not_a_port)
			s.close
		}.to raise_error(ArgumentError, "not a serial port")
		
		expect {
			s = SerialPort.new(@not_a_file)
			s.close
		}.to raise_error(Errno::ENOENT, /No such file or directory .*- #{@not_a_file}/)
	end
	
	
	it "should only support serial ports (serial API)" do
		skip "Not supported on windows" if @not_a_port.nil?
		expect {
			s = Serial.new(@not_a_port)
			s.close
		}.to raise_error(RubySerial::Error, /^ENO/)
		
		expect {
			s = Serial.new(@not_a_file)
			s.close
		}.to raise_error(Errno::ENOENT, /No such file or directory .*- #{@not_a_file}/)
	end
	
	it "should support named args" do
		s = SerialPort.new(@port, "baud" => 9600, "data_bits" => 8)
		expect(s.baud).to eq 9600
		expect(s.data_bits).to eq 8
		s.close
	end
	it "should support open" do
		outers = nil
		SerialPort.open(@port) do |s|
			outers = s
			expect(s.closed?).to be false
			expect(s.name).to eq @port
			expect(s).to be_an IO
		end
		expect(outers.closed?).to be true
	end
	it "should support open args" do
		SerialPort.open(@port, 19200, 7, 2, :odd) do |s|
			expect(s.baud).to eq 19200
			expect(s.data_bits).to eq 7
			expect(s.stop_bits).to eq 2
			expect(s.parity).to eq :odd
		end
	end
	
	it "should support open named args" do
		SerialPort.open(@port, "baud" => 57600,  "data_bits" => 6, "stop_bits" => 1, "parity" => :even) do |s|
			expect(s.baud).to eq 57600
			expect(s.data_bits).to eq 6
			expect(s.stop_bits).to eq 1
			expect(s.parity).to eq :even
		end
	end
	
	it "should support changing values" do
		SerialPort.open(@port, "baud" => 9600,  "data_bits" => 7, "stop_bits" => 2, "parity" => :odd) do |s|
			expect(s.baud).to eq 9600
			expect(s.data_bits).to eq 7
			expect(s.stop_bits).to eq 2
			expect(s.parity).to eq :odd
			
			expect(s.baud=19200).to eq 19200
			expect(s.baud).to eq 19200
			expect(s.data_bits).to eq 7
			expect(s.stop_bits).to eq 2
			expect(s.parity).to eq :odd
			
			expect(s.data_bits=8).to eq 8
			expect(s.baud).to eq 19200
			expect(s.data_bits).to eq 8
			expect(s.stop_bits).to eq 2
			expect(s.parity).to eq :odd
			
			expect(s.parity=:none).to eq :none
			expect(s.baud).to eq 19200
			expect(s.data_bits).to eq 8
			expect(s.stop_bits).to eq 2
			expect(s.parity).to eq :none
			
			expect(s.stop_bits=1).to eq 1
			expect(s.baud).to eq 19200
			expect(s.data_bits).to eq 8
			expect(s.stop_bits).to eq 1
			expect(s.parity).to eq :none
		end
	end
	
	it "should support hupcl" do
		SerialPort.open(@port) do |s|
			expect(s.hupcl = true).to eq true
			expect(s.hupcl).to eq true
			s.baud=19200 # re-get the values
			expect(s.hupcl).to eq true 
			expect(s.hupcl = false).to eq false
			expect(s.hupcl).to eq false
			s.baud=9600 # re-get the values
			expect(s.hupcl).to eq false
			expect(s.hupcl = true).to eq true
			expect(s.hupcl).to eq true
			s.baud=19200 # re-get the values
			expect(s.hupcl).to eq true 
		end
	end
end
