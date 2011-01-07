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

/*
  Start Configuration:
  
  Predefined Macro Name   Default Value (recommended) Description
  
  _LOGGING_               0       [0 = OFF, 1 = ON]  (Logging eats up the unit's memory)
  _SIMULATE_DRUM_         0       [0 = OFF, 1 = ON]  (Simulate Dynorun when "Make Run" is started in WOTID, turning this off uses the real Drum)
  _COM_BAUD_              19200                      (Serial connection baud rate)
  _DEBUG_                 0       [0 = OFF, 1 = ON]  (Debug information, useless to the WOTID frontend, only useful with a terminal connected)
  _EXTERNAL_RPM_SENSOR_   0       [0 = OFF, 1 = ON]  (Whether or not there is an external RPM sensor, use _RPM_HILO_ below to specify the Pin it's connected to)
  _PIN_                   0                          (Which Pin to make a Serial connection with)
  _DRUM_HILO_             0                          (Which Pin the Drum sensor is connected to)
  _IGNORE_STARTVALUE_     0       [0 = OFF, 1 = ON]  (Ignore the minimum start value (km/h) specified by WOTID, setting this to 1 will send all data to WOTID, even if it's below the start value)
  _STARTCOUNT_BUFFER_     5                          (Maximum ammount of bytes WOTID will send, when issuing "StartValue")
  _OPTICAL_TIMEOUT_       1000000                    (Maximum ammount of time in microseconds that the firmware will wait for a reply from the optical sensor, Arduino default is 1s, we could make it 100ms since the slowest sample we can send is 65.535ms)
  _SERIAL_BUFFER_         8                          (Ammount of bytes that should be pre-allocated to read the serial connection's buffer with, I've determined 8 is plenty "S065535," is the longest string I've seen the frontend generate)
  _FILTER_SLOW_SAMPLES_   0       [0 = OFF, 1 = ON]  (How we handle optical sensor values that are greater than _MAXIMUM_MICROSECOND_, 1 turns this on by filtering them so they don't appear in WOTID, 0 turns this off and just sends the value as 65535 instead)
  _CLOCK_FREQUENCY_       1                          (Has a huge affect on minimum starting speed. Measured in MHz, WOTID uses this value to divide every optical sensor value by, by setting a value that isn't 1 we override this behaviour and let the firmware do the math instead. 2 = 0.5, 1 = 1, 0.5 = 2, 0.225 = 4 etc.)
  _MAXIMUM_MICROSECOND_   65535                      (WOTID only accepts hexadecimal values up to FFFF, which is 65535, related to minimum starting value, if _CLOCK_FREQUENCY_ changes from 1, we might need to automatically adjust our max to suit)
  
*/
#define _LOGGING_ 0
#define _SIMULATE_DRUM_ 0
#define _COM_BAUD_ 19200
#define _DEBUG_ 0
#define _EXTERNAL_RPM_SENSOR_ 0
#define _PIN_ 0
#define _DRUM_HILO_ 0
#define _IGNORE_STARTVALUE_ 0
#define _STARTCOUNT_BUFFER_ 5
#define _OPTICAL_TIMEOUT_ 1000000
#define _SERIAL_BUFFER_ 8
#define _FILTER_SLOW_SAMPLES_ 1
#define _CLOCK_FREQUENCY_ 1
#define _MAXIMUM_MICROSECOND_ 65535
//#define _MAXIMUM_MICROSECOND_ (int)(65535 / _CLOCK_FREQUENCY_) // not used
/* End Configuration */ 

/* 
  Start Logging Configuration (ignored if LOGGING is OFF)

  _PLAYBACK_PIN_  5   (Use Pin 5 button press to playback logged data to the terminal in WOTID format)
  _MAX_LINES_     200 (Maximum ammount of lines to cache in memory, this will affect memory because it pre-allocates memory)
  _LINE_LENGTH_   16  (How much characters each line requires "FFFF,FFFF,FFFF" is 15 charactes, we reserve 16 so there is 1 byte of padding)
  
*/
#if (_LOGGING_ == 1)
  #define _PLAYBACK_PIN_ 5
  #define _MAX_LINES_ 200
  #define _LINE_LENGTH_ 16
#endif
/* End Logging Configuration */

/* 
  External RPM Sensor Configuration

  _RPM_HILO_  0  (Which Pin the RPM sensor is connected to)
  
*/
#define _RPM_HILO_ 0

/* Global Variables */
int bytesreceived = 0; // Count how many bytes the WOTID frontend has sent the firmware, only counts the important data, ignores B12345 in AB12345 for example (WOTID about string)
int startup = 0; // Used to calculate uptime
int current_line = 0; // Keep track of how many lines have been saved in memory so far, I really should change this to a local variable.. global variables are evil.
/* Logging Global Variables */
#if (_LOGGING_ == 1)
  char playback_string[_MAX_LINES_][_LINE_LENGTH_]; // _MAX_LINES_ * _LINE_LENGTH = the ammount of bytes this will allocate (200 * 15 = 3000bytes for example, Teensy++ 2.0 has 8192 bytes total), this really should be made a local variable somehow, it's an evil global variable
  int playback_buttonState = 0; // Status of button, whether it's been pressed or notr
#endif
/* End Logging Globals */
/* End Global Variables */

 // When Teensy is started or rebooted, this is the first function that is ran.
void setup()
{
  Serial.begin(_COM_BAUD_);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(_PIN_, INPUT); // Pin 0 should be connected to the optical sensor
  
  #if (_LOGGING_ == 1)
    pinMode(_PLAYBACK_PIN_, INPUT); // Pin 5 to playback current data
  #endif
  
  startup = millis(); // how many milliseconds have passed since the unix epoch (start from jan 1st 1970), we use this to mark when the Teensy unit was rebooted/started
}

// Our endless loop, With Arduino/Teensy there is no way to stop this loop, to save CPU cycles/power etc we could issue a delay(); otherwise optical sensor data is handled the instant it arrives
void loop() {        
  int available_bytes = 0;
  int readbyte[_SERIAL_BUFFER_];
  int i = 0;
  int arrayposition = 0;
  
  //'Where SSSSS is for 0 to 65535 for start figures
  //'S1,23400<cr> = Start,Spark every rev,23400 start count.
  int startcount_input[_STARTCOUNT_BUFFER_] = { 0, 0, 0, 0, 0 }; // maybe default to 65535
  long int startcount = 0; // hold "StartValue"
  int startcount_i = 0;
  
  #if (_LOGGING_ == 1)
    playback_buttonState = digitalRead(_PLAYBACK_PIN_);
    if (playback_buttonState == HIGH) 
    {
      playback_rawdata();
    }
  #endif
  
  available_bytes = Serial.available();

  // read the incoming byte string, one byte at a time, and assign each readbyte[0] - readbyte[1] respectively.
  // If there are no bytes available, skip this code block
  if (available_bytes > 0) 
  { 
    bytesreceived = (bytesreceived + available_bytes); // lets collect how many bytes in total the front end has sent
    
    while (i < available_bytes) // for every byte available, readbyte[0] holds the first byte, readbyte[1] holds the second byte etc
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
      #if (_IGNORE_STARTVALUE_ == 0)
      while (startcount_i < 5) // lets not wait for the 6th byte "," or space whatever it is. This could crash/infinite loop if the WOTID frontend only sends 4 numbers (like 9999 for example) 
      {
        available_bytes = Serial.available();
        if (available_bytes > 0)
        {
          startcount_input[startcount_i] = Serial.read(); // If Serial.read() is the number 9 for example, startcount_input[startcount_i] will equal 57. Why 57 though? That's the ASCII code for this number.
          
          if ((startcount_input[startcount_i] >= '0') && (startcount_input[startcount_i] <= '9')) // if startcount_input[startcount_i] is any number between 0 & 9. (because we don't want to try to do multiplication below on an alphabetical letter for example)
            startcount = (startcount*10 + (startcount_input[startcount_i] - 48)); // we take 48 away because 49 is the ASCII code for 1, so 50 - 49 = 1.. if startcount_input were 2, then it would be the ASCII code 50, take 48 and we have the number 2
          
          startcount_i++;
        }
      }
      #endif
      #if (_IGNORE_STARTVALUE_ == 1)
        startcount = 0;
      #endif
      
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
  Serial.print("Compiled on ");
  Serial.print(__DATE__);
  Serial.print(" @ ");
  Serial.print(__TIME__);
  Serial.print(" w/ GCC: ");
  Serial.print(__GNUC__);
  Serial.print(".");
  Serial.print(__GNUC_MINOR__);
  Serial.print(".");
  Serial.println(__GNUC_PATCHLEVEL__);
  Serial.print("Uptime: ");
  uptime();
  Serial.print(", Free Memory: ");
  freemem_output();
  Serial.print(", Bytes received: ");
  Serial.println(bytesreceived);
  Serial.print("Config options: ");

  Serial.print("Optical In: Pin ");
  Serial.print(_PIN_);
  Serial.print(" (timeout: ");
  
  Serial.print( (_OPTICAL_TIMEOUT_ / 1000) );
  Serial.print("ms) ");
  
  #if (_DEBUG_ == 1)
    Serial.print("Debug ON, ");
  #endif
  
  #if (_SIMULATE_DRUM_ == 1)
    Serial.print("Simulate Drum ON, ");
  #endif
    
  #if (_EXTERNAL_RPM_SENSOR_ == 1)
    Serial.print("External RPM Sensor ON, ");
  #endif
  
  #if (_IGNORE_STARTVALUE_ == 1)
    Serial.print("Ignore Start Value ON, ");
  #endif
    
  #if (_LOGGING_ == 1)
    Serial.print("Logging ON (");
    Serial.print(current_line);
    Serial.print(" out of ");
    Serial.print(_MAX_LINES_);
    Serial.print("line(s) cached), ");
  #endif
  
  Serial.println("");
  return;
}

//  The 2nd byte of the string is read to determine if we are going to calculate
//  DRUM only, or Drum and simulated engine RPM.
void Calc_Start(int readbyte [], long int startcount) 
{                               
  if ((readbyte[1] == '0') && (startcount == 0)) // readbyte[1] is the 2nd byte: 0 for no spark pulses, 1 for spark every revolution, 2 for every 2nd revolution
  {
    #if (_SIMULATE_DRUM_ == 1)
      simulate_dynorun(readbyte, startcount);
    #else
      Drum_Only();
    #endif
    return;
  }
  else if (!(readbyte[1] == '0') && (startcount == 0)) // readbyte[1] is the 2nd byte: 0 for no spark pulses, 1 for spark every revolution, 2 for every 2nd revolution
  {    
    #if (_SIMULATE_DRUM_ == 1)
      simulate_dynorun(readbyte, startcount);
    #else
      Drum_RPM();
    #endif
    return;
  }
  else if (startcount > 0)
  {
    #if (_SIMULATE_DRUM_ == 1)
      simulate_dynorun(readbyte, startcount);
    #else
      Auto_Start(readbyte, startcount);
    #endif
    return;
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
    sample[0] = pulseIn(_DRUM_HILO_, HIGH, _OPTICAL_TIMEOUT_); // measure how long the tooth is on for, store it in "sample1"
    sample[1] = pulseIn(_DRUM_HILO_, LOW, _OPTICAL_TIMEOUT_); // measure how long the tooth is off for

    // Should we check if these samples are greater than _MAXIMUM_MICROSECOND_ (65535) first? no because the frontend accepts a decimal value
    print_dec(sample);
  }
  Ending_Run();
  return;
}

void Test() {                           //  This just makes sure its spitting out data correctly
  long int sample[1];                        // for the front end to see / calculate.
  
  for(int x = 0; x < 15; x++) // loop this function set 15x, thats what the frontend wants
  {
    sample[0] = pulseIn(_DRUM_HILO_, HIGH); // measure how long the tooth is on for, store it in "sample1"
    
    // Should we check if these samples are greater than _MAXIMUM_MICROSECOND_ (65535) first? no because the frontend accepts a decimal value
    print_dec(sample);
  }
  Ending_Run();
  return;
}

void Auto_Start(int readbyte [], long int startcount){
  long int sample[1];
  
  sample[0] = pulseIn(_DRUM_HILO_, HIGH, _OPTICAL_TIMEOUT_); // measure how long the tooth is on for, store it in "sample1"
  
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
  
  // We need to detect that the drum is slowing down, so I don't think _OPTICAL_TIMEOUT_ applies here, it will default to 1 second anyway (set by Arduino).. perhaps we should even allow up to 10 second timeouts
  sample[0] = pulseIn(_DRUM_HILO_, HIGH); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(_DRUM_HILO_, LOW); // measure how long the tooth is off for
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

// Perhaps we could use this function later to free memory we've used so far
void Ending_Run() {
  Serial.println("T");
  return;
}

// AS the name suggests, just the drum without RPM input
void Drum_Only(){
  long int sample[3];
  
  sample[0] = pulseIn(_DRUM_HILO_, HIGH, _OPTICAL_TIMEOUT_); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(_DRUM_HILO_, LOW, _OPTICAL_TIMEOUT_); // measure how long the tooth is off for
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

// Drum + RPM input
void Drum_RPM(){
  long int sample[3];
  
  sample[0] = pulseIn(_DRUM_HILO_, HIGH, _OPTICAL_TIMEOUT_);
  sample[1] = pulseIn(_DRUM_HILO_, LOW, _OPTICAL_TIMEOUT_);

  #if (_EXTERNAL_RPM_SENSOR_ == 1)
    sample[2] = pulseIn(_RPM_HILO_, HIGH); // timeout will default to 1second (Arduino)
  #else
    sample[2] = 0;
  #endif

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

#if (_LOGGING_ == 1)
void playback_rawdata()
{
  int i = 0;
  
  #if (_DEBUG_ == 1)
     Serial.println("Playing back rawdata");
  #endif
  
  for(int i = 0; i < current_line; i++)
  {
    #if (_DEBUG_ == 1)
      Serial.print("Line ");
      Serial.print(i);
      Serial.print(" of ");
      Serial.println(current_line);
    #endif
    
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
#endif

#if (_SIMULATE_DRUM_ == 1)
#define _DELAY_TIMER_ 1 // specify delay in milliseconds to messages sent to the front end
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
        
        #if (_IGNORE_STARTVALUE_ == 0)
          if (sample[0] < startcount) // if sample[0] is slower than what the frontend asked (StartValue), don't send it
            print_hex(sample);
        #else
          print_hex(sample);
        #endif

        delay(_DELAY_TIMER_);
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
          
        #if (_IGNORE_STARTVALUE_ == 0)
          if (sample[0] < startcount) // if sample[0] is slower than what the frontend asked (StartValue), don't send it
            print_hex(sample);
        #else
          print_hex(sample);
        #endif

        delay(_DELAY_TIMER_);
	i++;
    }
  }
  Serial.println("T");

  //Serial.end(); // Should we close the connection?

  return;
}
#endif

// Common function used by all our code (even simulate_dynorun) that send Hexadecimal values over the serial link. The function that actually sends the HEX numbers to the frontend like: FFFF,FFFF,0 which in decimal means 65535,65535,0
void print_hex(long int sample [])
{
  int samples = (sizeof(sample)+1); // WOTID always expects 3 hex values that are seperated by carriage returns so we could set this static to 3 isntead of determining how many array elements are in 'sample'

  #if (!(_CLOCK_FREQUENCY_ == 1)) // if _CLOCK_FREQUENCY_ does NOT equal 1 (let'e not bother to divide by 1 as its a waste of time)
    sample[0] = (sample[0] / _CLOCK_FREQUENCY_); // if sample[0] equals 65535, and _CLOCK_FREQUENCY_ equals 0.5, then sample[0] becomes 131070 (65535 / 0.5), or if _CLOCK_FREQUENCY_ equals 2, then sample[0] becomes 32767.5 (65535 / 2)
    
    if (samples > 1)
      sample[1] = (sample[1] / _CLOCK_FREQUENCY_);
    
    if (_EXTERNAL_RPM_SENSOR_ == 1) // does WOTID apply "Clock Frequency" to RPM values? we probably won't know unless we actually provided it with RPM data by an external RPM sensor.
      sample[2] = (sample[2] / _CLOCK_FREQUENCY_); 
  #endif 

  #if (_FILTER_SLOW_SAMPLES_ == 0)
    if (sample[0] > _MAXIMUM_MICROSECOND_) // if sample1 (sample[0]) is greater than 65535
      sample[0] = _MAXIMUM_MICROSECOND_; // if sample[0] were 130000 microseconds, we wouldn't be able to send it as a 4 char HEX code, as it is represented as 1FBD0 in HEX (5 chars)
    
    if ((sample[1] > _MAXIMUM_MICROSECOND_) && (samples > 1)) // same as above, but also let's check there actually is a 2nd sample (LOW)
      sample[1] = _MAXIMUM_MICROSECOND_;
  #else
    if ((sample[0] > _MAXIMUM_MICROSECOND_) || (sample[1] > _MAXIMUM_MICROSECOND_))
      return; // if either of the above is true, then let's filter out this result and exit out of this function
  #endif
  
  #if (_DEBUG_ == 1)
    Serial.print("Ammount of samples: ");
    Serial.print(samples);
    Serial.print(" sample1: ");
    Serial.print(sample[0]);
    Serial.print(" sample2: ");
    Serial.print(sample[1]);
    Serial.print(" sample3: ");
    Serial.print(sample[3]);
    Serial.println("");
  #endif
  
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

  #if (_LOGGING_ == 1)
    current_line++;
    playback_string[current_line][0] = sample[0];
    playback_string[current_line][1] = sample[1];
    playback_string[current_line][2] = sample[2];
  #endif

  return;
}

// Usage see print_hex
void print_dec(long int sample [])
{
  int samples = (sizeof(sample)+1);

  #if (!(_CLOCK_FREQUENCY_ == 1)) // if _CLOCK_FREQUENCY_ does NOT equal 1 (let'e not bother to divide by 1 as its a waste of time)
    sample[0] = (sample[0] / _CLOCK_FREQUENCY_); // if sample[0] equals 65535, and _CLOCK_FREQUENCY_ equals 0.5, then sample[0] becomes 131070 (65535 / 0.5), or if _CLOCK_FREQUENCY_ equals 2, then sample[0] becomes 32767.5 (65535 / 2)
    
    if (samples > 1) // GearRatio() only requires 1 sample (HIGH), whereas Test() requires 2 samples (HIGH & LOW)
      sample[1] = (sample[1] / _CLOCK_FREQUENCY_);
  #endif 
  
  #if (_DEBUG_ == 1)
    Serial.print("Ammount of samples: ");
    Serial.print(samples);
    Serial.print(" sample1: ");
    Serial.print(sample[0]);
    Serial.print(" sample2: ");
    Serial.print(sample[1]);
    //Serial.print(" sample3: "); // WOTID doesn't ask for more than 2 decimal values seperated by a carriage return, so this is redundant and useless, thus commented out
    //Serial.print(sample[3]);
    Serial.println("");
  #endif

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

  #if (_LOGGING_ == 1)
    current_line++;
    playback_string[current_line][0] = sample[0];
    playback_string[current_line][1] = sample[1];
    playback_string[current_line][2] = sample[2];
  #endif

  return;
}

void uptime()
{
  long int days, hours, mins;
  long int currentuptime = ((millis() - startup) /1000);

  days = currentuptime / 86400;
  hours = (currentuptime / 3600) - (days * 24);
  mins = (currentuptime / 60) - (days * 1440) - (hours * 60);
  
  if (days > 0)
  {
    Serial.print(days);
    Serial.print("d");
  }
  if (hours > 0)
  {
    Serial.print(hours);
    Serial.print("h");
  }
  if (mins > 0)
  {
    Serial.print(mins);
    Serial.print("m");
  }
  Serial.print(currentuptime % 60);
  Serial.print("s");

  return;
}

extern int  __bss_end; 
extern int  *__brkval; 
int freemem(){ 
 int free_memory; 
 if((int)__brkval == 0) 
   free_memory = ((int)&free_memory) - ((int)&__bss_end); 
 else 
   free_memory = ((int)&free_memory) - ((int)__brkval); 
 return free_memory; 
}

void freemem_output()
{
  float freememory = freemem();
  
  if (freememory >= 1024)
  {
    Serial.print((freememory/1024));
    Serial.print("kb(s)");
  }
  else
  {
    Serial.print(freememory); // no decimal places
    Serial.print("b(s)");
  }
  
  return;
}
