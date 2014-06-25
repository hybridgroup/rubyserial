require 'ffi'

module RubySerial

  NCCS = 20
  #NCCS = 19

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
  attach_function :ioctl, [ :int, :ulong, Termios], :int

end
