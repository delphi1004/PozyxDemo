import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import java.util.Map; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class OscListener extends PApplet {

/// this is OSC listener for pozyx sensor, by John Lee 30 Jan 2019







OscP5 oscP5;
float SCALE = 10;

/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 

HashMap<String, PVector> tagPositions;

public void setup() 
{
  
  
  
  //size(400,400);
  
  /* create a new instance of oscP5. 
   * 12000 is the port number you are listening for incoming osc messages.
   */
  
  oscP5 = new OscP5(this,12000);
  
  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress("10.100.34.254",32000);
  
  initDefaultData();
}

public void initDefaultData()
{
  tagPositions = new HashMap<String, PVector>();

  connectToServer();
}

public void connectToServer()
{
  OscMessage msg;
  
  msg = new OscMessage("/server/connect",new Object[0]);
  
  oscP5.flush(msg,myBroadcastLocation); 
}

public void disconnectServer()
{
  OscMessage msg;
  
  msg = new OscMessage("/server/disconnect",new Object[0]);
  
  oscP5.flush(msg,myBroadcastLocation); 
}
  

public void oscEvent(OscMessage theOscMessage) 
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
      tagPositions.put(parseData[1], new PVector(PApplet.parseInt(parseData[2]), PApplet.parseInt(parseData[3]), PApplet.parseInt(parseData[4])));
      
      println(tagPositions); // for make sure , if we have correct data
    }
  }
}

public void displayTags()
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
  
  
public void draw()
{
  displayTags();
  
  text("I'm OSC listener!!",20,20);
}
  
  
  
  
  
  
  
  

  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "OscListener" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
