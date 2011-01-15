int RPM_HiLo = 0; // listed as 1 in the PBasic source
int Drum_HiLo = 0; // listed as 1 in the PBasic source
int DrumIn = 0; // listed as 0 in the PBasic source
int pin = 0;
/*
  human_readable:
  0 = WOTID frontend (HEX) = 510E,4EEE,0
  1 = Human readable (DEC) = RPM: 110   KM/H: 9.4   Tooth ON: 20750ms   Tooth OFF: 20194ms   Difference: +556ms
  2 = WOTID frontend (DEC) = 65535,65500,0
*/
int human_readable = 1;
int count_deceleration = 0; // we increment this number each time we detect the drum is slowing down
unsigned long timeout = 10000000; // default is 1 second, this value is microseconds, i've set this for 10 seconds
int ledState = LOW;

// How many deceleration samples in a row are required to effectively "End the run"
#define _END_RUN_ 5
// How many pulses per revolution
#define _PULSES_PER_REV_ 4
// Circumfereance in mm
#define _CIRCUMFERENCE_ 1426.283
// Pin for LED
#define _LED_PIN_ 6

#define _TOOTH_1_ HIGH
#define _TOOTH_2_ HIGH

// Wait until there is a LOW state (gate is blocked/interrupted) before we get a reading from the HIGH state (gate open).. if we initiate a HIGH state with the sensor starting halfway through the open gate (HIGH), we might not get the data we actually want
#define _WAIT_FOR_LOW_ 0


void setup() // main function set
{
  Serial.begin(19200);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(pin, INPUT); // Pin 0 should be connected to the optical sensor
  pinMode(_LED_PIN_, OUTPUT); // initialize LED
}

void loop()
{
  unsigned long sample[3];
  
  #if (_WAIT_FOR_LOW_ == 1)
    while ( digitalRead(pin) == HIGH ) // loop until pin 0 reachs a LOW state
    {
    }
    sample[0] = pulseIn(Drum_HiLo, _TOOTH_1_, timeout); // 1st tooth
  #else
    sample[0] = pulseIn(Drum_HiLo, _TOOTH_1_, timeout); // 1st tooth
  #endif

  if (sample[0] > 0)
    to_blink_or_not_to_blink(HIGH); // on

  #if (_WAIT_FOR_LOW_ == 1)
    while ( digitalRead(pin) == HIGH ) // loop until pin 0 reachs a LOW state
    {
    }
    sample[1] = pulseIn(Drum_HiLo, _TOOTH_2_, timeout); // 1st tooth
  #else
    sample[1] = pulseIn(Drum_HiLo, _TOOTH_2_, timeout); // 1st tooth
  #endif

  if (sample[1] > 0)
    to_blink_or_not_to_blink(LOW); // off

  sample[2] = 0;

 if (count_deceleration >= _END_RUN_) // 5 deceleration samples in a row!
  {
    if (human_readable == 1)
      Serial.println("CONFIRMED: Drum slowing down, would end the run now with 'T'");
    else
      Serial.println("T");
    
    count_deceleration = 0; // let's reset back to 0 so we can do it all over again
    delay(100); // wait 1 seconds before we try again?
    return;
  }    
  if (sample[0] == 0)
  {
    Serial.print("Received nothing (Tooth #1) from Drum, timed out (seconds): ");
    Serial.println(timeout / 1000 / 1000);
    //delay(1000); // wait 1 seconds before we try again?
    to_blink_or_not_to_blink(LOW);
    return;
  }
  else if (sample[1] == 0)
  {
    Serial.print("Received nothing (Tooth #2) from Drum, timed out (seconds): ");
    Serial.println(timeout / 1000 / 1000);
    //delay(1000); // wait 1 seconds before we try again?
    to_blink_or_not_to_blink(LOW);
    return;
  }
  else
  {
    if (human_readable == 1)
    {
      rotation_status(sample);    
      
      Serial.println("");
    }
    else if (human_readable == 2)
      print_wotid_dec(3, sample);
    else if (human_readable == 0)
      print_wotid(3, sample);
  }      
}

void to_blink_or_not_to_blink(int state)
{
  ledState = state;

  // if the LED is off turn it on and vice-versa:
  //if (ledState == LOW)
    //ledState = HIGH;
  //else
    //ledState = LOW;
  
  // set the LED with the ledState of the variable:
  digitalWrite(_LED_PIN_, ledState);
  return;
}

void calculate_difference(unsigned long sample[])
{
  float difference;
  
  if (sample[0] > sample[1])
  {
    difference = (sample[0]-sample[1]);

    count_deceleration = 0; // reset back to 0
    Serial.print("+");
    
    if (difference >= 1000000)
    {
      Serial.print( (difference / 1000 / 1000) );
      Serial.print("secs");
    }
    else if (difference >= 1000)
    {
      Serial.print( (difference / 1000) );
      Serial.print("ms");
    }
    else
    {
      Serial.print(difference);  
      Serial.print("us");
    }     
 
    Serial.print(" (Drum Speeding UP)");
  }
  else if (sample[0] < sample[1])
  {
    difference = (sample[1]-sample[0]);
    
    count_deceleration++; // increment by 1
    Serial.print("-");

    if (difference >= 1000000)
    {
      Serial.print( (difference / 1000 / 1000) );
      Serial.print("secs");
    }
    else if (difference >= 1000)
    {
      Serial.print( (difference / 1000) );
      Serial.print("ms");
    }
    else
    {
      Serial.print(difference);  
      Serial.print("us");
    }      
    
    Serial.print(" (Drum Slowing DOWN)");
  }
  else
  {
    Serial.print( (sample[0]-sample[1]) );
    Serial.print("us (Drum Holding Constant Speed)");
  }
} 

void calculate_rpm(unsigned long sample[])
{
  float rpm;
  float revs_per_km = 1000000 / _CIRCUMFERENCE_; // 1million millimeters divided by drum circumferance, this formula is 701.2622720897616 rotations to go 1 kilometer
  float kmh;  

  if (sample[0] > sample[1])
  {
/*
  float rpm:
  
  HIGH divided by 1000 (we convert microseconds to milliseconds by dividing by 1000)
  Then times the above result by 8 (since HIGH is just one tooth sample, and 8 teeth is a full revolution)..
  Finally we do 60000 (milliseconds) divided by the result above ((HIGH / 1000) * 8) which gives us rpm
*/
    rpm = (float)(60000. / ((sample[0] / 1000.) * _PULSES_PER_REV_));
/*
  float kmh:
  
  rpm times by 60 (we convert rpm to rph [revs per hour])
  The above result divided by revs_per_km (which is about 701.26) gives us km/h
*/
    kmh = ((rpm * 60) / revs_per_km);  
  }
  else if (sample[0] < sample[1])
  {
    rpm = (float)(60000. / ((sample[0] / 1000.) * _PULSES_PER_REV_));
    kmh = ((rpm * 60) / revs_per_km);
  }
  else
  {
    rpm = (float)(60000. / ((sample[0] / 1000.) * _PULSES_PER_REV_));
    kmh = ((rpm * 60) / revs_per_km);
  }

  Serial.print("RPM: ");
  Serial.print(rpm);
  Serial.print("   KM/H: ");
  Serial.print(kmh);
  return;
}

void rotation_status(unsigned long sample[])
{
  calculate_rpm(sample);

  Serial.print("   Tooth 1: ");
      
  if (sample[0] >= 1000000)
  {
    Serial.print( (float)(sample[0] / 1000. / 1000.) );
    Serial.print("secs");
  }
  else if (sample[0] >= 1000)
  {
    Serial.print( (float)(sample[0] / 1000.) );
    Serial.print("ms");
  }
  else
  {
    Serial.print(sample[0]);  
    Serial.print("us");
  }
  
  Serial.print("   Tooth 2: ");
      
  if (sample[1] >= 1000000)
  {
    Serial.print( (float)(sample[1] / 1000. / 1000.) );
    Serial.print("secs");
  }
  else if (sample[0] >= 1000)
  {
    Serial.print( (float)(sample[1] / 1000.) );
    Serial.print("ms");
  }
  else
  {
    Serial.print(sample[1]);  
    Serial.print("us");
  }
  
  Serial.print("   Difference: ");
     
  calculate_difference(sample);
}

// Usage, if there are 2 samples, then you would do "print_hex(2,sample1, sample2, 0);" or if you had 3 samples then "print_hex(3,sample1, sample2, sample3);" or only 1 sample then "print_hex(1,sample1, 0, 0);"
void print_wotid(int samples, unsigned long sample [])
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
  
  return;
}

// Usage, if there are 2 samples, then you would do "print_hex(2,sample1, sample2, 0);" or if you had 3 samples then "print_hex(3,sample1, sample2, sample3);" or only 1 sample then "print_hex(1,sample1, 0, 0);"
void print_wotid_dec(int samples, unsigned long sample [])
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
  
  return;
}
