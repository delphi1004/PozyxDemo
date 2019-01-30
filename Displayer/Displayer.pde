import processing.serial.*;
import oscP5.*;
import netP5.*;
import java.util.Map;

Serial arduino;
OscP5 oscP5;
NetAddressList myNetAddressList = new NetAddressList();

int myListeningPort = 32000;
/* the broadcast port is the port the clients should listen for incoming messages from the server*/
int myBroadcastPort = 12000;

String myConnectPattern = "/server/connect";
String myDisconnectPattern = "/server/disconnect";
float SCALE = 10;

HashMap<String, PVector> tagPositions;

void setup()
{
  //fullScreen();
  
  size(300,200);

  background(0);

  smooth();

  noStroke();

  textSize(12);

  initDefaultData();
}

void initDefaultData()
{
  tagPositions = new HashMap<String, PVector>();

  initSerial();

  initOSC();
}

void initSerial()
{
  String name;
  int index;

  index = 0;

  println(Serial.list());
  println("");

  for (int i=0; i<Serial.list().length; i++)
  {
    name = Serial.list()[i];

    if (name.contains("14101") == true || name.contains("14201") == true)
    {
      index = i; 

      println("Found Arduino "+name);

      break;
    }
  }

  if (Serial.list().length > 0)
  {
    arduino = new Serial(this, Serial.list()[index], 115200);

    println(arduino);
  }
}

void initOSC()
{
  oscP5 = new OscP5(this, myListeningPort);
}

void sendOscMsg(String data)
{
  OscMessage oscMsg;
  
  oscMsg = new OscMessage("/pozyx");
  
  oscMsg.add(data);  
  
  oscP5.send(oscMsg, myNetAddressList);
}

void serialEvent(Serial p) 
  String recvData;
  String []parseData;

  recvData = arduino.readStringUntil('\n'); 

  if (recvData != null)
  {
    recvData = trim(recvData);

    parseData = split(recvData, ",");

    if (parseData[0].equals("POS") == true)
    {  
      tagPositions.put(parseData[1], new PVector(int(parseData[2]), int(parseData[3]), int(parseData[4])));
      
      sendOscMsg(recvData);

      //println(tagPositions); // for make sure , if we have correct data
    }
  }
}

void oscEvent(OscMessage theOscMessage) 
{
  if (theOscMessage.addrPattern().equals(myConnectPattern)) 
  {
    connect(theOscMessage.netAddress().address());
  } else if (theOscMessage.addrPattern().equals(myDisconnectPattern)) 
  {
    disconnect(theOscMessage.netAddress().address());
  } else 
  {
    oscP5.send(theOscMessage, myNetAddressList);
  }
}

private void connect(String theIPaddress) 
{
  if (!myNetAddressList.contains(theIPaddress, myBroadcastPort)) 
  {
    myNetAddressList.add(new NetAddress(theIPaddress, myBroadcastPort));
    
    println("### adding "+theIPaddress+" to the list.");
  } else 
  {
    println("### "+theIPaddress+" is already connected.");
  }
  
  println("### currently there are "+myNetAddressList.list().size()+" remote locations connected.");
}

private void disconnect(String theIPaddress) 
{
  if (myNetAddressList.contains(theIPaddress, myBroadcastPort)) 
  {
    myNetAddressList.remove(theIPaddress, myBroadcastPort);

    println("### removing "+theIPaddress+" from the list.");
  } else 
  {
    println("### "+theIPaddress+" is not connected.");
  }
  
  println("### currently there are "+myNetAddressList.list().size());
}


void draw()
{
  int posY;
  String info;
  PVector tagPos;

  background(0);

  fill(255);
  
  posY = 20;

  for (Map.Entry tagInfo : tagPositions.entrySet()) 
  {
    tagPos = (PVector)tagInfo.getValue();

    ellipse(tagPos.x/SCALE, tagPos.y/SCALE, 20, 20);
    
    info = ((String)tagInfo.getKey()+" "+tagPos);
    
    text(info,20,posY+30);
    
    posY += 31;

    text((String)tagInfo.getKey(), tagPos.x/SCALE-20, tagPos.y/SCALE+25);
  }
}
