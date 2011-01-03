int RPM_HiLo = 0; // listed as 1 in the PBasic source
int Drum_HiLo = 0; // listed as 1 in the PBasic source
int DrumIn = 0; // listed as 0 in the PBasic source
int pin = 0;
/*
  human_readable:
  0 = WOTID frontend (HEX) = 510E,4EEE,0
  1 = Human readable (DEC) = RPM: 110   KM/H: 9.4   Tooth ON: 20750ms   Tooth OFF: 20194ms   Difference: +556ms
*/
int human_readable = 1;
int count_deceleration = 0; // we increment this number each time we detect the drum is slowing down

// How many deceleration samples in a row are required to effectively "End the run"
#define _END_RUN_ 5

void setup() // main function set
{
  Serial.begin(19200);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(pin, INPUT); // Pin 0 should be connected to the optical sensor
}

void loop()
{
  long sample[3];
  unsigned long timeout = 1000000; // default is 1 second, this value is microseconds
  
  sample[0] = pulseIn(Drum_HiLo, HIGH, timeout); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(Drum_HiLo, LOW, timeout); // measure how long the tooth is off for
  sample[2] = 0;
 
  if (count_deceleration >= _END_RUN_) // 5 deceleration samples in a row!
  {
    if (human_readable == 1)
      Serial.println("CONFIRMED: Drum slowing down, would end the run now with 'T'\n");
    else
      Serial.println("T");
    
    count_deceleration = 0; // let's reset back to 0 so we can do it all over again
    delay(3000); // wait 1 seconds before we try again?
    return;
  }    
  if (sample[0] == 0)
  {
    Serial.println("Received nothing (HIGH) from Drum, timed out");
    delay(1000); // wait 1 seconds before we try again?
    return;
  }
  else if (sample[1] == 0)
  {
    Serial.println("Received nothing (LOW) from Drum, timed out");
    delay(1000); // wait 1 seconds before we try again?
    return;
  }
  else
  {
    if (human_readable == 1)
    {
      calculate_rpm(sample);
      
      Serial.print("   Tooth ON: ");     
      Serial.print(sample[0]);
      Serial.print("μs   Tooth OFF: ");
      Serial.print(sample[1]);
      Serial.print("μs   Difference: ");
     
      calculate_difference(sample);     
      
      Serial.println("");
    }
    else
    {
      print_wotid(3, sample);
    }
  }      
}

void calculate_difference(long sample[])
{
  if (sample[0] > sample[1])
  {
    count_deceleration = 0; // reset back to 0
    Serial.print("+");
    Serial.print( (sample[0]-sample[1]) );
    Serial.print("μs (Drum Speeding UP)");
  }
  if (sample[0] < sample[1])
  {
    count_deceleration++; // increment by 1
    Serial.print("-");
    Serial.print( (sample[1]-sample[0]) );
    Serial.print("μs (Drum Slowing DOWN)");
  }
  else
  {
    Serial.print("NONE");
  }
} 

void calculate_rpm(long sample[])
{
  float rpm;
  float revs_per_km = 1000000. / 1426.283; // 1million millimeters divided by drum circumferance, this formula is 701.2622720897616 rotations to go 1 kilometer
  float kmh;  

  if (sample[0] > sample[1])
  {
/*
  float rpm:
  
  HIGH divided by 1000 (we convert microseconds to milliseconds by dividing by 1000)
  Then times the above result by 8 (since HIGH is just one tooth sample, and 8 teeth is a full revolution)..
  Finally we do 60000 (milliseconds) divided by the result above ((HIGH / 1000) * 8) which gives us rpm
*/
    rpm = (60000. / ((sample[0] / 1000.)  * 8.));
/*
  float kmh:
  
  rpm times by 60 (we convert rpm to rph [revs per hour])
  The above result divided by revs_per_km (which is about 701.26) gives us km/h
*/
    kmh = ((rpm * 60.) / revs_per_km);  
  }
  else if (sample[0] < sample[1])
  {
    rpm = (60000. / ((sample[1] / 1000.) * 8.));
    kmh = ((rpm * 60.) / revs_per_km);
  }
  else
  {
    rpm = (60000 / ((sample[0] / 1000.) * 8.));
    kmh = ((rpm * 60.) / revs_per_km);
  }

  Serial.print("RPM: ");
  Serial.print(rpm,2);
  Serial.print("   KM/H: ");
  Serial.print(kmh,2);
  return;
}

// Usage, if there are 2 samples, then you would do "print_hex(2,sample1, sample2, 0);" or if you had 3 samples then "print_hex(3,sample1, sample2, sample3);" or only 1 sample then "print_hex(1,sample1, 0, 0);"
void print_wotid(int samples, long sample [])
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
