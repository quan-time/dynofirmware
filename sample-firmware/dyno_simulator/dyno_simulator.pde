void setup() // main function set
{
  Serial.begin(19200);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  //pinMode(0, INPUT); // Pin 0 should be connected to the optical sensor
}

void loop() {        
  //int readbyte[4]; // for incoming serial data
  int readbyte[10]; // room for 10 bytes of data
  char readchar[2];
  // 4 bytes + 1 byte for padding
  // [0] = 1, [1] = 2, [2] = 3, [3] = 4 etc.
  int available_bytes = 0;
  int i = 0;
  char singlebyte[2];
  
  available_bytes = Serial.available();

  // read the incoming byte string, one byte at a time, and assign each readbyte[1] - readbyte[4] respectively.
  if (available_bytes > 0) { // If there are no bytes available, skip this code block
    readbyte[0] = Serial.read();   //  let's start reading 1 byte at a time
    
   //sprintf( singlebyte, "%s", readbyte[0] ); // save the incoming byte as a single character string
   
    if ( (readbyte[0] == 'A') || (readbyte[0] == 'a') )
    {
      Serial.println("Dynorun Simulator");
      Serial.println("v1.0");
    }
    else if ( (readbyte[0] == 'S') || (readbyte[0] == 's') )
    {
      simulate_dynorun();
    }
  }  
  
  Serial.flush();
}

void simulate_dynorun()
{
  int highest1 = 20750; // 510E.. 510E,xxxx,x
  int highest2 = 20194; // 4EE2.. xxxx,4EE2,x
  int lowest1 = 5197; // 144D.. 144D,xxxx,x
  int lowest2 = 5206; // 1456.. xxxx,1456,x
  int samples = 30; // how many lines to send to the front end
  int i = 0;
  int delay_timer = 250; // specify delay in milliseconds to messages sent to the front end

  int difference1 = ((highest1 - lowest1) / samples);
  int difference2 = ((highest2 - lowest2) / samples);

  while (i < samples)
  {
	highest1 = (highest1 - difference1);
	highest2 = (highest2 - difference2);

	Serial.print(highest1,HEX); // change this to DEC if no good
        Serial.print(",");
        Serial.print(highest2,HEX); // change this to DEC if no good
        Serial.println(",0");

        delay(delay_timer);
	i++;
  }

  Serial.println("T");
  
  //Serial.end();
}
