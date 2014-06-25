# rubyserial

A simple ruby gem which allows you to read and write from a serial port.

Usage:
```ruby
require 'rubyserial'
s = Serial.new("/dev/ttyACM0", 57600)
```

The object returned is a ruby IO object and responds to each IO instance [method](http://www.ruby-doc.org/core-2.1.2/IO.html)
