# rubyserial

A simple ruby gem which allows you to read and write from a serial port.

Usage:
```ruby
require 'rubyserial'
s = Serial.new("/dev/ttyACM0", 57600)
```

#####write(string) -> int
```
  returns the number of bytes written.
  RubySerial::Exception on error.
```
######read(length) -> string
```
 returns a string up to "length".   
 read is not guarenteed to return the entire "length" specified.
 returns "" on no data
 RubySerial::Exception on error.
```

######RubySerial::Exception
```
  returns the underlying system error code
```
