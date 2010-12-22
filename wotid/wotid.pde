int incomingByte = 0;        // for incoming serial data
int StartValue = 0;
int RPM_HiLo = 0;
int Drum_HiLo = 0;
int DrumIn = 0;

void setup() // main function set
{
        Serial.begin(19200);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
}

void loop() {        
        // read the incoming byte:
        if (Serial.available() > 0) {
          int incomingByte = Serial.read();
      
        switch (incomingByte) {
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
                incomingByte = 0;
                loop();
                break;
        }
}       
}
void About() {
        Serial.println("Quan-Time WOTID firmware");
        Serial.println("Version 0.01a - Yes, its that bad");
        loop();
}


void Calc_Start() {
        unsigned long time;
        time = micros();
        Serial.println(time, HEX);
        loop();
}

void Gear_Ratio() {
            for(int x = 0; x < 10; x++) // loop this function set 10x, thats what the frontend wants
            
            {
            if (digitalRead(Drum_HiLo) == HIGH)
            {
              int sample1 = 0;
                sample1 = micros(); // record the length in microsec that pin is HIGH
               Serial.print(sample1,',');
            }
            else
            {
              int sample2 = 0;
                sample2 = micros(); // record the length in microsec the pin is LOW
                Serial.print(sample2);
            }
      
        }
        Ending_Run();
}

void Test() {
        loop();
}

void Run_Down() {
        loop();
}

void Ending_Run() {
        Serial.println("T");
        loop();
}

