# Copyright (c) 2014-2016 The Hybrid Group

class RubySerial::Builder
  def self.build(address: , parent: IO, baud: 9600, data_bits: 8, parity: :none, stop_bits: 1, blocking: true, clear_config: true, winfix: :auto) # TODO: blocking & clear_config
    fd = IO::sysopen("\\\\.\\#{address}", File::RDWR)

    # enable blocking mode TODO

    hndl = RubySerial::WinC._get_osfhandle(fd)
    # TODO: check errno

    winfix_out = [] # TODO: remove winfix
    # Update the terminal settings
    _reconfigure(winfix_out, hndl, clear_config, baud: baud, data_bits: data_bits, parity: parity, stop_bits: stop_bits) # TODO: min: (blocking ? 1 : 0),

    ffi_call :SetupComm, hndl, 64, 64

    win32_update_readmode :blocking, hndl

    file = parent.send(:for_fd, fd, File::RDWR)
    # windows has no idea
    #unless file.tty?
    #  raise ArgumentError, "not a serial port: #{address}"
    #end
    file._win32_hndl = hndl
    file._winfix = winfix
    #file.dtr = false
    [file, address, fd]
  end

  WIN32_READMODES = {
    :blocking => [0, 0, 0],
    :partial => [2, 0, 0],
    :nonblocking => [0xffff_ffff, 0, 0]
  }

  def self.win32_update_readmode(mode, hwnd)
    t = RubySerial::Win32::CommTimeouts.new
    ffi_call :GetCommTimeouts, hwnd, t
    raise "ack TODO" if WIN32_READMODES[mode].nil?
    t[:read_interval_timeout], t[:read_total_timeout_multiplier], t[:read_total_timeout_constant] = *WIN32_READMODES[mode]
      # do we need to set these?
      #timeouts[:write_total_timeout_multiplier] #= 1
      #timeouts[:write_total_timeout_constant]   #= 10
  #    puts "comT: #{w32_pct t}"
   ffi_call :SetCommTimeouts, hwnd, t
  end



  def self._reconfigure(io, hndl, clear_config, hupcl: nil, baud: nil, data_bits: nil, parity: nil, stop_bits: nil, min: nil)


    # Update the terminal settings
    dcb = RubySerial::Win32::DCB.new
    dcb[:dcblength] = RubySerial::Win32::DCB::Sizeof
    ffi_call :GetCommState, hndl, dcb
      dcb[:baudrate] = baud if baud
      dcb[:bytesize] = data_bits if data_bits
      dcb[:stopbits] = RubySerial::Win32::DCB::STOPBITS[stop_bits] if stop_bits
      dcb[:parity]   = RubySerial::Win32::DCB::PARITY[parity] if parity

      dcb[:flags] &= ~(0x3000) # clear
      #doreset =
      unless hupcl.nil?
      cfl = (dcb[:flags] & 48) / 16
      dtr = hupcl
      rts = hupcl ? 0 : 0
 #     p cfl
      dcb[:flags] &= ~(48 + 0x3000) # clear
      dcb[:flags] |= 16 if dtr # set
      dcb[:flags] |= 0x1000*rts  # set
      if cfl > 0 && !dtr
        # TODO: ???
      end
      end
#    dcb[:flags] &= ~48
# DTR control
  #p dcb[:flags] # 4225, binary, txcontinuexonxoff, rtscontrol=1
  #p w32_dab(dcb)
  #4241 = 4225 +fDtrControl=1
   ffi_call :SetCommState, hndl, dcb

  end

  def self.w32_dab(t)
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
              :wreserved1].map{|x|t[x]}
  end

  def self.w32_pct(t)
    [:read_interval_timeout,
              :read_total_timeout_multiplier,
              :read_total_timeout_constant,
              :write_total_timeout_multiplier,
              :write_total_timeout_constant].map{|f| t[f]}
  end

  def self.ffi_call who, *args
     res = RubySerial::Win32.send who, *args
     if res == 0
       raise RubySerial::Error, RubySerial::Win32::ERROR_CODES[FFI.errno]
     end
   res
  end

end
# Copyright (c) 2014-2016 The Hybrid Group

module RubySerial::Includes
  def readpartial(*args, _bypass: false)
    change_win32_mode :partial unless _bypass
    super(*args)
  end

  def read_nonblock(maxlen, buf=nil, exception: true)
    change_win32_mode :nonblocking
    if buf.nil?
      readpartial(maxlen, _bypass: true)
    else
      readpartial(maxlen, buf, _bypass: true)
    end
  rescue EOFError
    raise IO::EAGAINWaitReadable, "Resource temporarily unavailable - read would block"
  end

  [:read, :pread, :readbyte, :readchar, :readline, :readlines, :sysread, :getbyte, :getc, :gets].each do |name|
    define_method name do |*args|
      change_win32_mode :blocking
      super(*args)
    end
  end

  def write_nonblock(*args)
    # TODO: support write_nonblock on windows
    write(*args)
  end

  def change_win32_mode type
    return if @_win32_curr_read_mode == type
    # Ugh, have to change the mode now
    RubySerial::Builder.win32_update_readmode(type, @_rs_hwnd)
    @_win32_curr_read_mode = type
  end

  def _win32_hndl= hwnd
    @_rs_hwnd = hwnd
    @_win32_curr_read_mode = :blocking
  end

  def reconfigure(clear_config, hupcl: nil, baud: nil, data_bits: nil, parity: nil, stop_bits: nil, min: nil)
    RubySerial::Builder._reconfigure(self, @_rs_hwnd, clear_config, hupcl: hupcl, baud: baud, data_bits: data_bits, parity: parity, stop_bits: stop_bits, min: min)
  end

  def dtr= val
    RubySerial::Builder.ffi_call :EscapeCommFunction, @_rs_hwnd, (val ? 5 : 6)
  end

  def rts= val
    RubySerial::Builder.ffi_call :EscapeCommFunction, @_rs_hwnd, (val ? 3 : 4)
  end

  def _winfix= val
  end
end
