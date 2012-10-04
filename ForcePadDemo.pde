import hypermedia.net.*;
import processing.serial.*;

int PORT_RX=12345;
String HOST_IP = "127.0.0.1";//IP Address of the PC in which this App is running
UDP udp; // For receiving from the ForcePad_UDPSender
Serial serial;
PImage bg;

// Buffer for each points (at most 5 points)
int[] px = new int[5];    // 1000 ~ 5900
int[] py = new int[5];    // 4500 ~ 1100
int[] pz = new int[5];
int[] pF = new int[5];    // 0 ~ 1000

void setup() {
  size(800, 600);
  udp= new UDP(this, PORT_RX, HOST_IP);
  udp.listen(true);
  
  bg = loadImage("screenshot.png");
  bg.resize(800, 600);
  
  // The communication with the Arduino is over the serial port
  // (it's the second one on the list, COM3, for some reason...)
  serial = new Serial(this, Serial.list()[1], 9600);
}

int delayMillis = millis(); // wait this many ms between updates
int smoothedPressure = 0;

void draw() {
  
  background(bg);
  ellipseMode(CENTER);
  int totalForce = 0;
  int numFingers = 0;
  for(int i=0;i<5;i++) {
    if(px[i]<=0)
      continue;
    float drawX = map(constrain(px[i], 1000, 5900), 1000, 5900, 0, width);
    float drawY = map(constrain(py[i], 1100, 4500), 4500, 1100, 0, height);
    int force = pF[i];
    
    fill(255);
    ellipse(drawX, drawY, force, force);
    totalForce += force;
    numFingers++;
  }
  if(numFingers > 0) {
    totalForce /= numFingers;
    totalForce += 7;
  }
  
  smoothedPressure = constrain(int(.995*smoothedPressure + .005*totalForce), 0, 255);
  
  if(millis() - delayMillis > 33) {
    serial.write(byte(smoothedPressure));
    delayMillis = millis();
  }
}



byte[] receiveBuffer = new byte[1000];
int bufferIndex;

void receive(byte[] data, String HOST_IP, int PORT_RX) {
  for (int i=0;i<data.length;i++) {
    // END byte
    if (data[i] == 0) {
      // calculate CRC;
      if(bufferIndex <= 4)
        return;  

      // Calculate the CRC
      byte[] CRC = new byte[4];
      byte[] receiveString = new byte[bufferIndex-4];

      for (int j=0;j<bufferIndex-4;j++) {
        int index = j%4;
        receiveString[j] = receiveBuffer[j];
        CRC[index] ^= receiveBuffer[j];
      }
      // if CRC matches, commit the message
      if (CRC[0] == receiveBuffer[bufferIndex-4] && CRC[1] == receiveBuffer[bufferIndex-3] && CRC[2] == receiveBuffer[bufferIndex-2] && CRC[3] == receiveBuffer[bufferIndex-1]) {
        processPacket(new String(receiveString));
      }

      bufferIndex = 0;
      return;
    }

    // if else, just accumlate it
    receiveBuffer[bufferIndex++] = data[i];
    if (bufferIndex==1000)    // if data explode happens in buffer, just clear it
      bufferIndex = 0;
  }
}

void processPacket(String packet) {
  int[] values = int(split(packet, "\t"));
  int i = values[0]; 
  px[i] = values[1];
  py[i] = values[2];
  pz[i] = values[3];
  pF[i] = values[4];
}

