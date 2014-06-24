require 'ffi'
require 'fcntl'

class Serial
  def initialize(address)
    @fd = IO::sysopen(address,Fcntl::O_RDWR|Fcntl::O_NOCTTY|Fcntl::O_NONBLOCK)
    @file = IO.open(@fd, "r+")
    @file.fcntl(Fcntl::F_SETFL, @file.fcntl(Fcntl::F_GETFL, 0) & ~Fcntl::O_NONBLOCK)

    @config = Posix::Termios.new
    @config[:c_iflag] = Posix::IGNPAR
    @config[:c_cflag] = Posix::CS8 | Posix::CREAD | Posix::CLOCAL | Posix::B57600
    @config[:cc_c][Posix::VMIN] = 0
    @config[:c_ispeed] = Posix::B57600
    @config[:c_ospeed] = Posix::B57600

    Posix::ioctl(@fd, Posix::TCSETS, @config)
  end

  def method_missing(method_name, *arguments, &block)
    @file.send(method_name, *arguments, &block)
  end

  module Posix
   extend FFI::Library
    ffi_lib FFI::Library::LIBC

    TCSETS = 0x5402
    IGNPAR = 0000004
    CS5 = 0000000
    CS6 = 0000020
    CS7 = 0000040
    CS8 = 0000060
    CREAD = 0000200
    CLOCAL = 0004000
    VMIN = 6
    NCCS = 19


    B0 = 0000000
    B50 = 0000001
    B75 = 0000002
    B110 = 0000003
    B134 = 0000004
    B150 = 0000005
    B200 = 0000006
    B300 = 0000007
    B600 = 0000010
    B1200 = 0000011
    B1800 = 0000012
    B2400 = 0000013
    B4800 = 0000014
    B9600 = 0000015
    B19200 = 0000016
    B38400 = 0000017
    B57600 = 0010001
    B115200 = 0010002
    B230400 = 0010003
    B460800 = 0010004
    B500000 = 0010005
    B576000 = 0010006
    B921600 = 0010007
    B1000000 = 0010010
    B1152000 = 0010011
    B1500000 = 0010012
    B2000000 = 0010013
    B2500000 = 0010014
    B3000000 = 0010015
    B3500000 = 0010016
    B4000000 = 0010017
    
    class Termios < FFI::Struct
      layout  :c_iflag, :uint,
              :c_oflag, :uint,
              :c_cflag, :uint,
              :c_lflag, :uint,
              :c_line, :uchar,
              :cc_c, [ :uchar, NCCS ],
              :c_ispeed, :uint,
              :c_ospeed, :uint
    end

    attach_function :ioctl, [ :int, :ulong, Termios], :int
  end
end