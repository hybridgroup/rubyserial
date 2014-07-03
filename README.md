# rubyserial

RubySerial is a simple RubyGem for reading from and writing to serial ports.

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

**RubySerial::Exception**

A wrapper exception type, that returns the underlying system error code.

## License

Apache 2.0. See `LICENSE` for more details.
