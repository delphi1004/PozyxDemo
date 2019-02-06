/// this is OSC listener for pozyx sensor, by John Lee 30 Jan 2019



import oscP5.*;
import java.util.Map;

OscP5 oscP5;
float SCALE = 10;

HashMap<String, PVector> tagPositions;

void setup() 
{
  fullScreen();
   
  oscP5 = new OscP5(this,12000);
  
  initDefaultData();
}

void initDefaultData()
{
  tagPositions = new HashMap<String, PVector>();

  connectToServer();
}

void connectToServer()
{
  OscMessage msg;
  
  msg = new OscMessage("/server/connect",new Object[0]);
  
  oscP5.flush(msg,myBroadcastLocation); 
}

void disconnectServer()
{
  OscMessage msg;
  
  msg = new OscMessage("/server/disconnect",new Object[0]);
  
  oscP5.flush(msg,myBroadcastLocation); 
}
  
void oscEvent(OscMessage theOscMessage) 
{
  String recvData;
  String []parseData;
    
  if (theOscMessage.addrPattern().equals("/pozyx") == true)
  {
    println("received data");
    
    recvData = (String) theOscMessage.arguments()[0];
    
    parseData = split(recvData, ",");

    if (parseData[0].equals("POS") == true)
    {  
      tagPositions.put(parseData[1], new PVector(int(parseData[2]), int(parseData[3]), int(parseData[4])));
      
      //println(tagPositions); // for make sure , if we have correct data
    }
  }
}

void displayTags()
{
  PVector tagPos;

  background(0);

  fill(255);

  for (Map.Entry tagInfo : tagPositions.entrySet()) 
  {
    tagPos = (PVector)tagInfo.getValue();

    ellipse(tagPos.x/SCALE, tagPos.y/SCALE, 20, 20);

    text((String)tagInfo.getKey(), tagPos.x/SCALE-20, tagPos.y/SCALE+25);
  }
}
  
void draw()
{
  displayTags();
  
  text("I'm OSC listener!!",20,20);
}
