#include "LPD8806.h"
#include "SPI.h"

// Example to control LPD8806-based RGB LED Modules in a strip

/*****************************************************************************/

// Number of RGB LEDs in strand:
int nLEDs = 32;

// Chose 2 pins for output; can be any valid output pins:
int dataPin  = 2;
int clockPin = 3;

uint32_t current, past;

// First parameter is the number of LEDs in the strand.  The LED strips
// are 32 LEDs per meter but you can extend or cut the strip.  Next two
// parameters are SPI data and clock pins:
LPD8806 strip = LPD8806(32, dataPin, clockPin);

// You can optionally use hardware SPI for faster writes, just leave out
// the data and clock pin parameters.  But this does limit use to very
// specific pins on the Arduino.  For "classic" Arduinos (Uno, Duemilanove,
// etc.), data = pin 11, clock = pin 13.  For Arduino Mega, data = pin 51,
// clock = pin 52.  For 32u4 Breakout Board+ and Teensy, data = pin B2,
// clock = pin B1.  For Leonardo, this can ONLY be done on the ICSP pins.
//LPD8806 strip = LPD8806(nLEDs);

void setup() {
  
  Serial.begin(9600); // opens serial port, sets data rate to 9600 bps

  strip.begin();
  // Update the strip, to start they are all 'off'
  strip.show();
  
  current = 0;
  past = 0;
}


void loop() {
 // current = (some fed in value of pressure);
/* current = 180;
 if(past == 0) {
   colorWipe(Wheel(current), 50);
  } else {
   colorFade(past,current, 50);
 } */

//  colorWipe(Wheel(27), 50); //Orange for friendly/welcoming
// delay(10000);
 // colorWipe(Wheel(85), 50); //green for fresh
//  delay(10000);
// colorWipe(Wheel(180), 50); //blue for calm
  
//  delay(10000);


  int incomingByte = 0;   // for incoming serial data
  // send data only when you receive data:
  
  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();

    if (incomingByte < 128) {
        colorWipe(Wheel(180 - (95 * (incomingByte*1.0 / 128))), 1000);
    }
    else {
        colorWipe(Wheel(85 - (58 * ((incomingByte*1.0 - 128) / 256))), 1000);
    }
  }
  strip.show();

//  colorFade(180,27, 50);
  past = current;
}



// Fill the dots progressively along the strip.
void colorWipe(uint32_t c, uint8_t wait) {
  int i;

  for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
      
  }
  strip.show();
  
}

void colorFade(uint32_t start, uint32_t end, uint8_t span) {
  uint32_t i, j;
  
  
  if(start <= end) {
    for (j=start; j <end; j++) {     // 5 cycles of all 384 colors in the wheel
      for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
        strip.setPixelColor(i, Wheel( j) );
      }  
      strip.show();   // write all the pixels out
      delay(span);
    }
  } else {
    for (j=start; j >end; j--) {     // 5 cycles of all 384 colors in the wheel
      for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
        strip.setPixelColor(i, Wheel( j) );
      }  
      strip.show();   // write all the pixels out
      delay(span);
    }
  }
}


uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch(WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128;   //Red down
      g = WheelPos % 128;      // Green up
      b = 0;                  //blue off
      break; 
    case 1:
      g = 127 - WheelPos % 128;  //green down
      b = WheelPos % 128;      //blue up
      r = 0;                  //red off
      break; 
    case 2:
      b = 127 - WheelPos % 128;  //blue down 
      r = WheelPos % 128;      //red up
      g = 0;                  //green off
      break; 
  }
  return(strip.Color(r,g,b));
}


