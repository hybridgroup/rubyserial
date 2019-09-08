# Copyright (c) 2014-2016 The Hybrid Group
# Copyright (c) 2019 Patrick Plenefisch


class RubySerial::Builder
  def self.build(parent, config)
    dev = config.device.start_with?("\\\\.\\") ? config.device : "\\\\.\\#{config.device}"
    fd = IO::sysopen(dev, File::RDWR)

    hndl = RubySerial::WinC._get_osfhandle(fd)
    # TODO: check errno

    # Update the terminal settings
    out_config = reconfigure(hndl, config) # TODO: clear_config
    out_config.device = config.device

    ffi_call :SetupComm, hndl, 64, 64 # Set the buffers to 64 bytes

    blocking_mode = config.enable_blocking ? :blocking : :nonblocking
    win32_update_readmode(blocking_mode, hndl)

    file = parent.send(:for_fd, fd, File::RDWR)
    file.send :_rs_win32_init, hndl, blocking_mode

    return [file, fd, out_config]
  end

  # @api private
  # @!visibility private
  # Reconfigures the given (platform-specific) file handle with the provided configuration. See {RubySerial::Includes#reconfigure} for public API
  def self.reconfigure(hndl, req_config)
    # Update the terminal settings
    dcb = RubySerial::Win32::DCB.new
    dcb[:dcblength] = RubySerial::Win32::DCB::Sizeof
    ffi_call :GetCommState, hndl, dcb
    out_config = edit_config(dcb, req_config)
    ffi_call :SetCommState, hndl, dcb
    out_config
  end

  private

  # Changes the read mode timeouts to accomidate the desired blocking mode
  def self.win32_update_readmode(mode, hwnd)
    t = RubySerial::Win32::CommTimeouts.new

    ffi_call :GetCommTimeouts, hwnd, t
    raise ArgumentError, "Invalid mode: #{mode}" if RubySerial::Win32::CommTimeouts::READ_MODES[mode].nil?

    # Leave the write alone, just set the read timeouts
    t[:read_interval_timeout], t[:read_total_timeout_multiplier], t[:read_total_timeout_constant] = *RubySerial::Win32::CommTimeouts::READ_MODES[mode]

    #puts "com details: #{t.dbg_a}"
    ffi_call :SetCommTimeouts, hwnd, t
  end

  # Calls the given FFI target, and raises an error if it fails
  def self.ffi_call who, *args
     res = RubySerial::Win32.send who, *args
     if res == 0
       raise RubySerial::Error, RubySerial::Win32::ERROR_CODES[FFI.errno]
     end
   res
  end

  # Updates the configuration object with the requested configuration
  def self.edit_config(dcb, req)
    actual = RubySerial::Configuration.from(device: req.device)

    dcb[:baudrate] = req.baud if req.baud
    dcb[:bytesize] = req.data_bits if req.data_bits
    dcb[:stopbits] = RubySerial::Win32::DCB::STOPBITS[req.stop_bits] if req.stop_bits
    dcb[:parity]   = RubySerial::Win32::DCB::PARITY[req.parity] if req.parity

    dcb[:flags]  &= ~RubySerial::Win32::DCB::FLAGS_RTS # Always clear the RTS bit
    unless req.hupcl.nil?
      dcb[:flags] &= ~RubySerial::Win32::DCB::DTR_MASK
      dcb[:flags] |= RubySerial::Win32::DCB::DTR_ENABLED if req.hupcl
    end

    actual.baud = dcb[:baudrate]
    actual.data_bits = dcb[:bytesize]
    actual.stop_bits = RubySerial::Win32::DCB::STOPBITS.key(dcb[:stopbits])
    actual.parity = RubySerial::Win32::DCB::PARITY.key(dcb[:parity])
    actual.hupcl = (dcb[:flags] & RubySerial::Win32::DCB::DTR_MASK) != 0

    return actual
  end
end

module RubySerial::Includes
  def reconfigure(hupcl: nil, baud: nil, data_bits: nil, parity: nil, stop_bits: nil)
    RubySerial::Builder.reconfigure(@_rs_win32_hndl, RubySerial::Configuration.from(hupcl: hupcl, baud: baud, data_bits: data_bits, parity: parity, stop_bits: stop_bits))
  end

  # Ruby IO has issues with nonblocking from_fd on windows, so override just to change the underlying timeouts
  # @api private
  # @!visibility private
  def readpartial(*args, _bypass: false)
    change_win32_mode :partial unless _bypass
    super(*args)
  end

  # Ruby IO has issues with nonblocking from_fd on windows, so override just to change the underlying timeouts
  # @api private
  # @!visibility private
  def read_nonblock(maxlen, buf=nil, exception: true) # TODO: support exception
    change_win32_mode :nonblocking
    if buf.nil?
      readpartial(maxlen, _bypass: true)
    else
      readpartial(maxlen, buf, _bypass: true)
    end
  rescue EOFError
    raise IO::EAGAINWaitReadable, "Resource temporarily unavailable - read would block"
  end

  # Ruby IO has issues with nonblocking from_fd on windows, so override just to change the underlying timeouts
  [:read, :pread, :readbyte, :readchar, :readline, :readlines, :sysread, :getbyte, :getc, :gets].each do |name|
    define_method name do |*args|
      change_win32_mode @_rs_win32_blocking
      super(*args)
    end
  end

  # Ruby IO has issuew with nonblocking from_fd on windows, so override just to change the underlying timeouts
  # @api private
  # @!visibility private
  def write_nonblock(*args)
    # TODO: properly support write_nonblock on windows
    write(*args)
  end

  private

  ##
  # Updates the timeouts (if applicable) to emulate the requested read type
  def change_win32_mode type
    return if @_rs_win32_curr_read_mode == type

    # have to change the mode now
    RubySerial::Builder.win32_update_readmode(type, @_rs_win32_hndl)
    @_rs_win32_curr_read_mode = type
  end

  def _rs_win32_init(hndl, blocking_mode)
    @_rs_win32_hndl = hndl
    @_rs_win32_blocking = blocking_mode
    @_rs_win32_curr_read_mode = blocking_mode
  end

  # TODO: make cross platform...
  #def dtr= val
  #  RubySerial::Builder.ffi_call :EscapeCommFunction, @_rs_hwnd, (val ? 5 : 6)
  #end

  #def rts= val
  #  RubySerial::Builder.ffi_call :EscapeCommFunction, @_rs_hwnd, (val ? 3 : 4)
  #end
end
