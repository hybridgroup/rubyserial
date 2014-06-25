require 'ffi'

module RubySerial
  module Posix
  extend FFI::Library
    ffi_lib FFI::Library::LIBC

    NCCS = 19
    TCSETS = 0x5402
    IGNPAR = 0000004
    CREAD = 0000200
    CLOCAL = 0004000
    VMIN = 6
    VTIME = 5
    TCSANOW = 0

    DATA_BITS = {
      5 => 0000000,
      6 => 0000020,
      7 => 0000040,
      8 => 0000060
    }

    BAUDE_RATES = {
      0 => 0000000,
      50 => 0000001,
      75 => 0000002,
      110 => 0000003,
      134 => 0000004,
      150 => 0000005,
      200 => 0000006,
      300 => 0000007,
      600 => 0000010,
      1200 => 0000011,
      1800 => 0000012,
      2400 => 0000013,
      4800 => 0000014,
      9600 => 0000015,
      19200 => 0000016,
      38400 => 0000017,
      57600 => 0010001,
      115200 => 0010002,
      230400 => 0010003,
      460800 => 0010004,
      500000 => 0010005,
      576000 => 0010006,
      921600 => 0010007,
      1000000 => 0010010,
      1152000 => 0010011,
      1500000 => 0010012,
      2000000 => 0010013,
      2500000 => 0010014,
      3000000 => 0010015,
      3500000 => 0010016,
      4000000 => 0010017
    }

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

    attach_function :tcsetattr, [ :int, :int, RubySerial::Posix::Termios ], :int
  end
end