import processing.serial.*;

Serial arduino;

import java.util.Map;

float SCALE = 10;

HashMap<String,PVector> tagPositions;

void setup()
{
  fullScreen();
  
  background(0);

  smooth();

  noStroke();
  
  textSize(32);
  
  initDefaultData();
}

void initDefaultData()
{
   tagPositions = new HashMap<String,PVector>();
  
  initSerial();
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

      println(name);

      break;
    }
  }

  if (Serial.list().length > 0)
  {
    arduino = new Serial(this, Serial.list()[index], 115200);

    println(arduino);
  }
}

void serialEvent(Serial p) 
{ 
  float temp;
  float speed;
  String recvData;
  String []parseData;

  speed = 0;

  recvData = arduino.readStringUntil('\n'); 

  if (recvData != null)
  {
    recvData = trim(recvData);

    parseData = split(recvData, ",");

    if (parseData[0].equals("POS") == true)
    {  
      tagPositions.put(parseData[1],new PVector(int(parseData[2]),int(parseData[3]),int(parseData[4])));
       
      //println(tagPositions); // for make sure , if we have correct data
    }
  }
}

void draw()
{
  PVector tagPos;
  
  background(0);
  
  fill(255);
  
  for (Map.Entry tagInfo: tagPositions.entrySet()) 
  {
    tagPos = (PVector)tagInfo.getValue();
        
    ellipse(tagPos.x/SCALE,tagPos.y/SCALE,20,20);
    
    text((String)tagInfo.getKey(), tagPos.x/SCALE-20,tagPos.y/SCALE+25);
  }
}
