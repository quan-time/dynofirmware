//------------------------------------------------------------------------------
//  The original concept was derived by Steve of www.wotid.com.  The original
//  link can be found here:
//  http://wotid.com/dyno/content/view/14/39/#bs2
//  Because the original firmware was written by him, his front end software
//  expects data to be sent and recieved in a certain way.  This added some
//  constraints to the code, but nothing too complex.
//
//  This is by no means perfect, but it should work for what its intended 
//  purpose is.
//  Once all parts are working and functioning properly, no future development
//  or revisions should be required.  One thing I would like to add is an
//  external RPM sensor.  Something which would go around your spark plug lead
//  much like a timing light gun.  That or the negative wire on a COP (coil
//  on plug) setup.  
//
//  Original credit to Steve for the original concept, And Moodles for
//  some code help as im a lazy sod and he offered :)
//------------------------------------------------------------------------------

//#include <iostream.h>
//#include <iostream>
//only need these for string manipulation
#include <ctype.h> // isalpha, isnumeric etc
#include <stdio.h> // concat etc

// Start Setup variables
int pin = 0;
int playback_pin = 5;
int playback_buttonState = 0;
unsigned long duration;
int RPM_HiLo = 0; // listed as 1 in the PBasic source
int Drum_HiLo = 0; // listed as 1 in the PBasic source
int DrumIn = 0; // listed as 0 in the PBasic source
int StartValue = 0;
int use_external_rpm_sensor = 0; // set to 1 for yes
int debug = 0; // set to 1 for yes
int logging = 0; // use 0 to save memory
int current_line = 0;
int allow_recursion = 1; // use 0 to save memory, 1 for debugging
char playback_string[200][20]; // 200 lines and 20 bytes per string (4000 bytes), Teensy++ 2.0 has 8192 total
int com_baud = 19200;
int quan_mode = 0; // set to 1 if you are quantime
// End Setup variables

void setup() // main function set
{
  Serial.begin(19200);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(pin, INPUT); // Pin 0 should be connected to the optical sensor
  if (logging == 1)
  {
    pinMode(playback_pin, INPUT); // Pin 5 to playback current data
  }
}

void playback_rawdata()
{
  int i = 0;
  
  for(int i = 0; i < current_line; i++)
  {
    Serial.print(playback_string[i,0]);
    Serial.print(",");
    Serial.print(playback_string[i,1]);
    Serial.print(",");
    Serial.print(playback_string[i,2]);
  }
  
  Serial.println("");
  
  Ending_Run();

  if (allow_recursion == 1)
    return;
}

void loop() {        
  //int readbyte[4]; // for incoming serial data
  int readbyte[10]; // room for 10 bytes of data
  // 4 bytes + 1 byte for padding
  // [0] = 1, [1] = 2, [2] = 3, [3] = 4 etc.
  int available_bytes = 0;
  int i = 0;
  char string1[10]; // Placeholder for the startvalue // allocate 10 bytes
  char string3;
  int string2; // This is where the above (string1) is converted from a string to int 
  char tempbyte[2];
  String string = "";

  if (logging == 1)
  {
    playback_buttonState = digitalRead(playback_pin);
    if (playback_buttonState == HIGH) 
    {
      playback_rawdata();
    }
  }
  
  available_bytes = Serial.available();

  // read the incoming byte string, one byte at a time, and assign each readbyte[1] - readbyte[4] respectively.
  if (available_bytes > 0) { // If there are no bytes available, skip this code block
  
    while (i < available_bytes) // && i <= 10) // stop at 10 bytes or we will crash 
    {
      readbyte[i] = Serial.read();   //  let's start reading 1 byte at a time
      
    if ( (readbyte[0] == 'A') || (readbyte[0] == 'a') )
    {
      About();
    }
    else if ( (readbyte[0] == 'S') || (readbyte[0] == 's') )
    {
      Calc_Start(readbyte,1); // just hardcoding this to 1 for now
    }
    else if ( (readbyte[0] == 'G') || (readbyte[0] == 'g') )
    {
      Gear_Ratio();
    }
    else if ( (readbyte[0] == 'T') || (readbyte[0] == 't') )
    {
      Test();
    }
    else if ( (readbyte[0] == 'R') || (readbyte[0] == 'r') )
    {
      Run_Down();
    }
    else
    {
      if (debug == 1)
      {
        Serial.print(readbyte[0]);
        Serial.println(" is invalid!");
      }
      //StartValue = 000;
      //readbyte[0] = 0;
    }

      if ( (available_bytes > 3) ) // && (isalpha(readbyte[0])) && (isdigit(readbyte[i]))) // if there are more than 3 bytes (AB,) then lets use the remaining bytes as StartValue, lets also make sure the first byte is alpha (A-Z a-z) and the byte we are reading is a number (this will filter out letters, commas etc)
      {
        string += readbyte[i]; // append each byte to string1 (placeholder for StartValue) // this requires Arduino 0019
        
        // C alternative for above
        //sprintf( tempbyte, "%s", readbyte[i] ); // save the incoming byte as a single character string
        //strcat(string1, tempbyte); // append tempbyte to string (example. string1 = "hello" and tempbyte = "a", then string1 becomes "helloa"
      }
      
      i++; //increase by 1
    }
    
    //string2 = String.toInt(string); // Arduino 0022
    
    //string2 = atoi(string); // convert string into int without Arduino 0022
  }  
  
  Serial.flush();

  if (allow_recursion == 1)
    return;  
}

// Usage, if there are 2 samples, then you would do "print_hex(2,sample1, sample2, 0);" or if you had 3 samples then "print_hex(3,sample1, sample2, sample3);" or only 1 sample then "print_hex(1,sample1, 0, 0);"
void print_hex(int samples, int sample [])
{   
    if (samples == 1)
    {
      Serial.print(sample[0],HEX);
    }
    else
    {  
      Serial.print(sample[0],HEX);
      Serial.print(",");
    }

    if (samples == 2)
    {
      Serial.print(sample[1],HEX); // Complete line
    }
    else if (samples == 3)
    {
      Serial.print(sample[1],HEX);
      Serial.print(",");
      Serial.print(sample[2],HEX); // Complete line
    }
    
    Serial.println("");
    
    if (logging == 1)
    {
      current_line++;
      playback_string[current_line][0] = sample[0];
      playback_string[current_line][1] = sample[1];
      playback_string[current_line][2] = sample[2];
    }
    if (allow_recursion == 1)    
      return;
}

// Usage see print_hex
void print_dec(int samples, int sample [])
{
    if (samples == 1)
    {
      Serial.print(sample[0],DEC);
    }
    else
    {  
      Serial.print(sample[0],DEC);
      Serial.print(",");
    }

    if (samples == 2)
    {
      Serial.print(sample[1],DEC); // Complete line
    }
    else if (samples == 3)
    {
      Serial.print(sample[1],DEC);
      Serial.print(",");
      Serial.print(sample[2],DEC); // Complete line
    }
    
    Serial.println("");
    if (allow_recursion == 1)
    return;
}

void About() {                                 //  Fairly self explaitory.  It will dump this info 
  Serial.println("Quan-Time WOTID firmware");  //  out in plain-text, and is displayed on the software
  Serial.println("Version 0.01a - Yes, its that bad");  // front end.
  if (allow_recursion == 1)
  return;
}

void Calc_Start(int readbyte [], int StartValue) {        //  The 2nd byte of the string is read to determine if we are going to calculate
                           //  DRUM only, or Drum and simulated engine RPM.
  if (quan_mode == 1)
  {
    simulate_dynorun();
  }
                       
  if ((readbyte[1] == 0) && (StartValue == 0))
  {
    Drum_Only();
    if (allow_recursion == 1)
    return;
  }
  else if (!(readbyte[1] == 0) && (StartValue == 0))
  {
    Drum_RPM();
    if (allow_recursion == 1)
    return;
  }
  else if (StartValue > 0)
  {
    Auto_Start(readbyte);
    if (allow_recursion == 1)
    return;
  }
  else
  {
    if (debug = 1)
    {
      Serial.println("Problem in Calc_Start, we shouldn't see this!");
    }
    if (allow_recursion == 1)
    return;
  }

  if (allow_recursion == 1)
  return;
}   



void Gear_Ratio() {
  //  The gear ratio is determined by holding the engine at a CONSTANT 4000rpm
  //  and then the drum is measured.  Because the engine is at a known state
  //  the ratio of drum:engine can be calculated.  This way when the drum
  //  speed increases, you can guess the engine rpm value.  Its not perfect
  //  but it should work quite well for what it is.
  //  
  //  As a note, this is where i would like to make a specific hardware timing
  //  mechanism.  That way you can VERY accurately measure engine RPM regardless
  //  of drum speed.
  int sample[2];

  for(int x = 0; x < 10; x++) // loop this function set 10x, thats what the frontend wants
  {
    sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
    sample[1] = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for

    print_dec(2,sample);
  }
  Ending_Run();
  return;
}

void Test() {                           //  This just makes sure its spitting out data correctly
  int sample[1];                        // for the front end to see / calculate.
  
  for(int x = 0; x < 15; x++) // loop this function set 15x, thats what the frontend wants
  {
    sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
    
    print_dec(1,sample);
  }
  Ending_Run();
  return;
}

void Auto_Start(int readbyte []){
  int sample[1];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
  
  if (sample[0] == 0)
  {
    Auto_Start(readbyte);
    return;
  }
  else if (sample[0] < readbyte[3] && readbyte[1] == 0)
  {
    Drum_Only();
    return;
  }
  else if (sample[0] < StartValue && readbyte[1] != 0)
  {
    Drum_RPM();
    return;
  }
  
  return;
}

void Run_Down() {
  int sample[3];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for
  sample[2] = 0;

  print_hex(3,sample);
    
  if (sample[0] > sample[1])
  {
    Ending_Run();
    return;
  }
  else
  {
    Run_Down();
    return;
  }
  
  return;
}

void Ending_Run() {
  Serial.println("T");
  return;
}

void Drum_Only(){
  int sample[3];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for
  sample[2] = 0;

  print_hex(3,sample);
    
  if (sample[0] < sample[1])
  {
    Ending_Run();
    return;
  }
  else
  {
    Drum_Only();
    return;
  }
  
  return;
}

void Drum_RPM(){
  int sample[3];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH);
  sample[1] = pulseIn(Drum_HiLo, LOW);

  if (use_external_rpm_sensor = 1)
  {
    sample[2] = pulseIn(RPM_HiLo, HIGH);
  }
  else
  {
    sample[2] = 0;
  }

  print_hex(3,sample);
    	
  if (sample[0] < sample[1])
  {
    Ending_Run();
    return;
  }
  else
  {
    Drum_RPM();
    return;
  }
  
  return;
}

void simulate_dynorun()
{
  int highest1 = 20750; // 510E
  int highest2 = 20194; // 4EE2
  int lowest1 = 5197; // 144D
  int lowest2 = 5206; // 1456
  int samples = 30; // 30 lines
  int i = 0;
  int delay_timer = 500; // delay 500ms per message

  int difference1 = ((highest1 - lowest1) / samples);
  int difference2 = ((highest2 - lowest2) / samples);

  while (i < samples)
  {
	highest1 = (highest1 - difference1);
	highest2 = (highest2 - difference2);

	Serial.print(highest1,HEX); // change this to DEC if no good
        Serial.print(",");
        Serial.print(highest2,HEX); // change this to DEC if no good
        Serial.println(",0");

        delay(delay_timer);
	i++;
  }

  Serial.println("T");
}
