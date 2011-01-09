/*
  Start Configuration:

  Predefined Macro Name   Default Value (recommended) Description

  _LOGGING_               0       [0 = OFF, 1 = ON]  (Logging eats up the unit's memory)
  _SIMULATE_DRUM_         0       [0 = OFF, 1 = ON]  (Simulate Dynorun when "Make Run" is started in WOTID, turning this off uses the real Drum)
  _COM_BAUD_              19200                      (Serial connection baud rate)
  _DEBUG_                 0       [0 = OFF, 1 = ON]  (Debug information, useless to the WOTID frontend, only useful with a terminal connected)
  _EXTERNAL_RPM_SENSOR_   0       [0 = OFF, 1 = ON]  (Whether or not there is an external RPM sensor, use _RPM_HILO_ below to specify the Pin it's connected to)
  _PIN_                   0                          (Which Pin to make a Serial connection with)
  _DRUM_HILO_             0                          (Which Pin the Drum sensor is connected to)
  _IGNORE_STARTVALUE_     0       [0 = OFF, 1 = ON]  (Ignore the minimum start value (km/h) specified by WOTID, setting this to 1 will send all data to WOTID, even if it's below the start value)
  _STARTCOUNT_BUFFER_     5                          (Maximum ammount of bytes WOTID will send, when issuing "StartValue")
  _OPTICAL_TIMEOUT_       1000000                    (Maximum ammount of time in microseconds that the firmware will wait for a reply from the optical sensor, Arduino default is 1s, we could make it 100ms since the slowest sample we can send is 65.535ms)
  _SERIAL_BUFFER_         8                          (Ammount of bytes that should be pre-allocated to read the serial connection's buffer with, I've determined 8 is plenty "S065535," is the longest string I've seen the frontend generate)
  _FILTER_SLOW_SAMPLES_   0       [0 = OFF, 1 = ON]  (How we handle optical sensor values that are greater than _MAXIMUM_MICROSECOND_, 1 turns this on by filtering them so they don't appear in WOTID, 0 turns this off and just sends the value as 65535 instead)
  _END_RUN_               1                          (How many deceleration samples in a row are required to call it a day and issue the end of the run with "T")
  _CLOCK_FREQUENCY_       1                          (Has a huge affect on minimum starting speed. Measured in MHz, WOTID uses this value to divide every optical sensor value by, by setting a value that isn't 1 we override this behaviour and let the firmware do the math instead. 2 = 0.5, 1 = 1, 0.5 = 2, 0.225 = 4 etc.)
  _MAXIMUM_MICROSECOND_   65535                      (WOTID only accepts hexadecimal values up to FFFF, which is 65535, related to minimum starting value, if _CLOCK_FREQUENCY_ changes from 1, we might need to automatically adjust our max to suit)
  _VERSION_STRING_        "Blah"                     (The version string that will be seen when the About button is used in WOTID)
  _LED_PIN_               6                          (Pin the builtin Teensy LED is on, 6 on Teensy++ 2.0, 11 on Teensy 2.0

*/
#define _LOGGING_ 0
#define _SIMULATE_DRUM_ 0
#define _COM_BAUD_ 19200
#define _DEBUG_ 0
#define _EXTERNAL_RPM_SENSOR_ 0
#define _PIN_ 0
#define _DRUM_HILO_ 0
#define _IGNORE_STARTVALUE_ 0
#define _STARTCOUNT_BUFFER_ 5
#define _OPTICAL_TIMEOUT_ 1000000
#define _SERIAL_BUFFER_ 8
#define _FILTER_SLOW_SAMPLES_ 1
#define _END_RUN_ 1
#define _CLOCK_FREQUENCY_ 1
#define _MAXIMUM_MICROSECOND_ 65535
//#define _MAXIMUM_MICROSECOND_ (int)(65535 / _CLOCK_FREQUENCY_) // not used
#define _VERSION_STRING_ "Quan-Time WOTID firmware. Version 0.3"
#define _LED_PIN_ 6
/* End Configuration */

/*
  Start Logging Configuration (ignored if LOGGING is OFF)

  _PLAYBACK_PIN_  5   (Use Pin 5 button press to playback logged data to the terminal in WOTID format)
  _MAX_LINES_     200 (Maximum ammount of lines to cache in memory, this will affect memory because it pre-allocates memory)
  _LINE_LENGTH_   16  (How much characters each line requires "FFFF,FFFF,FFFF" is 15 charactes, we reserve 16 so there is 1 byte of padding)

*/
#if (_LOGGING_ == 1)
  #define _PLAYBACK_PIN_ 5
  #define _MAX_LINES_ 200
  #define _LINE_LENGTH_ 16
#endif
/* End Logging Configuration */

/*
  External RPM Sensor Configuration

  _RPM_HILO_  0  (Which Pin the RPM sensor is connected to)

*/
#define _RPM_HILO_ 0
/* End */

/* Teensy CPU Speed Control: http://www.pjrc.com/teensy/prescaler.html */
#define CPU_PRESCALE(n) (CLKPR = 0x80, CLKPR = (n))
#define CPU_16MHz       0x00
#define CPU_8MHz        0x01
#define CPU_4MHz        0x02
#define CPU_2MHz        0x03
#define CPU_1MHz        0x04
#define CPU_500kHz      0x05
#define CPU_250kHz      0x06
#define CPU_125kHz      0x07
#define CPU_62kHz       0x08
/* End Teensy CPU Frequency Overrride */

/* Global Variables */
int bytesreceived = 0; // Count how many bytes the WOTID frontend has sent the firmware, only counts the important data, ignores B12345 in AB12345 for example (WOTID about string)
int startup = 0; // Used to calculate uptime
int current_line = 0; // Keep track of how many lines have been saved in memory so far, I really should change this to a local variable.. global variables are evil.
/* Logging Global Variables */
#if (_LOGGING_ == 1)
  char playback_string[_MAX_LINES_][_LINE_LENGTH_]; // _MAX_LINES_ * _LINE_LENGTH = the ammount of bytes this will allocate (200 * 15 = 3000bytes for example, Teensy++ 2.0 has 8192 bytes total), this really should be made a local variable somehow, it's an evil global variable
  int playback_buttonState = 0; // Status of button, whether it's been pressed or notr
#endif
/* End Logging Globals */
/* End Global Variables */
