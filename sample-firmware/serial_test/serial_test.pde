int com_baud = 19200;
int epoch_time = millis();

void setup()
{
  Serial.begin(com_baud);
  
  //com_baud = Serial.baud();
  
  //Serial.print("Com Baud: ");
  //Serial.println(Serial.baud());
  //Serial.print("Stop bits: ");
  //Serial.println(Serial.stopbits());
  //Serial.print("Parity type: ");
  //Serial.println(Serial.paritytype());
  //Serial.print("Num bits: ");
  //Serial.println(Serial.numbits());
  //Serial.print("RTS Signal State: ");
  //Serial.println(Serial.rts());
  //Serial.print("DTR Signal State: ");
  //Serial.println(Serial.dtr());
}

void loop()
{
  int available_bytes = 0;
  int buffer = 10;
  int readbyte[buffer];
  int i = 0;
  int arrayposition = 0;

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
  }
  
  delay(1);
  //delayMicroseconds(1000);
}
