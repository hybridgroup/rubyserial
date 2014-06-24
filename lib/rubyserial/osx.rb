require 'ffi'

module RubySerial
 extend FFI::Library
  ffi_lib FFI::Library::LIBC

  IGNPAR = 0x00000004
  VMIN = 16
  VTIME = 17
  NCCS = 20
  CLOCAL = 0x00008000
  CREAD = 0x00000800
  TCSANOW = 0 

  DATA_BITS = {
    5 => 0x00000000,
    6 => 0x00000100,
    7 => 0x00000200,
    8 => 0x00000300
  }

  BAUDE_RATES = {
    0 => 0,
    50 => 50,
    75 => 75,
    110 => 110,
    134 => 134,
    150 => 150,
    200 => 200,
    300 => 300,
    600 => 600,
    1200 => 1200,
    1800 => 1800,
    2400 => 2400,
    4800 => 4800,
    9600 => 9600,
    19200 => 19200,
    38400 => 38400,
    7200 =>  7200,
    14400 => 14400,
    28800 => 28800,
    57600 => 57600,
    76800 => 76800,
    115200 => 115200,
    230400 => 230400
  }
            
  class Termios < FFI::Struct
    layout  :c_iflag, :ulong,
            :c_oflag, :ulong,
            :c_cflag, :ulong,
            :c_lflag, :ulong,
            :c_line, :uchar,
            :cc_c, [ :uchar, NCCS ],
            :c_ispeed, :ulong,
            :c_ospeed, :ulong
  end

  attach_function :tcsetattr, [ :int, :int, Termios ], :int

  class SerialPort
    def initialize(address, baude_rate, data_bits)
      @fd = IO::sysopen(address, File::RDWR | File::NOCTTY | File::NONBLOCK)
      @file = IO.open(@fd, "r+")

      @config = Termios.new
      @config[:c_iflag] = RubySerial::IGNPAR
      @config[:c_cflag] = RubySerial::DATA_BITS[data_bits] | RubySerial::CREAD | RubySerial::CLOCAL | RubySerial::BAUDE_RATES[baude_rate]
      @config[:cc_c][RubySerial::VMIN] = 0
      @config[:cc_c][RubySerial::VTIME] = 10
      @config[:c_ispeed] = RubySerial::BAUDE_RATES[baude_rate]
      @config[:c_ospeed] = RubySerial::BAUDE_RATES[baude_rate]

      RubySerial::tcsetattr(@fd, RubySerial::TCSANOW, @config)
    end 

    def method_missing(method_name, *arguments, &block)
      @file.send(method_name, *arguments, &block)
    end
  end
end