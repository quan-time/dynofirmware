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
  _OPTICAL_TIMEOUT_       1000000 [1 second]         (Maximum ammount of time in microseconds that the firmware will wait for a reply from the optical sensor, Arduino default is 1s, we could make it 100ms since the slowest sample we can send is 65.535ms)
  _SERIAL_BUFFER_         8                          (Ammount of bytes that should be pre-allocated to read the serial connection's buffer with, I've determined 8 is plenty "S065535," is the longest string I've seen the frontend generate)
  _FILTER_SLOW_SAMPLES_   0       [0 = OFF, 1 = ON]  (How we handle optical sensor values that are greater than _MAXIMUM_MICROSECOND_, 1 turns this on by filtering them so they don't appear in WOTID, 0 turns this off and just sends the value as 65535 instead)
  _END_RUN_               1                          (How many deceleration samples in a row are required to call it a day and issue the end of the run with "T")
  _CLOCK_FREQUENCY_       1                          (Has a huge affect on minimum starting speed. Measured in MHz, WOTID uses this value to divide every optical sensor value by, by setting a value that isn't 1 we override this behaviour and let the firmware do the math instead. 2 = 0.5, 1 = 1, 0.5 = 2, 0.225 = 4 etc.)
  _MAXIMUM_MICROSECOND_   65535   [65.535ms]         (WOTID only accepts hexadecimal values up to FFFF, which is 65535, related to minimum starting value, if _CLOCK_FREQUENCY_ changes from 1, we might need to automatically adjust our max to suit)
  _MAKERUN_TIMEOUT_       10000   [10 seconds]       (How long in milliseconds till the backend will timeout waiting for a valid sample from the optical sample when "Start Now" is hit in the Make Run menu)
  _VERSION_STRING_        "Blah"                     (The version string that will be seen when the About button is used in WOTID)
  _LED_PIN_               6                          (Pin the builtin Teensy LED is on, 6 on Teensy++ 2.0, 11 on Teensy 2.0)

*/
#define _LOGGING_ 0
#define _SIMULATE_DRUM_ 0
#define _COM_BAUD_ 19200
#define _DEBUG_ 0
#define _EXTERNAL_RPM_SENSOR_ 0
#define _PIN_ 0
#define _DRUM_HILO_ 0
#define _IGNORE_STARTVALUE_ 1
#define _STARTCOUNT_BUFFER_ 5
#define _OPTICAL_TIMEOUT_ 1000000
#define _SERIAL_BUFFER_ 8
#define _FILTER_SLOW_SAMPLES_ 1
#define _END_RUN_ 4
#define _CLOCK_FREQUENCY_ 1
#define _MAXIMUM_MICROSECOND_ 65535
#define _MAKERUN_TIMEOUT_ 10000
//#define _MAXIMUM_MICROSECOND_ (int)(65535 / _CLOCK_FREQUENCY_) // not used
#define _VERSION_STRING_ "Quan-Time WOTID firmware. Version 0.3"
#define _LED_PIN_ 6
#define _PULSE_TYPE_ LOW // easier to interrupt the photosensor using a drill if the gate is open all the time waiting for HIGH to interrupt, versus using HIGH which waits until the gate is clear to measure interruptions (LOW)
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
/* End */

/* Teensy CPU Speed Control: http://www.pjrc.com/teensy/prescaler.html */
#define CPU_PRESCALE(n) (CLKPR = 0x80, CLKPR = (n))
#define CPU_16MHz       0x00
#define CPU_8MHz        0x01
#define CPU_4MHz        0x02
#define CPU_2MHz        0x03
#define CPU_1MHz        0x04
#define CPU_500kHz      0x05
#define CPU_250kHz      0x06
#define CPU_125kHz      0x07
#define CPU_62kHz       0x08
/* End Teensy CPU Frequency Overrride */

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

int ledState = LOW;

// When Teensy is started or rebooted, this is the first function that is ran.
void setup()
{
  //CPU_PRESCALE(CPU_16MHz); // Can be used to change the clock speed of the CPU, in this instance would set the speed during the device's startup.

  Serial.begin(_COM_BAUD_);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(_PIN_, INPUT); // Pin 0 should be connected to the optical sensor
  pinMode(_LED_PIN_, OUTPUT); // initialize LED
  
  #if (_LOGGING_ == 1)
    pinMode(_PLAYBACK_PIN_, INPUT); // Pin 5 to playback current data
  #endif
  
  startup = millis(); // how many milliseconds have passed since the unix epoch (start from jan 1st 1970), we use this to mark when the Teensy unit was rebooted/started
}

void loop()
{
  Drum_Only(0, millis());
  return;
}

void Drum_Only(int end_run_counter, unsigned long startrun){
  unsigned long sample[3];
  unsigned long elasped_time = (millis() - startrun);
  int optical_state = 0;
  
  if (ledState == HIGH) // turn off LED before 1st tooth sample
    LED_switch(LOW);
    
  if (end_run_counter >= _END_RUN_) // confirmed, so and so ammount of samples in a row are indicating decelleration of the drum, so lets end the run
  {
    Ending_Run();
    return;
  }
  if (elasped_time >= _MAKERUN_TIMEOUT_)
  {
    Serial.println("0,0,0"); // lets clear the frontend
    Ending_Run();
    return;  
  }
  
  /*optical_state = digitalRead(_PIN_);
  if (optical_state == LOW)
    Serial.println("BEFORE T1: Optical gate is blocked (LOW)");
  else if (optical_state == HIGH)
    Serial.println("BEFORE T1: Optical gate is clear (HIGH)");
  
  if (digitalRead(_PIN_) == LOW)
    pulseIn(_DRUM_HILO_, LOW); // 1 microsecond timeout, we clear this state so we can read the HIGH value again*/

  sample[0] = pulseIn(_DRUM_HILO_, _PULSE_TYPE_, _OPTICAL_TIMEOUT_);

  /*optical_state = digitalRead(_PIN_);
  if (optical_state == LOW)
    Serial.println("AFTER T1: Optical gate is blocked (LOW)");
  else if (optical_state == HIGH)
    Serial.println("AFTER T1: Optical gate is clear (HIGH)");*/

  LED_switch(HIGH); // turn LED on
  /*
  //It seems like pulseIn(pin,LOW) if it is ALREADY low will wait until it gets high and THEN low again before it measures the time it takes for it to get high after that.
  if (digitalRead(_PIN_) == LOW)
    pulseIn(_DRUM_HILO_, LOW); // 1 microsecond timeout*/
  
  sample[1] = pulseIn(_DRUM_HILO_, _PULSE_TYPE_, _OPTICAL_TIMEOUT_);
  /*optical_state = digitalRead(_PIN_);
  if (optical_state == LOW)
    Serial.println("After T2: Optical gate is blocked (LOW)");
  else if (optical_state == HIGH)
    Serial.println("After T2: Optical gate is clear (HIGH)");*/

  LED_switch(LOW); // switch it off again
  sample[2] = 0;
  
  if ((sample[0] < sample[1])) // || ((sample[0] == 0) && (sample[1] == 0))) // if tooth 1 is less than tooth 2 OR tooth1 and tooth2 both are 0
    end_run_counter++; // let's increment our counter by 1
  else if (sample[0] > sample[1])
    end_run_counter = 0; // speeding up, so lets reset back to 0 (if it isn't already)
  
  Serial.println(elasped_time);

  if (!(sample[0] == 0) && !(sample[1] == 0)) // dont print 0,0,0
    print_hex(3,sample);

  if ((sample[0] == 0) || (sample[1] == 0))
  {
    Drum_Only(end_run_counter,startrun);
    return;
  }
  else
  {
    Drum_Only(end_run_counter,millis());
    return;
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
  
  //if ( (sample[0] == 0) && (sample[1] == 0) ) // if either is 0, let's not print this
    //return;
  
  #if (_DEBUG_ == 1)
    Serial.print("Ammount of samples: ");
    Serial.print(samples);
    Serial.print(" sample1: ");
    Serial.print(sample[0]);
    Serial.print(" sample2: ");
    Serial.print(sample[1]);
    Serial.print(" sample3: ");
    Serial.print(sample[2]);
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

// Perhaps we could use this function later to free memory we've used so far
void Ending_Run() {
  Serial.println("T");
  LED_switch(LOW); // switch LED off incase it is on
  return;
}
