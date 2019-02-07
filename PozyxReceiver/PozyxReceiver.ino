// Please read the ready-to-localize tuturial together with this example.
// https://www.pozyx.io/Documentation/Tutorials/ready_to_localize
/**
  The Pozyx ready to localize tutorial (c) Pozyx Labs

  Please read the tutorial that accompanies this sketch: https://www.pozyx.io/Documentation/Tutorials/ready_to_localize/Arduino

  This tutorial requires at least the contents of the Pozyx Ready to Localize kit. It demonstrates the positioning capabilities
  of the Pozyx device both locally and remotely. Follow the steps to correctly set up your environment in the link, change the
  parameters and upload this sketch. Watch the coordinates change as you move your device around!
*/
#include <Pozyx.h>
#include <Pozyx_definitions.h>
#include <Wire.h>

////////////////////////////////////////////////
////////////////// PARAMETERS //////////////////
////////////////////////////////////////////////

const int num_tags = 5;
uint16_t tags[num_tags] = {0x675f, 0x6749,0x6735,0x673a,0x6759};

boolean use_processing = true;                         // set this to true to output data for the processing sketch

const uint8_t num_anchors = 4;                                    // the number of anchors
uint16_t anchors[num_anchors] = {0x6760, 0x675a, 0x6738, 0x6e1d};     // the network id of the anchors: change these to the network ids of your anchors.
int32_t anchors_x[num_anchors] = {0, 9400, 13221, 7336};               // anchor x-coorindates in mm
int32_t anchors_y[num_anchors] = {0, 1193, 6511, 7336};                  // anchor y-coordinates in mm
int32_t heights[num_anchors] = {2230, 2720, 2450, 2630};              // anchor z-coordinates in mm

uint8_t algorithm = POZYX_POS_ALG_UWB_ONLY;             // positioning algorithm to use. try POZYX_POS_ALG_TRACKING for fast moving objects.
uint8_t dimension = POZYX_3D;                           // positioning dimension
int32_t height = 1000;                                  // height of device, required in 2.5D positioning


////////////////////////////////////////////////

void setup(){
  Serial.begin(115200);

  if(Pozyx.begin() == POZYX_FAILURE){
    Serial.println(F("ERROR: Unable to connect to POZYX shield"));
    Serial.println(F("Reset required"));
    delay(100);
    abort();
  }

  Serial.println(F("----------POZYX POSITIONING V1.1----------"));
  Serial.println(F("NOTES:"));
  Serial.println(F("- No parameters required."));
  Serial.println();
  Serial.println(F("- System will auto start anchor configuration"));
  Serial.println();
  Serial.println(F("- System will auto start positioning"));
  Serial.println(F("----------POZYX POSITIONING V1.1----------"));
  Serial.println();
  Serial.println(F("Performing manual anchor configuration:"));

  // configures all remote tags and prints the success of their configuration.
  setAnchorsManual();
  setTagsAlgorithm();
  delay(1000);

  Serial.println(F("Starting positioning: "));
}

void loop()
{
  int status1,status2;
  coordinates_t position;
  euler_angles_t angle;
  
  for (int i = 1; i < num_tags; i++)
  {  // To void see the error msg, I just modified i starts from 1, because we can't get a data from base sensor which is index 0
    
    status1 = Pozyx.doRemotePositioning(tags[i], &position, dimension, height, algorithm);
    status2 = Pozyx.getEulerAngles_deg(&angle,tags[i]);
    
    if (status1 == POZYX_SUCCESS && status2 == POZYX_SUCCESS)
    {
      // prints out the result
      printCoordinates(position,angle, tags[i]);
    
    }else{
      // prints out the error code
      printErrorCode("positioning", tags[i]);
    }
  }
}

// prints the coordinates for either humans or for processing
void printCoordinates(coordinates_t coor,  euler_angles_t angle , uint16_t network_id)
{
  
  if(!use_processing)
  {
    Serial.print("POS ID 0x");
    Serial.print(network_id, HEX);
    Serial.print(", x(mm): ");
    Serial.print(coor.x);
    Serial.print(", y(mm): ");
    Serial.print(coor.y);
    Serial.print(", z(mm): ");
    Serial.print(coor.z);
    Serial.print(", yaw(degree): ");
    Serial.print(angle.heading);
    Serial.print(", roll(degree): ");
    Serial.print(angle.roll);
    Serial.print(", pitch(degree): ");
    Serial.print(angle.pitch);
  }else{
    Serial.print("POS,0x");
    Serial.print(network_id, HEX);
    Serial.print(",");
    Serial.print(coor.x);
    Serial.print(",");
    Serial.print(coor.y);
    Serial.print(",");
    Serial.print(coor.z);
    Serial.print(",");
    Serial.print(angle.heading);
    Serial.print(",");
    Serial.print(angle.roll);
    Serial.print(",");
    Serial.println(angle.pitch);
  }
}

// error printing function for debugging
void printErrorCode(String operation, uint16_t network_id)
{
  uint8_t error_code;
  int status = Pozyx.getErrorCode(&error_code, network_id);
  
  if(status == POZYX_SUCCESS)
  {
    Serial.print("ERROR ");
    Serial.print(operation);
    Serial.print(" on ID 0x");
    Serial.print(network_id, HEX);
    Serial.print(", error code: 0x");
    Serial.println(error_code, HEX);
  }else{
    Pozyx.getErrorCode(&error_code);
    Serial.print("ERROR ");
    Serial.print(operation);
    Serial.print(", couldn't retrieve remote error code, local error: 0x");
    Serial.println(error_code, HEX);
  }
}

void setTagsAlgorithm()
{
  for (int i = 0; i < num_tags; i++){
    Pozyx.setPositionAlgorithm(algorithm, dimension, tags[i]);
  }
}

// function to manually set the anchor coordinates
void setAnchorsManual()
{
  for (int i = 0; i < num_tags; i++){
    int status = Pozyx.clearDevices(tags[i]);
    for(int j = 0; j < num_anchors; j++){
      device_coordinates_t anchor;
      anchor.network_id = anchors[j];
      anchor.flag = 0x1;
      anchor.pos.x = anchors_x[j];
      anchor.pos.y = anchors_y[j];
      anchor.pos.z = heights[j];
      status &= Pozyx.addDevice(anchor, tags[i]);
    }
    if (num_anchors > 4){
      Pozyx.setSelectionOfAnchors(POZYX_ANCHOR_SEL_AUTO, num_anchors, tags[i]);
    }
    if (status == POZYX_SUCCESS){
      Serial.print("Configuring ID 0x");
      Serial.print(tags[i], HEX);
      Serial.println(" success!");
    }else{
      printErrorCode("configuration", tags[i]);
    }
  }
}
