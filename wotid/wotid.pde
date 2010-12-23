int byte1 = 0; // for incoming serial data
int byte2 = 0;
int byte3 = 0;
int byte4 = 0;
int pin = 0;
unsigned long duration;
int RPM_HiLo = 0;
int Drum_HiLo = 0;
int DrumIn = 0;
int StartValue = 0;
int sample1 = 0;
int sample2 = 0;

void setup() // main function set
{
  Serial.begin(19200);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(pin, INPUT); // Pin 0 should be connected to the optical sensor
}

void loop() {        
  // read the incoming byte:
  if (Serial.available() == 4) {
    int byte1 = Serial.read(); 
    int byte2 = Serial.read(); 
    int byte3 = Serial.read();
    int byte4 = Serial.read();

    switch (byte1) {
    case 'A':
      About();
      break;
    case 'S':
      Calc_Start();
      break;        
    case 'G':
      Gear_Ratio();
      break;        
    case 'T':
      Test();
      break;        
    case 'R':
      Run_Down();
      break;
    default:
      StartValue = 000;
      byte1 = 0;
      break;
    }
  }       
}
void About() {
  Serial.println("Quan-Time WOTID firmware");
  Serial.println("Version 0.01a - Yes, its that bad");
}


void Calc_Start() {
  {
    if (byte2 == 0);
    (StartValue == 0);
    Drum_Only();

    if (byte2 != 0);
    (StartValue == 0);
    Drum_RPM();
  }
  if (StartValue > 0);
  Auto_Start();
}   


void Gear_Ratio() {
  for(int x = 0; x < 10; x++) // loop this function set 10x, thats what the frontend wants
  {
    sample1 = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
    sample2 = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for
    Serial.print(sample1);
    Serial.print(",");  //  Should print out "yyy,xxx" on 10 individual lines.
    Serial.println(sample2);
  }
  Ending_Run();
}

void Test() {
  for(int x = 0; x < 15; x++) // loop this function set 15x, thats what the frontend wants
  {
    sample1 = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
    Serial.print(sample1);
  }
  Ending_Run();
}

void Auto_Start(){
  if (sample1 == 0)
  {
    Auto_Start();
  }
  else if (sample1 < byte4 && byte2 == 0)
  {
    Drum_Only();
  }
  else (sample1 < StartValue && byte2 != 0);
  {
    Drum_RPM();
  }
}

void Run_Down() {
}

void Ending_Run() {
  Serial.println("T");
}

void Drum_Only(){
}

void Drum_RPM(){
}

