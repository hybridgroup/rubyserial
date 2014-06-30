module RubySerial
  # wraps the native Windows API functions for file IO and COMM port found in kernel32.dll
  module Win32
    extend FFI::Library
    ffi_lib 'kernel32'
    ffi_convention :stdcall

    [
      [ :GetLastError,    [],  :uint32],
      [ :CreateFileA,     [:pointer, :uint32, :uint32, :pointer, :uint32, :uint32, :pointer],  :pointer],
      # CreateFile first argument is a const char*
      # Windows can decide to read it as a C string (1 char = 1 byte) or a unicode string (1 char = 2 byte)
      # the real dll functions are actually CreateFileA for the C strings and CreateFileW for unicode
      # I strongly suggest to use CreateFileA since FFI will automatically write a C string from Ruby string
      [ :CloseHandle,     [:pointer],  :int],
      [ :ReadFile,        [:pointer, :pointer, :uint32, :pointer, :pointer],    :int32],
      [ :WriteFile,       [:pointer, :pointer, :uint32, :pointer, :pointer],    :int32],
      [ :GetCommState,    [:pointer, :pointer], :int32],
      [ :SetCommState,    [:pointer, :pointer], :int32],
      [ :GetCommTimeouts, [:pointer, :pointer], :int32],
      [ :SetCommTimeouts, [:pointer, :pointer], :int32],
    ].each{ |sig| attach_function *sig }

    def self.error_check
      self::GetLastError().tap{ |err| puts "error: %i | 0x%.8x" % [err,err] if err != 0 }
    end

    # consts from Windows seven sdk. extract with
    # grep -i "generic_read" *.h
    # from the /Include directory
    FILE_SHARE_DELETE = 0x00000004
    FILE_SHARE_READ   = 0x00000001
    FILE_SHARE_WRITE  = 0x00000002
    FILE_SHARE_ALL    = FILE_SHARE_WRITE | FILE_SHARE_READ | FILE_SHARE_DELETE
    GENERIC_READ  = 0x80000000
    GENERIC_WRITE = 0x40000000
    CREATE_NEW    = 1
    CREATE_ALWAYS = 2
    OPEN_EXISTING = 3
    OPEN_ALWAYS   = 4
    FILE_ATTRIBUTE_NORMAL = 0x00000080

    # this struct is used by windows to configure the COMM port
    class DCB < FFI::Struct
      layout  :dcblength,   :uint32,
              :baudrate,    :uint32,
              :flags,       :uint32,    # :flag is actually a bit fields compound:
              :wreserved,   :uint16,    #   uint32 fBinary :1;
              :xonlim,      :uint16,    #   uint32 fParity :1;
              :xofflim,     :uint16,    #   uint32 fParity :1;
              :bytesize,    :uint8,     #   uint32 fOutxCtsFlow :1;
              :parity,      :uint8,     #   uint32 fOutxDsrFlow :1;
              :stopbits,    :uint8,     #   uint32 fDtrControl :2;
              :xonchar,     :int8,      #   uint32 fDsrSensitivity :1;
              :xoffchar,    :int8,      #   uint32 fTXContinueOnXoff :1;
              :errorchar,   :int8,      #   uint32 fOutX :1;
              :eofchar,     :int8,      #   uint32 fInX :1;
              :evtchar,     :int8,      #   uint32 fErrorChar :1;
              :wreserved1,  :uint16     #   uint32 fNull :1;
                                        #   uint32 fRtsControl :2;
                                        #   uint32 fAbortOnError :1;
                                        #   uint32 fDummy2 :17;
      Sizeof      = 28 # this is used to tell windows the size of its own struct,
      ONESTOPBIT  = 0  #   not sure why necessary (different Windows versions ?)
      NOPARITY    = 0
    end

    # this struct is used to set timeout properties of the opened COM ports
    class CommTimeouts < FFI::Struct
      layout  :read_interval_timeout,           :uint32,
              :read_total_timeout_multiplier,   :uint32,
              :read_total_timeout_constant,     :uint32,
              :write_total_timeout_multiplier,  :uint32,
              :write_total_timeout_constant,    :uint32
    end
  end
end