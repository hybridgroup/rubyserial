# Copyright (c) 2019 Patrick Plenefisch

require 'rubyserial'
require 'timeout'

describe "serialport" do
  before do
    @ports = []
    if RubySerial::ON_WINDOWS
      @port = "COM3"
    else
      # cu.usbserial-???? on a mac (varies)
      @port = "/dev/ttyUSB0"# SerialPort
    end
    @ser = nil
    begin
      @ser = SerialPort.new(@port, 57600, 8, 1, :none)
    rescue Errno::ENOENT
      skip "Arduino not connected or port number wrong"
    end
  end
  NAR = "narwhales are cool"

  after do
   @ser.close if @ser
  end

	it "should have the arduino" do
		Timeout::timeout(3) do
		#@ser.dtr = true
			dat = @ser.read(1)
			expect(dat).not_to be_nil
			expect(dat.length).to be(1)
			expect(['z', 'w', 'y']).to include(dat)
		end
	end
	it "should read all" do
		sleep 3.2 # ensure some data exists
		Timeout::timeout(1) do
			dat = @ser.readpartial(1024)
			expect(dat).not_to be_nil
			expect(dat.length).to be >= 2
			expect(dat.length).to be <= 512
		end
	end
=begin
	it "should test" do
		puts "start"
		#@ser.dtr = true
		p @ser.read(1)
		p @ser.read(1)
		p "dtr = false"
		#@ser.dtr = false
		p @ser.write("e")
		p @ser.read(1)
		p @ser.read(1)
		p @ser.read(1)
		p @ser.read(1)
		p "dtr = true"
		#@ser.dtr = true
		p @ser.read(1)
		p @ser.read(1)
		p @ser.read(1)
		p @ser.read(1)
		p "dtr = false"
		#@ser.dtr = false
		p @ser.read(1)
		p @ser.read(1)
		p @ser.read(1)
		p @ser.read(1)
	end
=end
	it "should reset" do
		@ser.hupcl = true
		@ser.read_nonblock(1024) rescue nil # remove the old garbage if it exists
		@ser.close
		@ser = SerialPort.new(@port, 57600, 8, 1, :none)
		Timeout::timeout(3) do
			dat = @ser.read(1)
			dat = @ser.read(1) if /[wy]/ === dat
			expect(dat).to eq("z")
		end
	end
	
	
	it "should not reset" do
		Timeout::timeout(4) do
			@ser.hupcl = false
			@ser.close # stil resets
			@ser = SerialPort.new(@port, 57600, 8, 1, :none) # reopen with hupcl set
			
			sleep 0.75 # time for the arduino to reset
			@ser.readpartial(1024) # remove the z
			
			@ser.close # should NOT reset
			@ser = SerialPort.new(@port, 57600, 8, 1, :none)
			expect(@ser.read(1)).not_to eq("z")
		end
	end

	it "should write" do
		Timeout::timeout(2) do
			@ser.write "iy"
			@ser.flush
			@ser.readpartial(1024) # remove the z
			
			@ser << "ex"
			
			dat = @ser.read(4)
			expect(dat).not_to be_nil
			expect(dat).to eq("echo")
		end
	end
	
	it "should timeout" do
		#expect(@ser.readpartial(1024)).to end_with("z")
		Timeout::timeout(2) do
			@ser.write "a12345"
			dat = @ser.readpartial(1024)
			expect(dat).not_to be_nil
			expect(dat).to end_with("12345")
		end
	end
	it "should capture partial" do
		#expect(@ser.readpartial(1024)).to end_with("z")
		Timeout::timeout(2) do
			@ser.write "riiwwwwa12345"
			dat = @ser.readpartial(1024)
			expect(dat).not_to be_nil
			expect(dat).to end_with("AB")
			
			dat = @ser.readpartial(1024)
			expect(dat).not_to be_nil
			expect(dat).to eq("12345")
		end
	end
	it "should wait" do
		#expect(@ser.readpartial(1024)).to end_with("z")
		Timeout::timeout(2) do
			@ser.write "riwewwwwa98765"
			dat = @ser.readpartial(1024) # remove the A
			expect(dat).not_to be_nil
			expect(dat).to end_with("A")
			
			dat = @ser.read(9)
			expect(dat).not_to be_nil
			expect(dat).to eq("echo98765")
		end
	end

	it "should reset (with write)" do
		Timeout::timeout(4) do
			@ser.hupcl = true
			@ser.write_nonblock("eiiiny")
			sleep 0.1
			@ser.readpartial(1024) # remove the garbage
			@ser.close
			@ser = SerialPort.new(@port, 57600, 8, 1, :none)
			
			expect(@ser.read(1)).to eq("z")
			expect(@ser.write_nonblock("iiiiir")).to eq(6)
			expect(@ser.read(3)).to eq("ABC")
		end
	end
	
	
	it "should not reset (with write)" do
		Timeout::timeout(4) do
			@ser.hupcl = false
			@ser.close # stil resets
			@ser = SerialPort.new(@port, 57600, 8, 1, :none) # reopen with hupcl set
			@ser.write "ey"
			sleep 1
			@ser.readpartial(1024) # remove the z
			@ser << "riin"
			@ser.flush # windows flush???
			sleep 0.1
			dat = @ser.read_nonblock(2 + NAR.length)
			expect(dat).to eq("AB#{NAR}")
			
			@ser.close # should NOT reset
			@ser = SerialPort.new(@port, 57600, 8, 1, :none)
			@ser << "ie"
			sleep 0.1
			expect(@ser.readpartial(1024)).to eq("Cecho")
			@ser.hupcl = true
		end
	end
	
	
	it "should support changing baud" do
		Timeout::timeout(6) do
			expect(@ser.read(1)).to eq("z")
			@ser.puts "ye"
			@ser.hupcl = true
			sleep 0.1
			dat = @ser.readpartial(1024)
			if dat.end_with? "echo!!"
				expect(dat).to end_with("echo!!") # mri on windows
			else
				expect(dat).to end_with("echo!")
			end
			
			@ser.print ["b", 19200, 6].pack("aVC")
			@ser.flush
			sleep 0.150 # wait for new baud to appear
			@ser.baud = 19200
			#sleep 1
			#p @ser.readpartial(NAR.length)
			expect(@ser.read(1)).to eq("B")
			@ser << "n"
			sleep 0.1
			dat = @ser.readpartial(NAR.length)
			expect(dat).to eq(NAR)
			
			
			@ser.print ["b", 9600, 6].pack("aVC")
			@ser.flush
			sleep 0.150 # wait for new baud to appear
			@ser.baud = 9600
			expect(@ser.read(1)).to eq("B")
			@ser << "e"
			sleep 0.1
			dat = @ser.readpartial(5)
			expect(dat).to eq("echo")
		end
	end
	
	
	it "should support changing settings" do
		Timeout::timeout(12) do
			expect(@ser.read(1)).to eq("z")
			@ser.puts "ye"
			@ser.hupcl = false
			sleep 0.5
			dat = @ser.readpartial(1024)
			if dat.end_with? "echo!!"
				expect(dat).to end_with("echo!!") # mri on windows
			else
				expect(dat).to end_with("echo!")
			end
			
			@ser.print ["b", 19200, 0x2e].pack("aVC")
			@ser.flush
			sleep 0.050 # wait for new baud to appear
			@ser.baud = 19200
			@ser.data_bits = 8
			@ser.parity = :even
			expect(@ser.stop_bits = 2).to eq(2)
			#sleep 1
			#p @ser.readpartial(NAR.length)
			expect(@ser.read(1)).to eq("B")
			@ser << "n"
			sleep 0.1
			dat = @ser.readpartial(NAR.length)
			expect(dat).to eq(NAR)
			
			
			@ser.print ["b", 19200, 0x34].pack("aVC")
			@ser.flush
			sleep 0.050 # wait for new baud to appear
			@ser.baud = 19200
			@ser.data_bits = 7
			@ser.parity = :odd
			@ser.stop_bits = 1
			expect(@ser.read(1)).to eq("B")
			@ser << "e"
			sleep 0.1
			dat = @ser.readpartial(5)
			expect(dat).to eq("echo")
		end
	end

	it "should be inspectable" do
		@ser.hupcl = true
		expect(@ser.to_s).to start_with "#<SerialPort:0x"
		expect(@ser.inspect).to start_with "#<SerialPort:fd "
		@ser << "x" # reset so that the first tests work
	end

end
