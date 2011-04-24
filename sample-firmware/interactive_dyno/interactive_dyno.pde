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
  int readbyte;
  signed long sample[3];
  
  available_bytes = Serial.available();

  if (available_bytes > 0) 
  {     
    readbyte = Serial.read();
    
    if ( (readbyte == 'S') || (readbyte == 's') )
    {
      //About();
      Serial.println("=================");
      Serial.println("Starting Dyno Run (infinite loop, restart the serial connection when finished)");
      Serial.println("=================");
      
      while (1 == 1)
      {
        sample[0] = pulseIn(_PIN_, _TOOTH_1_); // 1st tooth
        sample[1] = pulseIn(_PIN_, _TOOTH_2_); // 1st tooth (1/4 quarter turn)
        
        if ( !(sample[0] == 0) && !(sample[1] == 0) )
        {
          //Serial.print("Angular Acceleration (rads): ");
          Serial.println( calculate_stuff(sample) );
          //Serial.print("Torque: ");
          //Serial.println( ( _MOI_ * calculate_rads(sample) ) );
        }
        
        //Serial.print(" and ");
        //Serial.println(calculate_rpm(sample[1]);
      
        //return;
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
        Serial.println("Waiting 1 second to try again");
        delay(1000);
        
        _rpm_milliseconds_ = pulseIn(_PIN_, _TOOTH_1_);
      }
      
      Serial.print("SUCCESS: ");
      Serial.print( _rpm_milliseconds_ );
      Serial.print(" milliseconds = ");
      Serial.println(_RPM_CALIBRATION_);
      
      main_menu();
      return;
    }  
    if (readbyte == '27')
    {
      main_menu();
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
  
  Serial.println("Interactive Options:");
  Serial.println("- 'S' to start dyno run");
  Serial.println("- 'T' to test dyno");
  Serial.print("- 'R' to Calibrate @ ");
  Serial.print(_RPM_CALIBRATION_);
  Serial.print(" RPM [currently: ");
  Serial.print(_rpm_milliseconds_);
  Serial.println(" milliseconds]");
  Serial.println("***************************************");
  
  return;
}

int calculate_stuff(signed long sample[])
{
  float rpm;
  float rps;
  float rads;
  float angular_velocity;
  float angular_acceleration;
  float torque;
  float power;
  signed long difference;
  signed long ms_to_secs;
  
  if (sample[1] > sample[0])
    difference = (sample[1] - sample[0]);
  else
    difference = (sample[0] - sample[1]);

  Serial.println();
  Serial.print("Difference (ms): ");
  Serial.print(difference);
  
  ms_to_secs = (difference / 1000); // lets convert from milliseconds to seconds so we can match this to radians per second isntead of radians per milliseconds

  rpm = (float)(60000. / ((difference / 1000.) * _PULSES_PER_REV_)); //revs per minute
  
  Serial.print(" RPM: ");
  Serial.print(rpm);
  
  //rps = (float)(rpm / 60); // revs per seconds
  
  //Serial.print(" RPS: ");
  //Serial.print(rps);
  
  rads = (float)(rpm / 9.54929659643); // How many RPM in 1 radian/second? The answer is 9.54929659643.
  
  Serial.print(" rads: ");
  Serial.print(rads);
  
  angular_velocity = rads;
  
  // angular acceleration = w / t     Angular acceleration (a) equals change in angular velocity (w) per change in time.
  angular_acceleration = (float)(angular_velocity / ms_to_secs);
  
  Serial.print(" Angular Acceleration: ");
  Serial.print(angular_acceleration);
  
  torque = (_MOI_ * angular_acceleration);

  Serial.print(" Torque: ");
  Serial.print(torque);
  
  // P = t * w (Power = torque by angular velocity).
  power = (torque * angular_acceleration);

  Serial.print(" Power: ");
  Serial.println(power);  

  return rpm; // angular_velocity;
}

