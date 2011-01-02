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

#include <ctype.h> // isalpha, isnumeric etc

// Start Setup variables
int pin = 0;
int playback_pin = 5;
int playback_buttonState = 0;
unsigned long duration;
int RPM_HiLo = 0; // listed as 1 in the PBasic source
int Drum_HiLo = 0; // listed as 1 in the PBasic source
int DrumIn = 0; // listed as 0 in the PBasic source
int use_external_rpm_sensor = 0; // set to 1 for yes
int debug = 0; // set to 1 for yes
int logging = 0; // use 0 to save memory
int current_line = 0;
char playback_string[200][20]; // 200 lines and 20 bytes per string (4000 bytes), Teensy++ 2.0 has 8192 total
int com_baud = 19200;
int simulate_drum = 1; // set to 1 to simulate drum
int bytesreceived = 0;
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

void loop() {        
  int available_bytes = 0;
  int buffer = 10; // allocate 10 bytes
  int readbyte[buffer];
  int i = 0;
  int arrayposition = 0;
  
  //'Where SSSSS is for 0 to 65535 for start figures
  //'S1,23400<cr> = Start,Spark every rev,23400 start count.
  int startcount_buffer = 5;
  int startcount_input[5] = { 0, 0, 0, 0, 0 }; // maybe default to 65535
  long int startcount = 0;
  int startcount_i = 0;
  
  if (logging == 1)
  {
    playback_buttonState = digitalRead(playback_pin);
    if (playback_buttonState == HIGH) 
    {
      playback_rawdata();
    }
  }
  
  available_bytes = Serial.available();

  // read the incoming byte string, one byte at a time, and assign each readbyte[0] - readbyte[1] respectively.
  // If there are no bytes available, skip this code block
  if (available_bytes > 0) 
  { 
    bytesreceived = (bytesreceived + available_bytes); // lets collect how many bytes in total the front end has sent
    
    while (i < available_bytes)
    {
      readbyte[i] = Serial.read();
      i++; 
    }
    
    if ( (readbyte[0] == 'A') || (readbyte[0] == 'a') )
    {
      About();
      return;
    }
    else if ( (readbyte[0] == 'S') && ( (readbyte[1] == '0') || (readbyte[1] == '1') || (readbyte[1] == '2') ) ) // if string is S0, S1 or S2
    {
      while (startcount_i < 5) // lets not wait for the 6th byte "," or space whatever it is
      {
        available_bytes = Serial.available();
        if (available_bytes > 0)
        {
          startcount_input[startcount_i] = Serial.read();
          startcount = (startcount*10 + (startcount_input[startcount_i] - 48)); // we take 48 away because 49 is the ASCII code for 1, so 50 - 49 = 1.. if startcount_input were 2, then it would be the ASCII code 50, take 48 and we have the number 2
          startcount_i++;
        }
      }
      Calc_Start(readbyte,startcount);
      return;
    }
    else if ( (readbyte[0] == 'G') || (readbyte[0] == 'g') )
    {
      Gear_Ratio();
      return;
    }
    else if ( (readbyte[0] == 'T') || (readbyte[0] == 't') )
    {
      Test();
      return;
    }
    else if ( (readbyte[0] == 'R') || (readbyte[0] == 'r') )
    {
      Run_Down();
      return;
    }
    else
    {
      return; // not a valid option
    }
  }
  return;  
}

void About() //  Fairly self explaitory.  It will dump this info  
{                                 
  Serial.println("Quan-Time WOTID firmware. Version 0.1"); 
  Serial.print("Bytes received: ");
  Serial.print(bytesreceived);
  Serial.println(", Configuration options: ");
    
  Serial.print("INPUT: Pin ");
  Serial.print(pin);
  Serial.print(", ");
  
  if (debug == 1)
    Serial.print("Debug ON, ");
  
  if (simulate_drum == 1)
    Serial.print("Simulate Drum ON, ");
    
  if (use_external_rpm_sensor == 1)
    Serial.print("External RPM Sensor ON, ");
    
  if (logging == 1)
  {
    Serial.print("Logging ON (");
    Serial.print(current_line);
    Serial.print("line(s) stored), ");
  }
  
  Serial.println("");
  return;
}

//  The 2nd byte of the string is read to determine if we are going to calculate
//  DRUM only, or Drum and simulated engine RPM.
void Calc_Start(int readbyte [], long int startcount) 
{                               
  if ((readbyte[1] == '0') && (startcount == 0)) // readbyte[1] is the 2nd byte: 0 for no spark pulses, 1 for spark every revolution, 2 for every 2nd revolution
  {
    if (simulate_drum == 1)
    {
      simulate_dynorun(readbyte, startcount);
      return;
    }
    else
    {
      Drum_Only();
      return;
    }
  }
  else if (!(readbyte[1] == '0') && (startcount == 0)) // readbyte[1] is the 2nd byte: 0 for no spark pulses, 1 for spark every revolution, 2 for every 2nd revolution
  {    
    if (simulate_drum == 1)
    {
      simulate_dynorun(readbyte, startcount);
      return;
    }
    else
    {
      Drum_RPM();
      return;
    }
  }
  else if (startcount > 0)
  {
    if (simulate_drum == 1)
    {
      simulate_dynorun(readbyte, startcount);
      return;
    }
    else
    {    
      Auto_Start(readbyte, startcount);
      return;
    }
  }
  else
  {
    return;
  }
  return;
}   



void Gear_Ratio() {
/*
  The gear ratio is determined by holding the engine at a CONSTANT 4000rpm
  and then the drum is measured.  Because the engine is at a known state
  the ratio of drum:engine can be calculated.  This way when the drum
  speed increases, you can guess the engine rpm value.  Its not perfect
  but it should work quite well for what it is.
 
  As a note, this is where i would like to make a specific hardware timing
  mechanism.  That way you can VERY accurately measure engine RPM regardless
  of drum speed.
*/
  long int sample[2]; // initiate an array with 2 element: sample[0] and sample[1]

  for(int x = 0; x < 10; x++) // loop this function set 10x, thats what the frontend wants
  {
    sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
    sample[1] = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for

    print_dec(sample);
  }
  Ending_Run();
  return;
}

void Test() {                           //  This just makes sure its spitting out data correctly
  long int sample[1];                        // for the front end to see / calculate.
  
  for(int x = 0; x < 15; x++) // loop this function set 15x, thats what the frontend wants
  {
    sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
    
    print_dec(sample);
  }
  Ending_Run();
  return;
}

void Auto_Start(int readbyte [], long int startcount){
  long int sample[1];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
  
  if (sample[0] == 0) // drum input timed out after 1 second of no input, try again immediately
  {
    Auto_Start(readbyte, startcount);
    return;
  }
  else if ( (sample[0] < startcount) && (readbyte[1] == '0') ) // if drum input is less than startvalue AND readbyte DOES = 0 is in reference to S0 (0 for no spark pulses)
  {
    Drum_Only();
    return;
  }
  else if ( (sample[0] < startcount) && !(readbyte[1] == '0') ) // if drum input is less than startvalue AND readbyte DOES NOT = 0, Sx is either S1 or S2 (1 for spark every revolution, 2 for every 2nd revolution)
  {
    Drum_RPM();
    return;
  }
  else
  {
    // insert code here if neither of the above are true
    return;
  }
  return;
}

void Run_Down() {
  long int sample[3];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for
  sample[2] = 0;

  print_hex(sample);
    
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
  long int sample[3];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for
  sample[2] = 0;

  print_hex(sample);
    
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
  long int sample[3];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH);
  sample[1] = pulseIn(Drum_HiLo, LOW);

  if (use_external_rpm_sensor == 1)
  {
    sample[2] = pulseIn(RPM_HiLo, HIGH);
  }
  else
  {
    sample[2] = 0;
  }

  print_hex(sample);
    	
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

// Below are common functions

void playback_rawdata()
{
  int i = 0;
  
  if (debug == 1)
  {
     Serial.println("Playing back rawdata");
  }
  
  for(int i = 0; i < current_line; i++)
  {
    if (debug == 1)
    {
      Serial.print("Line ");
      Serial.print(i);
      Serial.print(" of ");
      Serial.println(current_line);
    }
    
    Serial.print(playback_string[i,0]);
    Serial.print(",");
    Serial.print(playback_string[i,1]);
    Serial.print(",");
    Serial.print(playback_string[i,2]);
    Serial.println("");
  }
   
  Ending_Run();
  return;
}

void simulate_dynorun(int readbyte[], long int startcount) // use startcount to not send data slower than WOTID asks
{
  int highest1 = 20750; // 510E.. 510E,xxxx,x
  int highest2 = 20194; // 4EE2.. xxxx,4EE2,x
  int lowest1 = 5197; // 144D.. 144D,xxxx,x
  int lowest2 = 5206; // 1456.. xxxx,1456,x
  int lowrpm = 1000;
  int highrpm = 9000;
  int samples = 30; // how many lines to send to the front end
  int i = 0;
  int delay_timer = 1; // specify delay in milliseconds to messages sent to the front end
  long int sample[3];

  int difference1 = ((highest1 - lowest1) / samples);
  int difference2 = ((highest2 - lowest2) / samples);
  int difference3 = ((lowrpm + highrpm) / samples);

  delay(3000); // lets give the frontend time to set itself up, 3 secs
  
  if (readbyte[1] == '0') // no spark pulse
  {
    while (i < samples)
    {
	highest1 = (highest1 - difference1);
	highest2 = (highest2 - difference2);

        sample[0] = highest1;
        sample[1] = highest2;
        sample[2] = 0;

        print_hex(sample);

        delay(delay_timer);
	i++;
    }
  }
  else if (!(readbyte[1] == '0')) //1 =  spark pulse every revolution, 2 = spark pulse every 2nd revolution
  {
    while (i < samples)
    {
	highest1 = (highest1 - difference1);
	highest2 = (highest2 - difference2);
        lowrpm = (lowrpm + difference3);

        sample[0] = highest1;
        sample[1] = highest2;
        sample[2] = lowrpm;
        
        if ((readbyte[1] == '2') && (i % 2 == 0)) // emulate spark pulse every 2nd revolution
          sample[2] = 0; 
          
        print_hex(sample);

        delay(delay_timer);
	i++;
    }
  }
  Serial.println("T");

  //Serial.end(); // Should we close the connection?

  return;
}

// Let's analyze the provided character
void analyze_character(int character)
{
  Serial.print("Received character: ");
  Serial.println(character,BYTE);

  if (isalpha(character))
    Serial.println("byte is alphabetical");

  if (isdigit(character))
    Serial.println("byte is numerical");

  if (isblank(character))
    Serial.println("byte is a blank character");

  if (iscntrl(character))
    Serial.println("byte is a control character");

  if (isgraph(character))
    Serial.println("byte is graphic character");

  if (islower(character))
    Serial.println("byte is lowercase");

  if (isupper(character))
    Serial.println("byte is uppercase");

  if (ispunct(character))
    Serial.println("byte is punctuation");

  if (isspace(character))
    Serial.println("byte is a whitespace (tab)");

  if (isxdigit(character))
    Serial.println("byte is hexadecimal");

  if (isascii(character))
    Serial.println("byte is a ASCII character");

  if (character == ',')
    Serial.println("byte is a carriage return");

  return;
}

// Usage, if there are 2 samples, then you would do "print_hex(2,sample1, sample2, 0);" or if you had 3 samples then "print_hex(3,sample1, sample2, sample3);" or only 1 sample then "print_hex(1,sample1, 0, 0);"
void print_hex(long int sample [])
{
  int samples = (sizeof(sample)+1);
  
  if (debug == 1)
  {
    Serial.print("Ammount of samples: ");
    Serial.print(samples);
    Serial.print(" sample1: ");
    Serial.print(sample[0]);
    Serial.print(" sample2: ");
    Serial.print(sample[1]);
    Serial.print(" sample3: ");
    Serial.print(sample[3]);
    Serial.println("");
  }

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

  return;
}

// Usage see print_hex
void print_dec(long int sample [])
{
  int samples = (sizeof(sample)+1);
  
  if (debug == 1)
  {
    Serial.print("Ammount of samples: ");
    Serial.print(samples);
    Serial.print(" sample1: ");
    Serial.print(sample[0]);
    Serial.print(" sample2: ");
    Serial.print(sample[1]);
    Serial.print(" sample3: ");
    Serial.print(sample[3]);
    Serial.println("");
  }

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

  if (logging == 1)
  {
    current_line++;
    playback_string[current_line][0] = sample[0];
    playback_string[current_line][1] = sample[1];
    playback_string[current_line][2] = sample[2];
  }

  return;
}
