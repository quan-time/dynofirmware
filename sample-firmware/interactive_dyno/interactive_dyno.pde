#include "config.h"

void setup()
{
  //CPU_PRESCALE(CPU_500kHz); // Can be used to change the clock speed of the CPU, in this instance would set the speed during the device's startup.
  //#define _CPU_OVERRIDE_ "0.5mHz" // just for our sake, if we're not overriding the cpu speed just comment this line out

  Serial.begin(_COM_BAUD_);  // setup connection, teensy++ is pure USB anyway, so this isnt hugely important to specify speed       
  pinMode(_PIN_, INPUT); // Pin 0 should be connected to the optical sensor
  pinMode(_LED_PIN_, OUTPUT); // initialize LED
  
  ledState = LOW; // LED is default off
  
  #if (_LOGGING_ == 1)
    pinMode(_PLAYBACK_PIN_, INPUT); // Pin 5 to playback current data
  #endif
  
  startup = millis(); // how many milliseconds have passed since the unix epoch (start from jan 1st 1970), we use this to mark when the Teensy unit was rebooted/started

  main_menu();

}

void loop()
{
  int available_bytes = 0;
  int i = 0;
  int readbyte;
  int readbytebuffer[5];
  signed long sample[3];
  
  available_bytes = Serial.available();

  if (available_bytes > 0) 
  {     
    readbyte = Serial.read();
    
    //Serial.println(readbyte);
    
    if ( (readbyte == 'S') || (readbyte == 's') )
    {
      Serial.println("=================");
      Serial.println("Starting Dyno Run (infinite loop, restart the serial connection when finished)");
      Serial.println("=================");

      while (1 == 1)
      {
        available_bytes = Serial.available();

        if (available_bytes > 0) 
        {     
          readbyte = Serial.read();
          
          if ( (readbyte == 'Q') || (readbyte == 'q') )
          {
            main_menu();
            return;
          } 
        }

        sample[0] = pulseIn(_PIN_, _TOOTH_1_); // 1st tooth (quarter turn)
        sample[1] = pulseIn(_PIN_, _TOOTH_2_); // 2nd tooth (half turn)
        
        if ( !(sample[0] == 0) && !(sample[1] == 0) )
        {
          calculate_stuff(sample);
        }
      }
    }
    if ( (readbyte == 'R') || (readbyte == 'r') )
    {
      //About();
      Serial.println("=================");
      Serial.print("Calibrating Bike RPM, Hold RPM @ ");
      Serial.println(_RPM_CALIBRATION_);
      Serial.println("=================");
      
      _rpm_milliseconds_ = pulseIn(_PIN_, _TOOTH_1_);
      
      while (_rpm_milliseconds_ == 0)
      {
        available_bytes = Serial.available();

        if (available_bytes > 0) 
        {     
          readbyte = Serial.read();
          
          if ( (readbyte == 'Q') || (readbyte == 'q') )
          {
            main_menu();
            return;
          } 
        } 

        Serial.println("Waiting 1 second to try again");
        delay(1000);
        
        _rpm_milliseconds_ = pulseIn(_PIN_, _TOOTH_1_);
      }
      
      Serial.print("SUCCESS: ");
      Serial.print( _rpm_milliseconds_ );
      Serial.print(" milliseconds = ");
      Serial.println(_RPM_CALIBRATION_);
      
      _gear_ratio_ = (float)(_rpm_milliseconds_ / _drum_quarter_turn_);
      
      main_menu();
      return;
    }  
    if ( (readbyte == 'Q') || (readbyte == 'q') )
    {
      main_menu();
      return;
    }
    if ( (readbyte == 'Z') || (readbyte == 'z') )
    {
      _php_output_ = 0;
      mybike();
      return;
    }
    if ( (readbyte == 'X') || (readbyte == 'x') )
    {
      _php_output_ = 1;
      mybike();
      return;
    }
    if ( (readbyte == 'C') || (readbyte == 'c') )
    {
      _php_output_ = 2;
      mybike();
      return;
    }   
    if ( (readbyte == 'V') || (readbyte == 'v') )
    {
      _php_output_ = 3;
      mybike();
      return;
    } 
    if ( (readbyte == 'Y') || (readbyte == 'y') )
    {
      _gear_ratio_ = 0;
      
      Serial.println("=================");
      Serial.println("Enter engine:drum ratio: (2 decimal points MAX!)");
      Serial.println("=================");

      available_bytes = Serial.available();
    
      while (available_bytes == 0)
      {
        available_bytes = Serial.available();  
      }

      if (available_bytes > 0) 
      {
        while (i < available_bytes) // for every byte available, readbyte[0] holds the first byte, readbyte[1] holds the second byte etc
        {
          readbytebuffer[i] = Serial.read();
          
          if (i == 0)
            _gear_ratio_ = (readbytebuffer[i] - 48);
          else if (i == 2)
            _gear_ratio_ = (float)( _gear_ratio_ + ((readbytebuffer[i] - 48) / 10.));
          else if (i == 3)
            _gear_ratio_ = (float)( _gear_ratio_ + ((readbytebuffer[i] - 48) / 100.));
          else if (i == 4)
            break;
            
          i++; 
        }
     }
        
     Serial.println("Selected gear ratio: ");
     Serial.println(_gear_ratio_);
     
     main_menu();

     return;
    }
  }
}

void main_menu ()
{
  Serial.println("***************************************");
  Serial.println("Hello welcome to the interactive dyno!");
  Serial.print("Connected @ ");
  Serial.print(_COM_BAUD_);
  Serial.println(" baud");

  Serial.print("Drum Inertia: ");
  Serial.print(_MOI_);
  Serial.println(" kg/m2");
  Serial.print("Drum Circumference: ");
  Serial.print(_CIRCUMFERENCE_);
  Serial.println(" kg/m2");  
  
  Serial.println("Interactive Options:");
  Serial.println("- 'Q' to exit back to this menu");
  Serial.println("- 'S' to start dyno run");
  Serial.println("- 'Z' to start saved ZZR250 run");
  Serial.println("- 'X' for PHP output (sample[0] RPM)");
  Serial.println("- 'C' for PHP output (sample[1] RPM)");
  Serial.println("- 'V' for PHP output (inbetween RPM)");
  Serial.println("- 'T' to test dyno");
  Serial.print("- 'R' to Calibrate @ ");
  Serial.print(_RPM_CALIBRATION_);
  Serial.print(" RPM [currently: ");
  Serial.print(_rpm_milliseconds_);
  Serial.print(" milliseconds]");
  if (_rpm_milliseconds_ > 0)
  {
    Serial.print(" calculated engine:bike ratio: ");
    Serial.println( _gear_ratio_ );
  }
  else
    Serial.println("");
  
  Serial.print("- 'Y' to manually enter/override \"engine:rpm ratio\". Currently: ");
  Serial.println( _gear_ratio_ );
  Serial.println("***************************************");
  
  return;
}

void calculate_stuff(signed long sample[])
{
  float rpm;
  float drumrpm;
  float rps;
  float rads;
  float angular_velocity;
  float angular_acceleration;
  float torque;
  float power;
  float kilowatts;
  float horsepower;
  signed long adjustedsample;
  signed long difference;
  float ms_to_secs;
  
  if (sample[1] > sample[0])
  {
    difference = (sample[1] - sample[0]);
    adjustedsample = (sample[0] + (difference/2));
  }
  else
  {
    difference = (sample[0] - sample[1]); // so not a negative figure
    adjustedsample = (sample[1] + (difference/2));
  }
    
  ms_to_secs = (float)(difference * 10); // lets convert from milliseconds to seconds so we can match this to radians per second isntead of radians per milliseconds.. i dont know why 10 works here. seriously.

  if (_php_output_ < 2)
    rpm = (float)(60000. / ((sample[0] / 1000.) * _PULSES_PER_REV_)); //revs per minute, using sample[0] though reall we should use middleground between sample[0] and sample[1] for accuracy.
  else if (_php_output_ == 2)
    rpm = (float)(60000. / ((sample[1] / 1000.) * _PULSES_PER_REV_)); //revs per minute, using sample[0] though reall we should use middleground between sample[0] and sample[1] for accuracy.  
  else if (_php_output_ == 3)
    rpm = (float)(60000. / ((adjustedsample / 1000.) * _PULSES_PER_REV_)); //revs per minute, using sample[0] though reall we should use middleground between sample[0] and sample[1] for accuracy.
  
  rpm = (float)(rpm * 4.55); // 4.55 needs to be replaced with the engine:drum ratio, my bike is 4.5
  
  drumrpm = (float)(60000. / ((sample[0] / 1000.) * _PULSES_PER_REV_));
  
  rads = (float)(rpm / 9.54929659643); // How many RPM in 1 radian/second? The answer is 9.54929659643.
  
  angular_velocity = (float)rads; // sake of readability
  
  // angular acceleration = w / t     Angular acceleration (a) equals change in angular velocity (w) per change in time.
  angular_acceleration = (float)(angular_velocity / ms_to_secs);
  
  torque = (float)(_MOI_ * angular_acceleration); // MOI = motion of inertia, we know the drum is 11.83 as defined in config.h
  
  // P = t * w (Power = torque by angular velocity).
  power = (float)(torque * angular_acceleration);
  
  horsepower = (float)(power * 1.34);
  
  if (_php_output_ > 0)
  {
    Serial.print(rpm);
    Serial.print(" ");
    Serial.print(torque);
    Serial.print(" ");
    Serial.print(power);
    Serial.println("EOL");
  }
  else
  {
    Serial.print("Drum RPM: ");
    Serial.print(drumrpm);

    Serial.print(" RPM: ");
    Serial.print(rpm);
    
    Serial.print(" Torque: ");
    Serial.print(torque);
    
    Serial.print(" Power (kw): ");
    Serial.print(power);  
    
    Serial.print(" Difference (ms): ");
    Serial.print(difference);
    
    Serial.print(" rads: ");
    Serial.print(rads);
    
    Serial.print(" Angular Acceleration: ");
    Serial.println(angular_acceleration);
  }

  return; // angular_velocity;
}

void mybike ()
{
  signed long sample[3];
  
  sample[0] = 0x4C77;
  sample[1] = 0x4B56;
  calculate_stuff(sample);
  sample[0] = 0x4C15;
  sample[1] = 0x4AD4;
  calculate_stuff(sample);
  sample[0] = 0x4B55;
  sample[1] = 0x4A20;
  calculate_stuff(sample);
  sample[0] = 0x4A72;
  sample[1] = 0x491D;
  calculate_stuff(sample);
  sample[0] = 0x494D;
  sample[1] = 0x47F0;
  calculate_stuff(sample);
  sample[0] = 0x4800;
  sample[1] = 0x46AE;
  calculate_stuff(sample);
  sample[0] = 0x4695;
  sample[1] = 0x4551;
  calculate_stuff(sample);
  sample[0] = 0x4538;
  sample[1] = 0x43CF;
  calculate_stuff(sample);
  sample[0] = 0x439E;
  sample[1] = 0x425F;
  calculate_stuff(sample);
  sample[0] = 0x4239;
  sample[1] = 0x40F4;
  calculate_stuff(sample);
  sample[0] = 0x40EB;
  sample[1] = 0x3FA4;
  calculate_stuff(sample);
  sample[0] = 0x3F85;
  sample[1] = 0x3E57;
  calculate_stuff(sample);
  sample[0] = 0x3E5A;
  sample[1] = 0x3D33;
  calculate_stuff(sample);
  sample[0] = 0x3D41;
  sample[1] = 0x3C20;
  calculate_stuff(sample);
  sample[0] = 0x3C29;
  sample[1] = 0x3B11;
  calculate_stuff(sample);
  sample[0] = 0x3B2A;
  sample[1] = 0x3A22;
  calculate_stuff(sample);
  sample[0] = 0x3A47;
  sample[1] = 0x3939;
  calculate_stuff(sample);
  sample[0] = 0x3957;
  sample[1] = 0x3858;
  calculate_stuff(sample);
  sample[0] = 0x3876;
  sample[1] = 0x377F;
  calculate_stuff(sample);
  sample[0] = 0x37B5;
  sample[1] = 0x36B8;
  calculate_stuff(sample);
  sample[0] = 0x36DF;
  sample[1] = 0x35E9;
  calculate_stuff(sample);
  sample[0] = 0x3616;
  sample[1] = 0x352B;
  calculate_stuff(sample);
  sample[0] = 0x355A;
  sample[1] = 0x3471;
  calculate_stuff(sample);
  sample[0] = 0x3499;
  sample[1] = 0x33AC;
  calculate_stuff(sample);
  sample[0] = 0x33E1;
  sample[1] = 0x32FB;
  calculate_stuff(sample);
  sample[0] = 0x3332;
  sample[1] = 0x3251;
  calculate_stuff(sample);
  sample[0] = 0x3282;
  sample[1] = 0x319D;
  calculate_stuff(sample);
  sample[0] = 0x31CE;
  sample[1] = 0x30F6;
  calculate_stuff(sample);
  sample[0] = 0x3132;
  sample[1] = 0x305A;
  calculate_stuff(sample);
  sample[0] = 0x308D;
  sample[1] = 0x2FB3;
  calculate_stuff(sample);
  sample[0] = 0x2FE8;
  sample[1] = 0x2F18;
  calculate_stuff(sample);
  sample[0] = 0x2F54;
  sample[1] = 0x2E87;
  calculate_stuff(sample);
  sample[0] = 0x2EBF;
  sample[1] = 0x2DF5;
  calculate_stuff(sample);
  sample[0] = 0x2E28;
  sample[1] = 0x2D63;
  calculate_stuff(sample);
  sample[0] = 0x2DA3;
  sample[1] = 0x2CDE;
  calculate_stuff(sample);
  sample[0] = 0x2D17;
  sample[1] = 0x2C54;
  calculate_stuff(sample);
  sample[0] = 0x2C8C;
  sample[1] = 0x2BD1;
  calculate_stuff(sample);
  sample[0] = 0x2C16;
  sample[1] = 0x2B56;
  calculate_stuff(sample);
  sample[0] = 0x2B91;
  sample[1] = 0x2AD7;
  calculate_stuff(sample);
  sample[0] = 0x2B16;
  sample[1] = 0x2A62;
  calculate_stuff(sample);
  sample[0] = 0x2AA4;
  sample[1] = 0x29F3;
  calculate_stuff(sample);
  sample[0] = 0x2A2F;
  sample[1] = 0x297A;
  calculate_stuff(sample);
  sample[0] = 0x29C1;
  sample[1] = 0x290B;
  calculate_stuff(sample);
  sample[0] = 0x2952;
  sample[1] = 0x28A3;
  calculate_stuff(sample);
  sample[0] = 0x28E5;
  sample[1] = 0x2839;
  calculate_stuff(sample);
  sample[0] = 0x2878;
  sample[1] = 0x27D4;
  calculate_stuff(sample);
  sample[0] = 0x2818;
  sample[1] = 0x2773;
  calculate_stuff(sample);
  sample[0] = 0x27B7;
  sample[1] = 0x270F;
  calculate_stuff(sample);
  sample[0] = 0x2758;
  sample[1] = 0x26B0;
  calculate_stuff(sample);
  sample[0] = 0x26F9;
  sample[1] = 0x265A;
  calculate_stuff(sample);
  sample[0] = 0x26A2;
  sample[1] = 0x2600;
  calculate_stuff(sample);
  sample[0] = 0x2641;
  sample[1] = 0x25A1;
  calculate_stuff(sample);
  sample[0] = 0x25EA;
  sample[1] = 0x2550;
  calculate_stuff(sample);
  sample[0] = 0x2599;
  sample[1] = 0x24F8;
  calculate_stuff(sample);
  sample[0] = 0x253C;
  sample[1] = 0x24A5;
  calculate_stuff(sample);
  sample[0] = 0x24EB;
  sample[1] = 0x2458;
  calculate_stuff(sample);
  sample[0] = 0x249B;
  sample[1] = 0x2404;
  calculate_stuff(sample);
  sample[0] = 0x244E;
  sample[1] = 0x23B6;
  calculate_stuff(sample);
  sample[0] = 0x23FF;
  sample[1] = 0x236E;
  calculate_stuff(sample);
  sample[0] = 0x23B3;
  sample[1] = 0x231C;
  calculate_stuff(sample);
  sample[0] = 0x2369;
  sample[1] = 0x22D3;
  calculate_stuff(sample);
  sample[0] = 0x2320;
  sample[1] = 0x2292;
  calculate_stuff(sample);
  sample[0] = 0x22D9;
  sample[1] = 0x2246;
  calculate_stuff(sample);
  sample[0] = 0x2291;
  sample[1] = 0x2200;
  calculate_stuff(sample);
  sample[0] = 0x224C;
  sample[1] = 0x21C0;
  calculate_stuff(sample);
  sample[0] = 0x2208;
  sample[1] = 0x2177;
  calculate_stuff(sample);
  sample[0] = 0x21C2;
  sample[1] = 0x213A;
  calculate_stuff(sample);
  sample[0] = 0x2183;
  sample[1] = 0x2100;
  calculate_stuff(sample);
  sample[0] = 0x2143;
  sample[1] = 0x20BE;
  calculate_stuff(sample);
  sample[0] = 0x2105;
  sample[1] = 0x2082;
  calculate_stuff(sample);
  sample[0] = 0x20CC;
  sample[1] = 0x2046;
  calculate_stuff(sample);
  sample[0] = 0x2094;
  sample[1] = 0x200E;
  calculate_stuff(sample);
  sample[0] = 0x2054;
  sample[1] = 0x1FD0;
  calculate_stuff(sample);
  sample[0] = 0x201E;
  sample[1] = 0x1F9E;
  calculate_stuff(sample);
  sample[0] = 0x1FE9;
  sample[1] = 0x1F65;
  calculate_stuff(sample);
  sample[0] = 0x1FB0;
  sample[1] = 0x1F2E;
  calculate_stuff(sample);
  sample[0] = 0x1F7B;
  sample[1] = 0x1EFE;
  calculate_stuff(sample);
  sample[0] = 0x1F47;
  sample[1] = 0x1EC7;
  calculate_stuff(sample);
  sample[0] = 0x1F11;
  sample[1] = 0x1E95;
  calculate_stuff(sample);
  sample[0] = 0x1EDF;
  sample[1] = 0x1E64;
  calculate_stuff(sample);
  sample[0] = 0x1EAD;
  sample[1] = 0x1E33;
  calculate_stuff(sample);
  sample[0] = 0x1E7A;
  sample[1] = 0x1E01;
  calculate_stuff(sample);
  sample[0] = 0x1E4A;
  sample[1] = 0x1DDA;
  calculate_stuff(sample);
  sample[0] = 0x1E22;
  sample[1] = 0x1DA4;
  calculate_stuff(sample);
  sample[0] = 0x1DF2;
  sample[1] = 0x1D76;
  calculate_stuff(sample);
  sample[0] = 0x1DC5;
  sample[1] = 0x1D4C;
  calculate_stuff(sample);
  sample[0] = 0x1D9A;
  sample[1] = 0x1D26;
  calculate_stuff(sample);
  sample[0] = 0x1D6D;
  sample[1] = 0x1CF6;
  calculate_stuff(sample);
  sample[0] = 0x1D48;
  sample[1] = 0x1CCE;
  calculate_stuff(sample);
  sample[0] = 0x1D1C;
  sample[1] = 0x1CA6;
  calculate_stuff(sample);
  sample[0] = 0x1CEF;
  sample[1] = 0x1C80;
  calculate_stuff(sample);
  sample[0] = 0x1CC9;
  sample[1] = 0x1C59;
  calculate_stuff(sample);
  sample[0] = 0x1CA4;
  sample[1] = 0x1C31;
  calculate_stuff(sample);
  sample[0] = 0x1C7D;
  sample[1] = 0x1C0A;
  calculate_stuff(sample);
  sample[0] = 0x1C53;
  sample[1] = 0x1BE3;
  calculate_stuff(sample);
  sample[0] = 0x1C30;
  sample[1] = 0x1BBE;
  calculate_stuff(sample);
  sample[0] = 0x1C0D;
  sample[1] = 0x1B9D;
  calculate_stuff(sample);
  sample[0] = 0x1BE6;
  sample[1] = 0x1B79;
  calculate_stuff(sample);
  sample[0] = 0x1BC7;
  sample[1] = 0x1B59;
  calculate_stuff(sample);
  sample[0] = 0x1B9F;
  sample[1] = 0x1B34;
  calculate_stuff(sample);
  sample[0] = 0x1B81;
  sample[1] = 0x1B18;
  calculate_stuff(sample);
  sample[0] = 0x1B61;
  sample[1] = 0x1AF7;
  calculate_stuff(sample);
  sample[0] = 0x1B3C;
  sample[1] = 0x1AD1;
  calculate_stuff(sample);
  sample[0] = 0x1B20;
  sample[1] = 0x1AB3;
  calculate_stuff(sample);
  sample[0] = 0x1AFF;
  sample[1] = 0x1A98;
  calculate_stuff(sample);
  sample[0] = 0x1ADD;
  sample[1] = 0x1A73;
  calculate_stuff(sample);
  sample[0] = 0x1AC1;
  sample[1] = 0x1A58;
  calculate_stuff(sample);
  sample[0] = 0x1AA1;
  sample[1] = 0x1A3C;
  calculate_stuff(sample);
  sample[0] = 0x1A83;
  sample[1] = 0x1A1A;
  calculate_stuff(sample);
  sample[0] = 0x1A67;
  sample[1] = 0x1A00;
  calculate_stuff(sample);
  sample[0] = 0x1A4B;
  sample[1] = 0x19E3;
  calculate_stuff(sample);
  sample[0] = 0x1A29;
  sample[1] = 0x19C1;
  calculate_stuff(sample);
  sample[0] = 0x1A0F;
  sample[1] = 0x19A7;
  calculate_stuff(sample);
  sample[0] = 0x19F5;
  sample[1] = 0x198E;
  calculate_stuff(sample);
  sample[0] = 0x19D9;
  sample[1] = 0x1974;
  calculate_stuff(sample);
  sample[0] = 0x19BF;
  sample[1] = 0x1954;
  calculate_stuff(sample);
  sample[0] = 0x199D;
  sample[1] = 0x193D;
  calculate_stuff(sample);
  sample[0] = 0x1984;
  sample[1] = 0x1920;
  calculate_stuff(sample);
  sample[0] = 0x196A;
  sample[1] = 0x1906;
  calculate_stuff(sample);
  sample[0] = 0x1952;
  sample[1] = 0x18EE;
  calculate_stuff(sample);
  sample[0] = 0x1936;
  sample[1] = 0x18D2;
  calculate_stuff(sample);
  sample[0] = 0x191B;
  sample[1] = 0x18BB;
  calculate_stuff(sample);
  sample[0] = 0x1905;
  sample[1] = 0x18A3;
  calculate_stuff(sample);
  sample[0] = 0x18E8;
  sample[1] = 0x188A;
  calculate_stuff(sample);
  sample[0] = 0x18D0;
  sample[1] = 0x1873;
  calculate_stuff(sample);
  sample[0] = 0x18B7;
  sample[1] = 0x185D;
  calculate_stuff(sample);
  sample[0] = 0x18A3;
  sample[1] = 0x183F;
  calculate_stuff(sample);
  sample[0] = 0x1889;
  sample[1] = 0x182D;
  calculate_stuff(sample);
  sample[0] = 0x1876;
  sample[1] = 0x1812;
  calculate_stuff(sample);
  sample[0] = 0x185A;
  sample[1] = 0x17FC;
  calculate_stuff(sample);
  sample[0] = 0x1842;
  sample[1] = 0x17E5;
  calculate_stuff(sample);
  sample[0] = 0x1831;
  sample[1] = 0x17D3;
  calculate_stuff(sample);
  sample[0] = 0x1819;
  sample[1] = 0x17BC;
  calculate_stuff(sample);
  sample[0] = 0x1800;
  sample[1] = 0x17A3;
  calculate_stuff(sample);
  sample[0] = 0x17EF;
  sample[1] = 0x1792;
  calculate_stuff(sample);
  sample[0] = 0x17D9;
  sample[1] = 0x177C;
  calculate_stuff(sample);
  sample[0] = 0x17C4;
  sample[1] = 0x1768;
  calculate_stuff(sample);
  sample[0] = 0x17B1;
  sample[1] = 0x1755;
  calculate_stuff(sample);
  sample[0] = 0x1797;
  sample[1] = 0x173F;
  calculate_stuff(sample);
  sample[0] = 0x1786;
  sample[1] = 0x172C;
  calculate_stuff(sample);
  sample[0] = 0x1775;
  sample[1] = 0x171A;
  calculate_stuff(sample);
  sample[0] = 0x1761;
  sample[1] = 0x1705;
  calculate_stuff(sample);
  sample[0] = 0x174E;
  sample[1] = 0x16F1;
  calculate_stuff(sample);
  sample[0] = 0x173B;
  sample[1] = 0x16E4;
  calculate_stuff(sample);
  sample[0] = 0x1726;
  sample[1] = 0x16CB;
  calculate_stuff(sample);
  sample[0] = 0x1715;
  sample[1] = 0x16BE;
  calculate_stuff(sample);
  sample[0] = 0x1702;
  sample[1] = 0x16AA;
  calculate_stuff(sample);
  sample[0] = 0x16EE;
  sample[1] = 0x1695;
  calculate_stuff(sample);
  sample[0] = 0x16DB;
  sample[1] = 0x1684;
  calculate_stuff(sample);
  sample[0] = 0x16CB;
  sample[1] = 0x1673;
  calculate_stuff(sample);
  sample[0] = 0x16B8;
  sample[1] = 0x1660;
  calculate_stuff(sample);
  sample[0] = 0x16A8;
  sample[1] = 0x1651;
  calculate_stuff(sample);
  sample[0] = 0x1696;
  sample[1] = 0x1643;
  calculate_stuff(sample);
  sample[0] = 0x1687;
  sample[1] = 0x162F;
  calculate_stuff(sample);
  sample[0] = 0x1672;
  sample[1] = 0x161C;
  calculate_stuff(sample);
  sample[0] = 0x1664;
  sample[1] = 0x1611;
  calculate_stuff(sample);
  sample[0] = 0x1652;
  sample[1] = 0x15FF;
  calculate_stuff(sample);
  sample[0] = 0x1641;
  sample[1] = 0x15EF;
  calculate_stuff(sample);
  sample[0] = 0x1634;
  sample[1] = 0x15DF;
  calculate_stuff(sample);
  sample[0] = 0x162C;
  sample[1] = 0x15D9;
  calculate_stuff(sample);
  sample[0] = 0x1630;
  sample[1] = 0x15DD;
  calculate_stuff(sample);
  
  return;
}
