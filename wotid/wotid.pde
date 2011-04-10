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

#include "config.h" 

// When Teensy is started or rebooted, this is the first function that is ran.
void setup()
{
  //CPU_PRESCALE(CPU_500kHz); // Can be used to change the clock speed of the CPU, in this instance would set the speed during the device's startup.
  //#define _CPU_OVERRIDE_ "0.5mHz" // just for our sake, if we're not overriding the cpu speed just comment this line out

  Serial.begin(_COM_BAUD_);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(_PIN_, INPUT); // Pin 0 should be connected to the optical sensor
  pinMode(_LED_PIN_, OUTPUT); // initialize LED
  
  ledState = LOW; // LED is default off
  
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
  unsigned long startcount = 0; // hold "StartValue"
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
    // following 3 lines would bring the CPU out of sleep/idle and back to 16MHz
    //cli();
    //CPU_PRESCALE(CPU_16MHz);
    //sei(); 
    
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
    else if ( ((readbyte[0] == 'S') || (readbyte[0] == 's')) && ( (readbyte[1] == '0') || (readbyte[1] == '1') || (readbyte[1] == '2') ) ) // if string is S0, S1 or S2
    {
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
      #if (_IGNORE_STARTVALUE_ == 1)
        startcount = 0;
      #endif
      
      Calc_Start(readbyte,startcount);
      return;
    }
    else if ( (readbyte[0] == 'G') || (readbyte[0] == 'g') )
    {
      #if (_SIMULATE_GEAR_RATIO_ == 1)
        simulate_autocalc();
      #else
        Gear_Ratio();
      #endif 
      
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
  //else
  //{
      //cli();
      //CPU_PRESCALE(CPU_125kHz); // Available bytes is 0 so we could effectively put the unit to sleep
      //sei();
  //}
  return;  
}

void About() //  Fairly self explaitory.  It will dump this info  
{                                 
  Serial.println(_VERSION_STRING_); 
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

  #if (_SYSTEM_INFO_ == 1)

  #ifdef _CPU_OVERRIDE_
  Serial.print("CPU: ");
  Serial.print(_CPU_OVERRIDE_);
  Serial.print(",");
  #endif

  Serial.print(" Uptime: ");
  uptime();
  Serial.print(", Free Mem: ");
  freemem_output();
  //Serial.print(", Bytes received: ");
  //Serial.println(bytesreceived);
  #endif
  Serial.print(" Config = ");

  Serial.print("Optic: Pin ");
  Serial.print(_PIN_);
  
  optical_timeout();
  
  Serial.print("End Run: ");
  Serial.print(_END_RUN_);
  Serial.print("x, ");
  
  #if (_TOOTH_SKIP_ >= 1)
    Serial.print("Tooth Skip: ");
    Serial.print(_TOOTH_SKIP_);
    Serial.print(", ");
  #endif
  
  #if (_DEBUG_ == 1)
    Serial.print("Debug ON, ");
  #endif
  
  #if (_SIMULATE_DRUM_ == 1)
    Serial.print("Sim Drum ON, ");
  #endif
  
  #if (_SIMULATE_GEAR_RATIO_ == 1)
    Serial.print("Sim Gear Ratio ON, ");
  #endif  
    
  #if (_EXTERNAL_RPM_SENSOR_ == 1)
    Serial.print("Ex RPM Sensor ON, ");
  #endif
  
  #if (_IGNORE_STARTVALUE_ == 1)
    Serial.print("Ignore Start Value ON, ");
  #endif
  
  #if (_FILTER_SLOW_SAMPLES_ == 1)
    Serial.print("Filter Slow Samples ON, ");
  #endif
  
  #if (_CLOCK_FREQUENCY_ != 1)
    Serial.print("Clock Freq ");
    Serial.print(_CLOCK_FREQUENCY_);
    Serial.print("MHz, ");
  #endif
  
  Serial.print("Min Samples: ");
  Serial.print(_MINIMUM_SAMPLES_);
  
  Serial.print(", Makerun Timeout (s): ");
  Serial.print((_MAKERUN_TIMEOUT_ / 1000));
    
  #if (_LOGGING_ == 1)
    Serial.print(", Logging ON (");
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
void Calc_Start(int readbyte [], unsigned long startcount) 
{                               
  if ((readbyte[1] == '0') && (startcount == 0)) // readbyte[1] is the 2nd byte: 0 for no spark pulses, 1 for spark every revolution, 2 for every 2nd revolution
  {
    #if (_SIMULATE_DRUM_ == 1)
      simulate_dynorun(readbyte, startcount);
    #else
      Drum_Only(0,millis(),0); // we initialize Drum_Only with 0 because 0 indicates how many deceleration samples we have detected.
    #endif
    return;
  }
  else if (!(readbyte[1] == '0') && (startcount == 0)) // readbyte[1] is the 2nd byte: 0 for no spark pulses, 1 for spark every revolution, 2 for every 2nd revolution
  {    
    #if (_SIMULATE_DRUM_ == 1)
      simulate_dynorun(readbyte, startcount);
    #else
      Drum_RPM(0);
    #endif
    return;
  }
  else if (startcount > 0)
  {
    #if (_SIMULATE_DRUM_ == 1)
      simulate_dynorun(readbyte, startcount);
    #else
      Auto_Start(readbyte, startcount, millis());
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
  unsigned long sample[2]; // initiate an array with 2 element: sample[0] and sample[1]

  delay(_WOTID_FRONTEND_DELAY_); // the frontend has a wierd delay so we wait 3 seconds before we send data

  for(int x = 0; x < 10; x++) // loop this function set 10x, thats what the frontend wants
  {
    sample[0] = pulseIn(_DRUM_HILO_, _TOOTH_1_, _OPTICAL_TIMEOUT_); // Time it takes for this tooth
    
    if (_BETWEEN_SAMPLE_PAUSE_ > 0)
      delayMicroseconds(_BETWEEN_SAMPLE_PAUSE_);
    
    sample[1] = pulseIn(_DRUM_HILO_, _TOOTH_2_, _OPTICAL_TIMEOUT_); // to arrive to this tooth

    // Should we check if these samples are greater than _MAXIMUM_MICROSECOND_ (65535) first? no because the frontend accepts a decimal value
    print_dec(2,sample);
  }
  Ending_Run();
  return;
}

// Used with WOTID's calibration tool, will send 15x samples to it.
void Test() {                           //  This just makes sure its spitting out data correctly
  unsigned long sample[1];                        // for the front end to see / calculate.
  
  for(int x = 0; x < 15; x++) // loop this function set 15x, thats what the frontend wants
  {
    sample[0] = pulseIn(_DRUM_HILO_, _TOOTH_1_);
    
    // Should we check if these samples are greater than _MAXIMUM_MICROSECOND_ (65535) first? no because the frontend accepts a decimal value
    print_dec(1,sample);
  }
  Ending_Run();
  return;
}

void Auto_Start(int readbyte [], unsigned long startcount, unsigned long startrun){
  unsigned long sample[1];
  unsigned long elasped_time = (millis() - startrun);
  
  sample[0] = pulseIn(_DRUM_HILO_, _TOOTH_1_, _OPTICAL_TIMEOUT_); // measure how long the tooth is on for, store it in "sample1"
  
  if ( (sample[0] == 0) || (sample[0] > _MAXIMUM_MICROSECOND_) )// drum input timed out after 1 second of no input, try again immediately, or samples was too slow (_MAXIMUM_MICROSECOND_)
  {
    LED_blink(); // This will blink with _OPTICAL_TIMEOUT_, every 1 second, to indicate we are waiting for data

    if (elasped_time >= _MAKERUN_TIMEOUT_) // lets give it this many counts before we exit back to the loop
    {
      Serial.println("0,0,0"); // we send this so the frontend will auto-end
      Ending_Run();
      return;
    }

    Auto_Start(readbyte, startcount, startrun);
    return;
  }
  else if ( (sample[0] < startcount) && (readbyte[1] == '0') ) // if drum input is less than startvalue AND readbyte DOES = 0 is in reference to S0 (0 for no spark pulses)
  {
    Drum_Only(0,millis(),0);
    return;
  }
  else if ( (sample[0] < startcount) && !(readbyte[1] == '0') ) // if drum input is less than startvalue AND readbyte DOES NOT = 0, Sx is either S1 or S2 (1 for spark every revolution, 2 for every 2nd revolution)
  {
    Drum_RPM(0);
    return;
  }
  else
  {
    // insert code here if neither of the above are true
    LED_blink(); // This will blink with _OPTICAL_TIMEOUT_, every 1 second, to indicate we are waiting for data

    if (elasped_time >= _MAKERUN_TIMEOUT_) // lets give it this many counts before we exit back to the loop
    {
      Serial.println("0,0,0"); // we send this so the frontend will auto-end
      Ending_Run();
      return;
    }
    
    Auto_Start(readbyte, startcount, startrun);
    return;
  }
  return;
}

void Run_Down() {
  unsigned long sample[3];
  
  // We need to detect that the drum is slowing down, so I don't think _OPTICAL_TIMEOUT_ applies here, it will default to 1 second anyway (set by Arduino).. perhaps we should even allow up to 10 second timeouts
  sample[0] = pulseIn(_DRUM_HILO_, _TOOTH_1_);
  
  if (_BETWEEN_SAMPLE_PAUSE_ > 0)
    delayMicroseconds(_BETWEEN_SAMPLE_PAUSE_);  
  
  sample[1] = pulseIn(_DRUM_HILO_, _TOOTH_2_);
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

// Perhaps we could use this function later to free memory we've used so far
void Ending_Run() {
  Serial.println("T");
  LED_switch(LOW); // switch LED off if it is on
  return;
}

// AS the name suggests, just the drum without RPM input
void Drum_Only(int end_run_counter, unsigned long startrun, int samplecount){
  unsigned long sample[3];
  unsigned long elasped_time = (millis() - startrun);
  
  if (elasped_time >= _MAKERUN_TIMEOUT_)
  {
    Serial.println("0,0,0"); // lets clear the frontend
    Ending_Run();
    return;  
  }
  if ( (end_run_counter >= _END_RUN_) && (samplecount >= _MINIMUM_SAMPLES_) ) /// confirmed, so and so ammount of samples in a row are indicating decelleration of the drum, so lets end the run
  {
    Ending_Run();
    return;
  }
  
  if (ledState == HIGH) // turn off LED before 1st tooth sample
    LED_switch(LOW);
  
  sample[0] = pulseIn(_DRUM_HILO_, _TOOTH_1_, _OPTICAL_TIMEOUT_);
  LED_switch(HIGH); // turn LED on
  
  if (_BETWEEN_SAMPLE_PAUSE_ > 0)
    delayMicroseconds(_BETWEEN_SAMPLE_PAUSE_);  
  
  sample[1] = pulseIn(_DRUM_HILO_, _TOOTH_2_, _OPTICAL_TIMEOUT_);
  LED_switch(LOW); // switch it off again
  sample[2] = 0;
    
  if ( (sample[0] < sample[1]) || ((sample[0] == 0) && (sample[1] == 0)) ) // if tooth 1 is less than tooth 2
  {
    end_run_counter++; // let's increment our counter by 1
    Drum_Only(end_run_counter,startrun,samplecount++);
    return;
  }
  else
  {
    end_run_counter = 0; // not slowing down, so lets reset back to 0
    print_hex(3,sample);
    Drum_Only(end_run_counter,millis(),samplecount++);
    return;
  }
  return;
}

// Drum + RPM input
void Drum_RPM(int end_run_counter){
  unsigned long sample[3];

  if (ledState == HIGH) // turn off LED before 1st tooth sample
    LED_switch(LOW);  

  sample[0] = pulseIn(_DRUM_HILO_, _TOOTH_1_, _OPTICAL_TIMEOUT_);
  LED_switch(HIGH); // turn LED on
  
  if (_BETWEEN_SAMPLE_PAUSE_ > 0)
    delayMicroseconds(_BETWEEN_SAMPLE_PAUSE_);  
  
  sample[1] = pulseIn(_DRUM_HILO_, _TOOTH_2_, _OPTICAL_TIMEOUT_);
  LED_switch(LOW); // switch it off again
  
  #if (_EXTERNAL_RPM_SENSOR_ == 1)
    sample[2] = pulseIn(_RPM_HILO_, _RPM_); // timeout will default to 1second (Arduino)
  #else
    sample[2] = 0;
  #endif

  print_hex(3,sample);
    	
  if (sample[0] < sample[1]) // if tooth 1 is less than tooth 2
    end_run_counter++; // let's increment our counter by 1
  else
    end_run_counter = 0; // not slowing down, so lets reset back to 0
    
  if (end_run_counter >= _END_RUN_) // confirmed, so and so ammount of samples in a row are indicating decelleration of the drum, so lets end the run
  {
    Ending_Run();
    return;
  }
  else
  {
    Drum_RPM(end_run_counter);
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

void simulate_autocalc()
{
  unsigned long sample[2];
  sample[0] = 18000; // my zzr250 at approx 38km/h in 4th gear at 4000rpm
  sample[1] = 18000;
  int i = 0;
  
  delay(_WOTID_FRONTEND_DELAY_);
  
  while (i != 10)
  {
    LED_blink();
    print_dec(2, sample);
    delay(1);
    i++;
  }
  
  Serial.println("T");
  
  return;
}

#if (_SIMULATE_DRUM_ == 1)
#define _DELAY_TIMER_ 1 // specify delay in milliseconds to messages sent to the front end
void simulate_dynorun(int readbyte[], unsigned long startcount) // use startcount to not send data slower than WOTID asks
{
  unsigned int highest1 = 50000; // 510E.. 510E,xxxx,x
  unsigned int highest2 = 49000; // 4EE2.. xxxx,4EE2,x
  unsigned int lowest1 = 4000; // 144D.. 144D,xxxx,x
  unsigned int lowest2 = 400; // 1456.. xxxx,1456,x
  unsigned int lowrpm = 1000;
  unsigned int highrpm = 9000;
  int samples = 80; // how many lines to send to the front end
  int i = 0;
  unsigned long sample[3];

  int difference1 = ((highest1 - lowest1) / samples);
  int difference2 = ((highest2 - lowest2) / samples);
  int difference3 = ((lowrpm + highrpm) / samples);

  delay(_WOTID_FRONTEND_DELAY_); // lets give the frontend time to set itself up, 3 secs
  
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
            print_hex(3,sample);
        #else
          print_hex(3,sample);
        #endif
        LED_blink();

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
            print_hex(3,sample);
        #else
          print_hex(3,sample);
        #endif
        LED_blink();

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
void print_hex(int samples, unsigned long sample [])
{
  //int samples = (sizeof(sample)+1); // WOTID always expects 3 hex values that are seperated by carriage returns so we could set this static to 3 isntead of determining how many array elements are in 'sample'

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
  
 #if (_LOGGING_ == 1)
    current_line++;
    playback_string[current_line][0] = sample[0];
    playback_string[current_line][1] = sample[1];
    playback_string[current_line][2] = sample[2];
  #endif
  
  if (samples == 1)
  {
    Serial.println(sample[0],HEX);
    if (_SAMPLE_PAUSE_ > 0)
      delayMicroseconds(_SAMPLE_PAUSE_);
    return;
  }

  if (samples == 2)
  {
    Serial.print(sample[0],HEX);
    Serial.print(",");
    Serial.println(sample[1],HEX); // Complete line
    if (_SAMPLE_PAUSE_ > 0)
      delayMicroseconds(_SAMPLE_PAUSE_);
    return;
  }
  else if (samples == 3)
  {
    Serial.print(sample[0],HEX);
    Serial.print(",");
    Serial.print(sample[1],HEX);
    Serial.print(",");
    Serial.println(sample[2],HEX); // Complete line
    if (_SAMPLE_PAUSE_ > 0)
      delayMicroseconds(_SAMPLE_PAUSE_);
    return;
  }

  return;
}

// Usage see print_hex
void print_dec(int samples, unsigned long sample [])
{
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
  
  #if (_LOGGING_ == 1)
    current_line++;
    playback_string[current_line][0] = sample[0];
    playback_string[current_line][1] = sample[1];
  #endif

  if (samples == 1)
  {
    Serial.println(sample[0],DEC);
    if (_SAMPLE_PAUSE_ > 0)
      delayMicroseconds(_SAMPLE_PAUSE_);
    return;
  }

  if (samples == 2)
  {
    Serial.print(sample[0],DEC);
    Serial.print(",");
    Serial.println(sample[1],DEC); // Complete line
    if (_SAMPLE_PAUSE_ > 0)
      delayMicroseconds(_SAMPLE_PAUSE_);
    return;
  }

  return;
}

void uptime()
{
  long days, hours, mins;
  long currentuptime = ((millis() - startup) /1000);

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

void optical_timeout()
{
  float optical_timeout;
  
  Serial.print(" (timeout: ");
  
  if (_OPTICAL_TIMEOUT_ >= 1000000)
  {
    optical_timeout = (_OPTICAL_TIMEOUT_ / 1000 / 1000);
    Serial.print( optical_timeout );
    Serial.print("s), ");
  }
  else if (_OPTICAL_TIMEOUT_ >= 1000)
  {
    optical_timeout = (_OPTICAL_TIMEOUT_ / 1000);
    Serial.print( optical_timeout );
    Serial.print("ms), ");
  }
  else
  {
    Serial.print( _OPTICAL_TIMEOUT_ );
    Serial.print("μs), ");
  }
  
  return;
}
  
void LED_blink()
{
  // if the LED is off turn it on and vice-versa:
  if (ledState == LOW)
    ledState = HIGH;
  else
    ledState = LOW;

  // set the LED with the ledState of the variable: // Let's blink while we are waiting for data
  digitalWrite(_LED_PIN_, ledState);
  return;
}

void LED_switch(int state)
{
  ledState = state;

  // set the LED with the ledState of the variable: // Let's blink while we are waiting for data
  digitalWrite(_LED_PIN_, ledState);
  return;
}
  
