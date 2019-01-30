/// this is OSC listener for pozyx sensor, by John Lee 30 Jan 2019



import oscP5.*;
import netP5.*;
import java.util.Map;

OscP5 oscP5;
float SCALE = 10;

/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 

HashMap<String, PVector> tagPositions;

void setup() 
{
  
  fullScreen();
  
  //size(400,400);
  
  /* create a new instance of oscP5. 
   * 12000 is the port number you are listening for incoming osc messages.
   */
  
  oscP5 = new OscP5(this,12000);
  
  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress("10.100.34.254",32000);
  
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
  float temp;
  float speed;
  String recvData;
  String []parseData;
  OscMessage oscMsg;

  speed = 0;
  
   /* get and print the address pattern and the typetag of the received OscMessage */
 // println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
 // theOscMessage.print();
  
  if (theOscMessage.addrPattern().equals("/pozyx") == true)
  {
    println("received data");
    
    recvData = (String) theOscMessage.arguments()[0];
    
    parseData = split(recvData, ",");

    if (parseData[0].equals("POS") == true)
    {  
      tagPositions.put(parseData[1], new PVector(int(parseData[2]), int(parseData[3]), int(parseData[4])));
      
      println(tagPositions); // for make sure , if we have correct data
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
  
  
  
  
  
  
  
  
