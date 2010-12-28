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
  Serial.begin(com_baud);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
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
  int string2 = 0; // This is where the above (string1) is converted from a string to int 
  char tempbyte[2];

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
  
    while (i < available_bytes && i <= 10) // stop at 10 bytes or we will crash 
    {
      readbyte[i] = Serial.read();   //  let's start reading 1 byte at a time
      
      if ( (available_bytes > 3) && (isalpha(readbyte[0])) && (isdigit(readbyte[i]))) // if there are more than 3 bytes (AB,) then lets use the remaining bytes as StartValue, lets also make sure the first byte is alpha (A-Z a-z) and the byte we are reading is a number (this will filter out letters, commas etc)
      {
        //string1 += readbyte[i]; // append each byte to string1 (placeholder for StartValue) // this requires Arduino 0019
        
        // C alternative for above
        sprintf( tempbyte, "%s", readbyte[i] ); // save the incoming byte as a single character string
        strcat(string1, tempbyte); // append tempbyte to string (example. string1 = "hello" and tempbyte = "a", then string1 becomes "helloa"
      }
      
      i++; //increase by 1
    }
    
    string2 = atoi(string1); // convert string into int

    Serial.flush();

    if ( isalpha(readbyte[0]) )
    {
    switch (readbyte[0]) {  //  readbyte[0] is either A, S, G, T or R.  This reads that byte
    case 'A':         //  and does a conditional state.
    case 'a':
      About();
      break;
    case 'S':       
    case 's':
      Calc_Start(readbyte,string2);
      break;
    case 'G':
    case 'g':
      Gear_Ratio();
      break;        
    case 'T':
    case 't':
      Test();
      break;      
    case 'R':
    case 'r':
      Run_Down();
      break;
    default:
      if (debug == 1)
      {
        Serial.print(readbyte[0]);
        Serial.println(" is invalid!");
      }
      StartValue = 000;
      readbyte[0] = 0;
      break;
    }
   }
   else
   {      
     StartValue = 000;
     readbyte[0] = 0;
   }
  }
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
Serial.println("510E,4EE2,0");
Serial.println("4CE5,4B15,0");
Serial.println("4968,47D8,0");
Serial.println("465F,450B,0");
Serial.println("43D0,429F,0");
Serial.println("4180,4076,0");
Serial.println("3F78,3E77,0");
Serial.println("3D83,3C9A,0");
Serial.println("3BAD,3ACC,0");
Serial.println("39F5,392A,0");
Serial.println("3866,37A5,0");
Serial.println("36ED,3640,0");
Serial.println("3596,34EC,0");
Serial.println("3444,33AA,0");
Serial.println("330E,3277,0");
Serial.println("31E9,3156,0");
Serial.println("30CB,3046,0");
Serial.println("2FC0,2F41,0");
Serial.println("2EC0,2E49,0");
Serial.println("2DD2,2D5D,0");
Serial.println("2CED,2C84,0");
Serial.println("2C1A,2BB2,0");
Serial.println("2B4D,2AEC,0");
Serial.println("2A8B,2A2E,0");
Serial.println("29D1,2976,0");
Serial.println("291D,28C5,0");
Serial.println("2872,281F,0");
Serial.println("27CE,2780,0");
Serial.println("2732,26E4,0");
Serial.println("2696,264F,0");
Serial.println("2604,25BF,0");
Serial.println("257A,2539,0");
Serial.println("24F6,24BA,0");
Serial.println("247E,2445,0");
Serial.println("240E,23D6,0");
Serial.println("23A1,236A,0");
Serial.println("2335,2300,0");
Serial.println("22C9,2293,0");
Serial.println("225D,2227,0");
Serial.println("21F1,21BA,0");
Serial.println("2186,2154,0");
Serial.println("2121,20F0,0");
Serial.println("20BD,208C,0");
Serial.println("205D,2031,0");
Serial.println("2003,1FD4,0");
Serial.println("1FA8,1F7D,0");
Serial.println("1F51,1F24,0");
Serial.println("1EFD,1ED6,0");
Serial.println("1EB0,1E89,0");
Serial.println("1E65,1E40,0");
Serial.println("1E1C,1DFD,0");
Serial.println("1DDD,1DBB,0");
Serial.println("1D95,1D74,0");
Serial.println("1D53,1D34,0");
Serial.println("1D13,1CF1,0");
Serial.println("1CD2,1CB1,0");
Serial.println("1C96,1C7A,0");
Serial.println("1C5B,1C3C,0");
Serial.println("1C21,1C05,0");
Serial.println("1BE9,1BCD,0");
Serial.println("1BB3,1B97,0");
Serial.println("1B79,1B5F,0");
Serial.println("1B48,1B2E,0");
Serial.println("1B12,1AF7,0");
Serial.println("1ADF,1AC6,0");
Serial.println("1AAF,1A95,0");
Serial.println("1A79,1A5F,0");
Serial.println("1A49,1A36,0");
Serial.println("1A1E,1A01,0");
Serial.println("19EA,19D6,0");
Serial.println("19A9,1992,0");
Serial.println("1966,1952,0");
Serial.println("1927,1911,0");
Serial.println("18EA,18D5,0");
Serial.println("18AD,189B,0");
Serial.println("1872,1861,0");
Serial.println("183B,182A,0");
Serial.println("1808,17F4,0");
Serial.println("17D6,17C5,0");
Serial.println("17A3,1794,0");
Serial.println("1774,1764,0");
Serial.println("1746,1736,0");
Serial.println("1719,170A,0");
Serial.println("16ED,16DF,0");
Serial.println("16C3,16B5,0");
Serial.println("1698,168B,0");
Serial.println("1671,1662,0");
Serial.println("164A,163C,0");
Serial.println("1622,1618,0");
Serial.println("15FE,15F2,0");
Serial.println("15DC,15CD,0");
Serial.println("15B6,15AC,0");
Serial.println("1595,158A,0");
Serial.println("1577,1569,0");
Serial.println("1553,154A,0");
Serial.println("1533,152A,0");
Serial.println("1515,1509,0");
Serial.println("14F9,14EF,0");
Serial.println("14DB,14D2,0");
Serial.println("14BD,14B6,0");
Serial.println("14A4,149A,0");
Serial.println("1487,147F,0");
Serial.println("146B,146B,0");
Serial.println("1462,1457,0");
Serial.println("1452,144E,0");
Serial.println("1444,1440,0");
Serial.println("143E,143D,0");
Serial.println("144D,1456,0");
Serial.println("T");
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