int RPM_HiLo = 0; // listed as 1 in the PBasic source
int Drum_HiLo = 0; // listed as 1 in the PBasic source
int DrumIn = 0; // listed as 0 in the PBasic source
int pin = 0;
/*
  human_readable:
  0 = WOTID frontend (HEX) = 510E,4EEE,0
  1 = Human readable (DEC) = Tooth ON: 20750ms   Tooth OFF: 20194ms   Difference: +556ms
*/
int human_readable = 1;

void setup() // main function set
{
  Serial.begin(19200);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(pin, INPUT); // Pin 0 should be connected to the optical sensor
}

void loop()
{
  unsigned int sample[3];
  unsigned long timeout = 1000000; // default is 1 second, this value is microseconds
  
  sample[0] = pulseIn(Drum_HiLo, HIGH, timeout); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(Drum_HiLo, LOW, timeout); // measure how long the tooth is off for
  sample[2] = 0;
 
  if (sample[0] == 0)
  {
    Serial.println("Received nothing (HIGH) from Drum, timed out");
    delay(1000); // wait 1 seconds before we try again?
  }
  else if (sample[1] == 0)
  {
    Serial.println("Received nothing (LOW) from Drum, timed out");
    delay(1000); // wait 1 seconds before we try again?
  }
  else
  {
    if (human_readable == 1)
    {
      Serial.print("Tooth ON: ");
      Serial.print(sample[0]);
      Serial.print("ms   Tooth OFF: ");
      Serial.print(sample[1]);
      Serial.print("ms   Difference: ");
      
      if (sample[0] > sample[1])
      {
        Serial.print("+");
        Serial.print( (sample[0]-sample[1]) );
        Serial.println("ms");
      }
      if (sample[0] < sample[1])
      {
        Serial.print("-");
        Serial.print( (sample[1]-sample[0]) );
        Serial.println("ms");
      }
      else
      {
        Serial.println("0ms");
      }      
    }
    else
    {
      print_wotid(3, sample);
    }
  }      
}

// Usage, if there are 2 samples, then you would do "print_hex(2,sample1, sample2, 0);" or if you had 3 samples then "print_hex(3,sample1, sample2, sample3);" or only 1 sample then "print_hex(1,sample1, 0, 0);"
void print_wotid(int samples, unsigned int sample [])
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


/*void Drum_Only(){
  int sample[3];
  
  sample[0] = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
  sample[1] = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for
  sample[2] = 0;

  print_hex(3,sample);
    
  if (sample[0] < sample[1])
  {
    Ending_Run();
    if (allow_recursion == 1)
      return;
  }
  else
  {
    Drum_Only();
    if (allow_recursion == 1)
      return;
  }
  
  if (allow_recursion == 1)
    return;
}*/
