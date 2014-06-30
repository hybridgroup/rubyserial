require 'ffi'

module RubySerial
  module Posix
  extend FFI::Library
    ffi_lib FFI::Library::LIBC

    O_NONBLOCK = 00004000
    O_NOCTTY = 00000400
    O_RDWR = 00000002
    F_GETFL = 3
    F_SETFL = 4
    VTIME = 5
    TCSANOW = 0
    TCSETS = 0x5402
    IGNPAR = 0000004
    CREAD = 0000200
    CLOCAL = 0004000
    VMIN = 6
    NCCS = 19

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
      20 => "ENOTDIR ",
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

    attach_function :ioctl, [ :int, :ulong, RubySerial::Posix::Termios], :int
    attach_function :tcsetattr, [ :int, :int, RubySerial::Posix::Termios ], :int
    attach_function :fcntl, [:int, :int, :varargs], :int
    attach_function :open, [:pointer, :int], :int
    attach_function :close, [:int], :int
    attach_function :write, [:int, :pointer,  :int],:int
    attach_function :read, [:int, :pointer,  :int],:int
  end
end