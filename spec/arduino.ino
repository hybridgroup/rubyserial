// This is the Arduino script for testing. Please compile and upload to any arduino with *hardware* serial. SoftSerial doesn't reset on HUPCL, such as with the pro Mini.
// Uno, Nano, or other board with ftdi or similar usb chips are required.

int i = 0;
int loopv = 0;
void setup() {
  // put your setup code here, to run once:
 Serial.begin(57600);
    Serial.write('z');
    i = 0;
    loopv = 0;
}
// w - wait 250ms
// e immediate "echo!"
// n immediate "narwhales are cool"
// i immediate "A" + i++
// a[5 bytes] - immediate 5 byte echo
// [1s wait] - "y/w"
// x/y - enable/disable pings
// r - reset i

bool ping = true;

void loop()
{
  if (Serial.available())
  {
    char chr = (char)Serial.read();
    switch (chr)
    {
      case 'a':
        while (Serial.available() < 5)
          delay(3);
        byte buf[5];
        Serial.readBytes(buf, 5);
        Serial.write(buf, 5);
        break;
      case 'b':
      {
        while (Serial.available() < 5)
          delay(3);
        int buf2;
        Serial.readBytes((char*)&buf2, 4);
        uint8_t r = Serial.read();
        Serial.end();
        delay(100);
        Serial.begin(buf2, r);
        delay(100);
        Serial.write('B');
        break;
      }
      case 'e':
        Serial.print("echo");
        break;
      case 'w':
        delay(250);
        break;
      case 'i':
        Serial.write(i++ + 'A');
        break;
      case 'n':
        Serial.print("narwhales are cool");
        break;
      case 'y':
        ping = false;
        break;
      case 'x':
        ping = true;
        break;
      case 'r':
        i = 0;
        break;
      default:
        Serial.write('!');
        break;
    }
    loopv = 0;
  }
  loopv++;
  if (loopv == 1000 && ping)
  {
    Serial.write('w');
  }
  else if (loopv == 2000 && ping)
  {
    Serial.write('y');
    loopv = 0;
  }
  delay(1);
}

