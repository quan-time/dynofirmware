int com_baud = 19200;
int epoch_time = millis();

void setup()
{
  Serial.begin(com_baud);
}

void loop()
{
  int available_bytes = 0;
  int buffer = 10;
  int readbyte[buffer];
  int i = 0;
  int arrayposition = 0;
  
  //
  int startcount_buffer = 5;
  int startcount_input[5] = { 0, 0, 0, 0, 0 }; // maybe default to 65535
  long int startcount = 0;
  int startcount_i = 0;

  available_bytes = Serial.available();
  
  if (available_bytes > 0)
  {
       
    Serial.print("Serial packet: ");
    Serial.print(available_bytes);
    Serial.print(" bytes (");
    Serial.print((millis() - epoch_time));
    Serial.println(" milliseconds ago)");
    epoch_time = millis();
    
    while (i < available_bytes)
    {
      readbyte[i] = Serial.read();
      
      Serial.print("Byte "); 
      Serial.print((i+1));
      Serial.print(" received: ");
      Serial.println(readbyte[i],BYTE);
      
      if (readbyte[i] == ',')
      {
        Serial.println("Carriage return detected");
        break;
        break;
        break;
      }
     
      i++; 
    }
    
    if ( (readbyte[0] == 'S') && ( (readbyte[1] == '0') || (readbyte[1] == '1') || (readbyte[1] == '2') ) ) // if string is S0, S1 or S2
    {
      while (startcount_i < 5) // lets not wait for the 6th byte "," or space whatever it is
      {
        //delay(1);
        available_bytes = Serial.available();
        if (available_bytes > 0)
        {
          Serial.print("Bytes avail: ");
          Serial.print(available_bytes);
          startcount_input[startcount_i] = Serial.read();
          Serial.print(" char: ");
          Serial.println(startcount_input[startcount_i],BYTE);
          startcount = (startcount*10 + (startcount_input[startcount_i] - 48)); // we take 48 away because 49 is the ASCII code for 1, so 50 - 49 = 1.. if startcount_input were 2, then it would be the ASCII code 50, take 48 and we have the number 2
          Serial.println(startcount);
          startcount_i++;
        }
      }
      Serial.print("startcount: ");
      Serial.print(startcount,DEC);
      Serial.println("ms");
     
      com_debug();
    }
  }
  
  delay(1);
  //delayMicroseconds(1000);
}

void com_debug()
{
  Serial.print("Com Baud: ");
  Serial.println(Serial.baud());
  Serial.print("Stop bits: ");
  Serial.println(Serial.stopbits());
  Serial.print("Parity type: ");
  Serial.println(Serial.paritytype());
  Serial.print("Num bits: ");
  Serial.println(Serial.numbits());
  Serial.print("RTS Signal State: ");
  Serial.println(Serial.rts());
  Serial.print("DTR Signal State: ");
  Serial.println(Serial.dtr());
}
