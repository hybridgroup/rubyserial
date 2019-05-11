# Copyright (c) 2014-2016 The Hybrid Group

module RubySerial
  module Posix
  extend FFI::Library
    ffi_lib FFI::Library::LIBC

    O_NONBLOCK = 0x0004
    O_NOCTTY = 0x8000
    O_RDWR = 0x0002
    F_GETFL = 3
    F_SETFL = 4
    VTIME = 17
    TCSANOW = 0

    IGNPAR = 0x00000004
    PARENB = 0x00001000
    PARODD = 0x00002000
    CSTOPB = 0x00000400
    CREAD  = 0x00000800
    CLOCAL = 0x00008000
    VMIN = 16
    NCCS = 20
    CCTS_OFLOW = 0x00010000 # Clearing this disables RTS AND CTS.

    DATA_BITS = {
      5 => 0x00000000,
      6 => 0x00000100,
      7 => 0x00000200,
      8 => 0x00000300
    }

    BAUD_RATES = {
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

    PARITY = {
      :none => 0x00000000,
      :even => PARENB,
      :odd => PARENB | PARODD,
    }

    STOPBITS = {
      1 => 0x00000000,
      2 => CSTOPB
    }

    ERROR_CODES = {
      1 => "EPERM",
      2 => "ENOENT",
      3 => "ESRCH",
      4 => "EINTR",
      5 => "EIO",
      6 => "ENXIO",
      7 => "E2BIG",
      8 => "ENOEXEC",
      9 => "EBADF",
      10 => "ECHILD",
      11 => "EAGAIN",
      12 => "ENOMEM",
      13 => "EACCES",
      14 => "EFAULT",
      15 => "ENOTBLK",
      16 => "EBUSY",
      17 => "EEXIST",
      18 => "EXDEV",
      19 => "ENODEV",
      20 => "ENOTDIR",
      21 => "EISDIR",
      22 => "EINVAL",
      23 => "ENFILE",
      24 => "EMFILE",
      25 => "ENOTTY",
      26 => "ETXTBSY",
      27 => "EFBIG",
      28 => "ENOSPC",
      29 => "ESPIPE",
      30 => "EROFS",
      31 => "EMLINK",
      32 => "EPIPE",
      33 => "EDOM",
      34 => "ERANGE",
      35 => "EDEADLK",
      36 => "ENAMETOOLONG",
      37 => "ENOLCK ",
      38 => "ENOSYS",
      39 => "ENOTEMPTY",
      40 => "ELOOP",

      42 => "ENOMSG",
      43 => "EIDRM",
      44 => "ECHRNG",
      45 => "EL2NSYNC",
      46 => "EL3HLT",
      47 => "EL3RST",
      48 => "ELNRNG",
      49 => "EUNATCH",
      50 => "ENOCSI",
      51 => "EL2HLT",
      52 => "EBADE",
      53 => "EBADR",
      54 => "EXFULL",
      55 => "ENOANO",
      56 => "EBADRQC",
      57 => "EBADSLT",

      59 => "EBFONT",
      60 => "ENOSTR",
      61 => "ENODATA",
      62 => "ETIME",
      63 => "ENOSR",
      64 => "ENONET",
      65 => "ENOPKG",
      66 => "EREMOTE",
      67 => "ENOLINK",
      68 => "EADV",
      69 => "ESRMNT",
      70 => "ECOMM",
      71 => "EPROTO",
      72 => "EMULTIHOP",
      73 => "EDOTDOT",
      74 => "EBADMSG",
      75 => "EOVERFLOW",
      76 => "ENOTUNIQ",
      77 => "EBADFD",
      78 => "EREMCHG",
      79 => "ELIBACC",
      80 => "ELIBBAD",
      81 => "ELIBSCN",
      82 => "ELIBMAX",
      83 => "ELIBEXEC",
      84 => "EILSEQ",
      85 => "ERESTART",
      86 => "ESTRPIPE",
      87 => "EUSERS",
      88 => "ENOTSOCK",
      89 => "EDESTADDRREQ",
      90 => "EMSGSIZE",
      91 => "EPROTOTYPE",
      92 => "ENOPROTOOPT",
      93 => "EPROTONOSUPPORT",
      94 => "ESOCKTNOSUPPORT",
      95 => "EOPNOTSUPP",
      96 => "EPFNOSUPPORT",
      97 => "EAFNOSUPPORT",
      98 => "EADDRINUSE",
      99 => "EADDRNOTAVAIL",
      100 => "ENETDOWN",
      101 => "ENETUNREACH",
      102 => "ENETRESET",
      103 => "ECONNABORTED",
      104 => "ECONNRESET",
      105 => "ENOBUFS",
      106 => "EISCONN",
      107 => "ENOTCONN",
      108 => "ESHUTDOWN",
      109 => "ETOOMANYREFS",
      110 => "ETIMEDOUT",
      111 => "ECONNREFUSED",
      112 => "EHOSTDOWN",
      113 => "EHOSTUNREACH",
      114 => "EALREADY",
      115 => "EINPROGRESS",
      116 => "ESTALE",
      117 => "EUCLEAN",
      118 => "ENOTNAM",
      119 => "ENAVAIL",
      120 => "EISNAM",
      121 => "EREMOTEIO",
      122 => "EDQUOT",
      123 => "ENOMEDIUM",
      124 => "EMEDIUMTYPE",
      125 => "ECANCELED",
      126 => "ENOKEY",
      127 => "EKEYEXPIRED",
      128 => "EKEYREVOKED",
      129 => "EKEYREJECTED",
      130 => "EOWNERDEAD",
      131 => "ENOTRECOVERABLE"
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

    attach_function :ioctl, [ :int, :ulong, RubySerial::Posix::Termios], :int, blocking: true
    attach_function :tcsetattr, [ :int, :int, RubySerial::Posix::Termios ], :int, blocking: true
    attach_function :fcntl, [:int, :int, :varargs], :int, blocking: true
    attach_function :open, [:pointer, :int], :int, blocking: true
    attach_function :close, [:int], :int, blocking: true
    attach_function :write, [:int, :pointer,  :int],:int, blocking: true
    attach_function :read, [:int, :pointer,  :int],:int, blocking: true
  end
end
