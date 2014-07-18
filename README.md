# rubyserial

RubySerial is a simple Ruby gem for reading from and writing to serial ports. 

Unlike other Ruby serial port implementations, it supports all of the most popular Ruby implementations (MRI, JRuby, & Rubinius) on the most popular operating systems (OSX, Linux, & Windows). And it does not require any native compilation thanks to using RubyFFI [https://github.com/ffi/ffi](https://github.com/ffi/ffi).

The interface to RubySerial should be (mostly) compatible with other Ruby serialport gems, so you should be able to drop in the new gem, change the `require` and use it as a replacement. If not, please let us know so we can address any issues.

[![Build Status](https://travis-ci.org/hybridgroup/rubyserial.svg)](https://travis-ci.org/hybridgroup/rubyserial)

## Installation

    $ gem install rubyserial

## Usage

```ruby
require 'rubyserial'
serialport = Serial.new '/dev/ttyACM0', 57600
```

## Methods

**write(data : String) -> Int**

Returns the number of bytes written.
Emits a `RubySerial::Exception` on error.

**read(length : Int) -> String**

Returns a string up to `length` long. It is not guaranteed to return the entire
length specified, and will return an empty string if no data is
available. Emits a `RubySerial::Exception` on error.

**getbyte -> Fixnum or nil**

Returns an 8 bit byte or nil if no data is available. 
Emits a `RubySerial::Exception` on error.

**RubySerial::Exception**

A wrapper exception type, that returns the underlying system error code.

## License

Apache 2.0. See `LICENSE` for more details.
