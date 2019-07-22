# rubyserial

RubySerial is a simple Ruby gem for reading from and writing to serial ports.

Unlike other Ruby serial port implementations, it supports all of the most popular Ruby implementations (MRI, JRuby, & Rubinius) on the most popular operating systems (OSX, Linux, & Windows). And it does not require any native compilation thanks to using RubyFFI [https://github.com/ffi/ffi](https://github.com/ffi/ffi). Note: Windows requires JRuby >= 9.2.8.0 to fix native IO issues.

The interface to RubySerial should be compatible with other Ruby serialport gems, so you should be able to drop in the new gem, change the `require` and use it as a replacement. If not, please let us know so we can address any issues.

[![Build Status](https://travis-ci.org/hybridgroup/rubyserial.svg)](https://travis-ci.org/hybridgroup/rubyserial)
[![Build status](https://ci.appveyor.com/api/projects/status/946nlaqy4443vb99/branch/master?svg=true)](https://ci.appveyor.com/project/zankich/rubyserial/branch/master)
[![Test Coverage](https://codeclimate.com/github/hybridgroup/rubyserial/badges/coverage.svg)](https://codeclimate.com/github/hybridgroup/rubyserial/coverage)

## Installation

    $ gem install rubyserial

## Basic Usage

```ruby
require 'rubyserial'

# 0.6 API (nonblocking by default)
serialport = Serial.new '/dev/ttyACM0' # Defaults to 9600 baud, 8 data bits, and no parity
serialport = Serial.new '/dev/ttyACM0', 57600
serialport = Serial.new '/dev/ttyACM0', 19200, :even, 8
serialport = Serial.new '/dev/ttyACM0', 19200, :even, 8, true # to enable blocking IO

# SerialPort gem compatible API (blocking IO by default)
serialport = SerialPort.new '/dev/ttyACM0' # Defaults to the existing system settings.
serialport = SerialPort.new '/dev/ttyACM0', 57600
serialport = SerialPort.new '/dev/ttyACM0', 19200, 8, :even # note the order of args is different

# open style syntax
SerialPort.open '/dev/ttyACM0', 19200, 8, :even do |serialport|
	# ...
end

# change the settings later
five = SerialPort.open '/dev/ttyACM0' do |serialport|
	serialport.baud = 9600
	serialport.data_bits = 8
	serialport.stop_bits = 1
	serialport.parity = :none
	serialport.hupcl = false
	# ...
	5
end
```
Both SerialPort and Serial are an IO object, so standard methods like read and write are available, but do note that Serial has some nonstandard read behavior by default.

## Classes

There are 3 levels of API:

* High level: {SerialPort} and {Serial}
* Medium level: {SerialIO}
* Low level: {RubySerial::Builder.build}

Most use cases will do fine with the high level API, as those, particularly {SerialPort}, are standard IO objects. {Serial} is also an IO, but with the {Serial#read} and {Serial#getbyte} methods having non-standard return conditions (`""` if no data exists, otherwise `readpartial` for the former, and nonblocking for the latter). For this reason, new code is suggested to use {SerialPort} as `read`/`readpartial`/`read_nonblocking` work as expected in all other IO objects.

The medium level API with {SerialIO} also returns an IO object, but allows you to provide your own SerialIO child class to instantiate instead.

The low level API is not considered stable, and may change in minor releases.

See the documentation ! TODO link!!! for more details

**RubySerial::Error**

A wrapper error type that returns the underlying system error code and inherits from IOError.

## Running the tests

The test suite is written using rspec, just use the `rspec` command. There are 3 test files: SerialPort API comatibility `serialport_spec`, Serial API compatability `rubyserial_spec`, and the DTR & timeout correctness test suite `serial_arduino_spec`. The latter requires this !TODO! program flashed to an arduino, or a compatible program that the test can talk to. 

### Test dependencies

To run the tests on OS X and Linux, you must also have the `socat` utility program installed.

#### Installing socat on OS X

```
brew install socat
```

#### Installing socat on Linux

```
sudo apt-get install socat
```

#### Test on Windows

To run the tests on Windows requires com0com which can be downloaded from here:

https://github.com/hybridgroup/rubyserial/raw/appveyor_deps/setup_com0com_W7_x64_signed.exe


## License

Apache 2.0. See `LICENSE` for more details.
