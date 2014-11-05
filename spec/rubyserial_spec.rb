require 'rubyserial'

describe "rubyserial" do
  before do
    @ports = []
    require 'rbconfig'
    if RbConfig::CONFIG['host_os'] =~ /mswin|windows|mingw/i
      @command_output = `powershell "Get-WmiObject Win32_SerialPort | Select-Object DeviceID, Description"`
      @prefix = "\\\\.\\"
      @coms = @command_output.scan(/COM\d*/).uniq
      @file_array = @command_output.split("\n")
      @file_array.each do |line|
        if line.include?('com0com')
          @coms.each do |e|
            if line =~ /#{e}/
              @ports << "#{@prefix}#{e}"
            end
          end
        end
      end

      if @ports[0].nil?
        puts "Heya mister (or miss(es)). For this to work you need com0com "\
        "installed. It doesn't look like you have it so rerun this after you"\
        "install it from here: https://code.google.com/p/powersdr-iq/download"\
        "s/detail?name=setup_com0com_W7_x64_signed.exe&can=2&q="
      end
    else
      File.delete('socat.log') if File.file?('socat.log')

      Thread.new do
        system('socat -lf socat.log -d -d pty,raw,echo=0 pty,raw,echo=0')
      end

      @ptys = nil

      loop do
        if File.file? 'socat.log'
          @file = File.open('socat.log', "r")
          @fileread = @file.read

          unless @fileread.count("\n") < 3
            @ptys = @fileread.scan(/PTY is (.*)/)
            break
          end
        end
      end

      @ports = [@ptys[1][0], @ptys[0][0]]
    end

    @sp2 = Serial.new(@ports[0])
    @sp = Serial.new(@ports[1])
  end

  after do
   @sp2.close
   @sp.close
  end

  it "should read and write" do
    @sp2.write('hello')
    # small delay so it can write to the other port.
    sleep 0.1
    check = @sp.read(5)
    expect(check).to eql('hello')
  end

  it "should convert ints to strings" do
    expect(@sp2.write(123)).to eql(3)
    sleep 0.1
    expect(@sp.read(3)).to eql('123')
  end

  it "write should return bytes written" do
    expect(@sp2.write('hello')).to eql(5)
  end

  it "reading nothing should be blank" do
    expect(@sp.read(5)).to eql('')
  end

  it "should give me nil on getbyte" do
    expect(@sp.getbyte).to be_nil
  end

  it "should give me bytes" do
    @sp2.write('hello')
    # small delay so it can write to the other port.
    sleep 0.1
    check = @sp.getbyte
    expect([check].pack('C')).to eql('h')
  end


  describe "giving me lines" do
    it "should give me a line" do
      @sp.write("no yes \n hello")
      sleep 0.1
      expect(@sp2.gets).to eql("no yes \n")
    end

    it "should accept a sep param" do
      @sp.write('no yes END bleh')
      sleep 0.1
      expect(@sp2.gets('END')).to eql("no yes END")
    end

    it "should accept a limit param" do
      @sp.write("no yes \n hello")
      sleep 0.1
      expect(@sp2.gets(4)).to eql("no y")
    end

    it "should accept limit and sep params" do
      @sp.write("no yes END hello")
      sleep 0.1
      expect(@sp2.gets('END', 20)).to eql("no yes END")
      @sp2.read(1000)
      @sp.write("no yes END hello")
      sleep 0.1
      expect(@sp2.gets('END', 4)).to eql('no y')
    end

    it "should read a paragraph at a time" do
      @sp.write("Something \n Something else \n\n and other stuff")
      sleep 0.1
      expect(@sp2.gets('')).to eql("Something \n Something else \n\n")
    end
  end
end
