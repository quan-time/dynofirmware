int incomingByte = 0;	// for incoming serial data
int StartValue = 0;
void setup() // main function set
{
	Serial.begin(19200);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed
	attachInterrupt(0, drumrpm, RISING);
}

void loop() {	
	// read the incoming byte:
	incomingByte = Serial.read();
	switch(incommingByte) {
	case "A":
		About();
		break;
	case "S":
		Calc_Start();
		break;	
	case "G":
		Gear_Ratio();
		break;	
	case "T":
		Test();
		break;	
	case "R":
		Run_Down();
		break;
	default:
                StartValue = 000;
                incommingByte = 0;
                loop();
		break;
	}
}       

void About() {
	serial.println("Quan-Time WOTID firmware");
	serial.println("Version 0.01a - Yes, its that bad");
	loop();
}


void Calc_Start() {
	time = micros();
	Serial.println(time, HEX);
	loop();
}

void Gear_Ratio() {
	for(int x = 0; x < 10; x++)
        {
          
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
	serial.println("T");
	loop();
}
