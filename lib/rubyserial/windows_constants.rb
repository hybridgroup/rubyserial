# Copyright (c) 2014-2016 The Hybrid Group
# Copyright (c) 2019 Patrick Plenefisch


module RubySerial
  # @api private
  # @!visibility private
  ENOTTY_MAP="ENOTTY"
  # @api private
  # @!visibility private
  module WinC
    extend FFI::Library
    ffi_lib 'msvcrt'
    ffi_convention :stdcall

    attach_function :_open_osfhandle,     [:pointer, :int], :int, blocking: true
    attach_function :_get_osfhandle,     [:int], :pointer, blocking: true
  end

  # @api private
  # @!visibility private
  module Win32
    extend FFI::Library
    ffi_lib 'kernel32'
    ffi_convention :stdcall

    GENERIC_READ  = 0x80000000
    GENERIC_WRITE = 0x40000000
    OPEN_EXISTING = 3

    ERROR_CODES = {
      5 => "ERROR_ACCESS_DENIED",
      57 => "ERROR_ADAP_HDW_ERR",
      85 => "ERROR_ALREADY_ASSIGNED",
      183 => "ERROR_ALREADY_EXISTS",
      7 => "ERROR_ARENA_TRASHED",
      174 => "ERROR_ATOMIC_LOCKS_NOT_SUPPORTED",
      199 => "ERROR_AUTODATASEG_EXCEEDS_64k",
      160 => "ERROR_BAD_ARGUMENTS",
      22 => "ERROR_BAD_COMMAND",
      66 => "ERROR_BAD_DEV_TYPE",
      119 => "ERROR_BAD_DRIVER_LEVEL",
      10 => "ERROR_BAD_ENVIRONMENT",
      193 => "ERROR_BAD_EXE_FORMAT",
      222 => "ERROR_BAD_FILE_TYPE",
      11 => "ERROR_BAD_FORMAT",
      24 => "ERROR_BAD_LENGTH",
      67 => "ERROR_BAD_NET_NAME",
      58 => "ERROR_BAD_NET_RESP",
      53 => "ERROR_BAD_NETPATH",
      161 => "ERROR_BAD_PATHNAME",
      230 => "ERROR_BAD_PIPE",
      60 => "ERROR_BAD_REM_ADAP",
      159 => "ERROR_BAD_THREADID_ADDR",
      20 => "ERROR_BAD_UNIT",
      109 => "ERROR_BROKEN_PIPE",
      111 => "ERROR_BUFFER_OVERFLOW",
      142 => "ERROR_BUSY_DRIVE",
      170 => "ERROR_BUSY",
      120 => "ERROR_CALL_NOT_IMPLEMENTED",
      173 => "ERROR_CANCEL_VIOLATION",
      266 => "ERROR_CANNOT_COPY",
      82 => "ERROR_CANNOT_MAKE",
      221 => "ERROR_CHECKOUT_REQUIRED",
      129 => "ERROR_CHILD_NOT_COMPLETE",
      23 => "ERROR_CRC",
      16 => "ERROR_CURRENT_DIRECTORY",
      303 => "ERROR_DELETE_PENDING",
      55 => "ERROR_DEV_NOT_EXIST",
      145 => "ERROR_DIR_NOT_EMPTY",
      144 => "ERROR_DIR_NOT_ROOT",
      130 => "ERROR_DIRECT_ACCESS_HANDLE",
      267 => "ERROR_DIRECTORY",
      157 => "ERROR_DISCARDED",
      107 => "ERROR_DISK_CHANGE",
      112 => "ERROR_DISK_FULL",
      302 => "ERROR_DISK_TOO_FRAGMENTED",
      108 => "ERROR_DRIVE_LOCKED",
      52 => "ERROR_DUP_NAME",
      196 => "ERROR_DYNLINK_FROM_INVALID_RING",
      276 => "ERROR_EA_FILE_CORRUPT",
      255 => "ERROR_EA_LIST_INCONSISTENT",
      277 => "ERROR_EA_TABLE_FULL",
      275 => "ERROR_EAS_DIDNT_FIT",
      282 => "ERROR_EAS_NOT_SUPPORTED",
      203 => "ERROR_ENVVAR_NOT_FOUND",
      101 => "ERROR_EXCL_SEM_ALREADY_OWNED",
      217 => "ERROR_EXE_CANNOT_MODIFY_SIGNED_BINARY",
      218 => "ERROR_EXE_CANNOT_MODIFY_STRONG_SIGNED_BINARY",
      216 => "ERROR_EXE_MACHINE_TYPE_MISMATCH",
      192 => "ERROR_EXE_MARKED_INVALID",
      83 => "ERROR_FAIL_I24",
      350 => "ERROR_FAIL_NOACTION_REBOOT",
      352 => "ERROR_FAIL_RESTART",
      351 => "ERROR_FAIL_SHUTDOWN",
      220 => "ERROR_FILE_CHECKED_OUT",
      80 => "ERROR_FILE_EXISTS",
      2 => "ERROR_FILE_NOT_FOUND",
      223 => "ERROR_FILE_TOO_LARGE",
      206 => "ERROR_FILENAME_EXCED_RANGE",
      224 => "ERROR_FORMS_AUTH_REQUIRED",
      31 => "ERROR_GEN_FAILURE",
      39 => "ERROR_HANDLE_DISK_FULL",
      38 => "ERROR_HANDLE_EOF",
      308 => "ERROR_IMAGE_SUBSYSTEM_NOT_PRESENT",
      304 => "ERROR_INCOMPATIBLE_WITH_GLOBAL_SHORT_NAME_REGISTRY_SETTING",
      202 => "ERROR_INFLOOP_IN_RELOC_CHAIN",
      122 => "ERROR_INSUFFICIENT_BUFFER",
      12 => "ERROR_INVALID_ACCESS",
      487 => "ERROR_INVALID_ADDRESS",
      104 => "ERROR_INVALID_AT_INTERRUPT_TIME",
      9 => "ERROR_INVALID_BLOCK",
      117 => "ERROR_INVALID_CATEGORY",
      13 => "ERROR_INVALID_DATA",
      15 => "ERROR_INVALID_DRIVE",
      278 => "ERROR_INVALID_EA_HANDLE",
      254 => "ERROR_INVALID_EA_NAME",
      151 => "ERROR_INVALID_EVENT_COUNT",
      191 => "ERROR_INVALID_EXE_SIGNATURE",
      186 => "ERROR_INVALID_FLAG_NUMBER",
      1 => "ERROR_INVALID_FUNCTION",
      6 => "ERROR_INVALID_HANDLE",
      124 => "ERROR_INVALID_LEVEL",
      153 => "ERROR_INVALID_LIST_FORMAT",
      307 => "ERROR_INVALID_LOCK_RANGE",
      195 => "ERROR_INVALID_MINALLOCSIZE",
      190 => "ERROR_INVALID_MODULETYPE",
      123 => "ERROR_INVALID_NAME",
      301 => "ERROR_INVALID_OPLOCK_PROTOCOL",
      182 => "ERROR_INVALID_ORDINAL",
      87 => "ERROR_INVALID_PARAMETER",
      86 => "ERROR_INVALID_PASSWORD",
      198 => "ERROR_INVALID_SEGDPL",
      180 => "ERROR_INVALID_SEGMENT_NUMBER",
      209 => "ERROR_INVALID_SIGNAL_NUMBER",
      189 => "ERROR_INVALID_STACKSEG",
      188 => "ERROR_INVALID_STARTING_CODESEG",
      114 => "ERROR_INVALID_TARGET_HANDLE",
      118 => "ERROR_INVALID_VERIFY_SWITCH",
      197 => "ERROR_IOPL_NOT_ENABLED",
      147 => "ERROR_IS_JOIN_PATH",
      133 => "ERROR_IS_JOIN_TARGET",
      134 => "ERROR_IS_JOINED",
      146 => "ERROR_IS_SUBST_PATH",
      149 => "ERROR_IS_SUBST_TARGET",
      135 => "ERROR_IS_SUBSTED",
      194 => "ERROR_ITERATED_DATA_EXCEEDS_64k",
      138 => "ERROR_JOIN_TO_JOIN",
      140 => "ERROR_JOIN_TO_SUBST",
      154 => "ERROR_LABEL_TOO_LONG",
      167 => "ERROR_LOCK_FAILED",
      33 => "ERROR_LOCK_VIOLATION",
      212 => "ERROR_LOCKED",
      353 => "ERROR_MAX_SESSIONS_REACHED",
      164 => "ERROR_MAX_THRDS_REACHED",
      208 => "ERROR_META_EXPANSION_TOO_LONG",
      126 => "ERROR_MOD_NOT_FOUND",
      234 => "ERROR_MORE_DATA",
      317 => "ERROR_MR_MID_NOT_FOUND",
      131 => "ERROR_NEGATIVE_SEEK",
      215 => "ERROR_NESTING_NOT_ALLOWED",
      88 => "ERROR_NET_WRITE_FAULT",
      64 => "ERROR_NETNAME_DELETED",
      65 => "ERROR_NETWORK_ACCESS_DENIED",
      54 => "ERROR_NETWORK_BUSY",
      232 => "ERROR_NO_DATA",
      18 => "ERROR_NO_MORE_FILES",
      259 => "ERROR_NO_MORE_ITEMS",
      113 => "ERROR_NO_MORE_SEARCH_HANDLES",
      89 => "ERROR_NO_PROC_SLOTS",
      205 => "ERROR_NO_SIGNAL_SENT",
      62 => "ERROR_NO_SPOOL_SPACE",
      125 => "ERROR_NO_VOLUME_LABEL",
      26 => "ERROR_NOT_DOS_DISK",
      8 => "ERROR_NOT_ENOUGH_MEMORY",
      136 => "ERROR_NOT_JOINED",
      158 => "ERROR_NOT_LOCKED",
      288 => "ERROR_NOT_OWNER",
      21 => "ERROR_NOT_READY",
      17 => "ERROR_NOT_SAME_DEVICE",
      137 => "ERROR_NOT_SUBSTED",
      50 => "ERROR_NOT_SUPPORTED",
      309 => "ERROR_NOTIFICATION_GUID_ALREADY_DEFINED",
      110 => "ERROR_OPEN_FAILED",
      300 => "ERROR_OPLOCK_NOT_GRANTED",
      28 => "ERROR_OUT_OF_PAPER",
      84 => "ERROR_OUT_OF_STRUCTURES",
      14 => "ERROR_OUTOFMEMORY",
      299 => "ERROR_PARTIAL_COPY",
      148 => "ERROR_PATH_BUSY",
      3 => "ERROR_PATH_NOT_FOUND",
      231 => "ERROR_PIPE_BUSY",
      229 => "ERROR_PIPE_LOCAL",
      233 => "ERROR_PIPE_NOT_CONNECTED",
      63 => "ERROR_PRINT_CANCELLED",
      61 => "ERROR_PRINTQ_FULL",
      127 => "ERROR_PROC_NOT_FOUND",
      402 => "ERROR_PROCESS_MODE_ALREADY_BACKGROUND",
      403 => "ERROR_PROCESS_MODE_NOT_BACKGROUND",
      30 => "ERROR_READ_FAULT",
      72 => "ERROR_REDIR_PAUSED",
      201 => "ERROR_RELOC_CHAIN_XEEDS_SEGLIM",
      51 => "ERROR_REM_NOT_LIST",
      71 => "ERROR_REQ_NOT_ACCEP",
      207 => "ERROR_RING2_STACK_IN_USE",
      200 => "ERROR_RING2SEG_MUST_BE_MOVABLE",
      143 => "ERROR_SAME_DRIVE",
      318 => "ERROR_SCOPE_NOT_FOUND",
      27 => "ERROR_SECTOR_NOT_FOUND",
      306 => "ERROR_SECURITY_STREAM_IS_INCONSISTENT",
      132 => "ERROR_SEEK_ON_DEVICE",
      25 => "ERROR_SEEK",
      102 => "ERROR_SEM_IS_SET",
      187 => "ERROR_SEM_NOT_FOUND",
      105 => "ERROR_SEM_OWNER_DIED",
      121 => "ERROR_SEM_TIMEOUT",
      106 => "ERROR_SEM_USER_LIMIT",
      36 => "ERROR_SHARING_BUFFER_EXCEEDED",
      70 => "ERROR_SHARING_PAUSED",
      32 => "ERROR_SHARING_VIOLATION",
      305 => "ERROR_SHORT_NAMES_NOT_ENABLED_ON_VOLUME",
      162 => "ERROR_SIGNAL_PENDING",
      156 => "ERROR_SIGNAL_REFUSED",
      141 => "ERROR_SUBST_TO_JOIN",
      139 => "ERROR_SUBST_TO_SUBST",
      0 => "ERROR_SUCCESS",
      150 => "ERROR_SYSTEM_TRACE",
      210 => "ERROR_THREAD_1_INACTIVE",
      400 => "ERROR_THREAD_MODE_ALREADY_BACKGROUND",
      401 => "ERROR_THREAD_MODE_NOT_BACKGROUND",
      56 => "ERROR_TOO_MANY_CMDS",
      214 => "ERROR_TOO_MANY_MODULES",
      152 => "ERROR_TOO_MANY_MUXWAITERS",
      68 => "ERROR_TOO_MANY_NAMES",
      4 => "ERROR_TOO_MANY_OPEN_FILES",
      298 => "ERROR_TOO_MANY_POSTS",
      103 => "ERROR_TOO_MANY_SEM_REQUESTS",
      100 => "ERROR_TOO_MANY_SEMAPHORES",
      69 => "ERROR_TOO_MANY_SESS",
      155 => "ERROR_TOO_MANY_TCBS",
      59 => "ERROR_UNEXP_NET_ERR",
      240 => "ERROR_VC_DISCONNECTED",
      226 => "ERROR_VIRUS_DELETED",
      225 => "ERROR_VIRUS_INFECTED",
      128 => "ERROR_WAIT_NO_CHILDREN",
      29 => "ERROR_WRITE_FAULT",
      19 => "ERROR_WRITE_PROTECT",
      34 => "ERROR_WRONG_DISK",
      258 => "WAIT_TIMEOUT"
    }

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
      Sizeof      = 28
      ONESTOPBIT  = 0
      TWOSTOPBITS  = 2

      STOPBITS = {
        1 => ONESTOPBIT,
        2 => TWOSTOPBITS
      }

      NOPARITY    = 0
      ODDPARITY   = 1
      EVENPARITY  = 2
      PARITY = {
        :none => NOPARITY,
        :odd  => ODDPARITY,
        :even => EVENPARITY
      }

      FLAGS_RTS = 0x3000

      DTR_MASK = 48
      DTR_ENABLED = 16

      # debug function to return all values as an array
      def dbg_a
        [ :dcblength,
              :baudrate,
              :flags,
              :wreserved,
              :xonlim,
              :xofflim,
              :bytesize,
              :parity,
              :stopbits,
              :xonchar,
              :xoffchar,
              :errorchar,
              :eofchar,
              :evtchar,
              :wreserved1].map{|x|self[x]}
      end
    end

    class CommTimeouts < FFI::Struct
      layout  :read_interval_timeout,           :uint32,
              :read_total_timeout_multiplier,   :uint32,
              :read_total_timeout_constant,     :uint32,
              :write_total_timeout_multiplier,  :uint32,
              :write_total_timeout_constant,    :uint32

      # debug function to return all values as an array
      def dbg_a
        [:read_interval_timeout,
              :read_total_timeout_multiplier,
              :read_total_timeout_constant,
              :write_total_timeout_multiplier,
              :write_total_timeout_constant].map{|f| self[f]}
      end

      READ_MODES = {
        :blocking => [0, 0, 0],
        :partial => [2, 0, 0],
        :nonblocking => [0xffff_ffff, 0, 0]
      }
    end

    attach_function :SetupComm,       [:pointer, :uint32, :uint32], :int32, blocking: true
    attach_function :GetCommState,    [:pointer, RubySerial::Win32::DCB], :int32, blocking: true
    attach_function :SetCommState,    [:pointer, RubySerial::Win32::DCB], :int32, blocking: true
    attach_function :GetCommTimeouts, [:pointer, RubySerial::Win32::CommTimeouts], :int32, blocking: true
    attach_function :SetCommTimeouts, [:pointer, RubySerial::Win32::CommTimeouts], :int32, blocking: true
    # TODO, expose this?
    attach_function :EscapeCommFunction,       [:pointer, :uint32], :int32, blocking: true
  end
end
