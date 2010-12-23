int incomingByte = 0;        // for incoming serial data
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
            sample1 = 0;  // Reset the sample time back to zero
            sample1 = pulseIn(Drum_HiLo, HIGH); // measure how long the tooth is on for, store it in "sample1"
            sample2 = 0; // Reset sample2 back to zero
            sample2 = pulseIn(Drum_HiLo, LOW); // measure how long the tooth is off for
            Serial.print(sample1);
            Serial.print(",");  //  Should print out "yyy,xxx" on 10 individual lines.
            Serial.println(sample2);
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

