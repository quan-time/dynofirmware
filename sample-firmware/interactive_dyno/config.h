/*
  Start Configuration:

  Predefined Macro Name   Default Value (recommended) Description

  _LOGGING_               0       [0 = OFF, 1 = ON]  (Logging eats up the unit's memory)
  _SIMULATE_DRUM_         0       [0 = OFF, 1 = ON]  (Simulate Dynorun when "Make Run" is started in WOTID, turning this off uses the real Drum)
  _SIMULATE_GEAR_RATIO_   0       [0 = OFF, 1 = ON]  (Simulate Gear Ratio when "AutoCalc" is started in WOTID, turning this off uses the real Drum)
  _COM_BAUD_              19200                      (Serial connection baud rate)
  _DEBUG_                 0       [0 = OFF, 1 = ON]  (Debug information, useless to the WOTID frontend, only useful with a terminal connected)
  _EXTERNAL_RPM_SENSOR_   0       [0 = OFF, 1 = ON]  (Whether or not there is an external RPM sensor, use _RPM_HILO_ below to specify the Pin it's connected to)
  _PIN_                   0                          (Which Pin our photo interrupter is connected to)
  _DRUM_HILO_             0                          (Which Pin the Drum sensor is connected to)
  _TOOTH_1_               HIGH    [LOW or HIGH]      (Tooth sample #1, which physical part of the wheel to get the sample from. LOW = photo beam interrupted, HIGH = gate clear)
  _TOOTH_2_               HIGH    [LOW or HIGH]      (Tooth sample #2, which physical part of the wheel to get the sample from. LOW = photo beam interrupted, HIGH = gate clear)
  _TOOTH_SKIP_            0       [0]                (How many teeth to skip to reach the desired tooth, since our wheel has 4 teeth, we need to skip 2 teeth in between for the sample data to represent a full rotation, we use the data from the 2 skipped teeth to average out the target teeth)
  _RPM_                   HIGH    [LOW or HIGH]      (Which state to read external RPM samples from, HIGH or LOW)
  _IGNORE_STARTVALUE_     0       [0 = OFF, 1 = ON]  (Ignore the minimum start value (km/h) specified by WOTID, setting this to 1 will send all data to WOTID, even if it's below the start value)
  _STARTCOUNT_BUFFER_     5                          (Maximum ammount of bytes WOTID will send, when issuing "StartValue")
  _OPTICAL_TIMEOUT_       1000000 [1 second]         (Maximum ammount of time in microseconds that the firmware will wait for a reply from the optical sensor, Arduino default is 1s, we could make it 100ms since the slowest sample we can send is 65.535ms)
  _SERIAL_BUFFER_         8                          (Ammount of bytes that should be pre-allocated to read the serial connection's buffer with, I've determined 8 is plenty "S065535," is the longest string I've seen the frontend generate)
  _FILTER_SLOW_SAMPLES_   0       [0 = OFF, 1 = ON]  (How we handle optical sensor values that are greater than _MAXIMUM_MICROSECOND_, 1 turns this on by filtering them so they don't appear in WOTID, 0 turns this off and just sends the value as 65535 instead)
  _END_RUN_               1                          (How many deceleration samples in a row are required to call it a day and issue the end of the run with "T")
  _MINIMUM_SAMPLES_       20      [0 = OFF]          (WOTID requires 20 sets of samples minimum to be able to make a graph, we ignore _END_RUN_ until we have reached our minimum then the run can be ended)
  _CLOCK_FREQUENCY_       1                          (Has a huge affect on minimum starting speed. Measured in MHz, WOTID uses this value to divide every optical sensor value by, by setting a value that isn't 1 we override this behaviour and let the firmware do the math instead. 2 = 0.5, 1 = 1, 0.5 = 2, 0.225 = 4 etc.)
  _MAXIMUM_MICROSECOND_   65535   [65.535ms]         (WOTID only accepts hexadecimal values up to FFFF, which is 65535, related to minimum starting value, if _CLOCK_FREQUENCY_ changes from 1, we might need to automatically adjust our max to suit)
  _MAKERUN_TIMEOUT_       10000   [10 seconds]       (How long in milliseconds till the backend will timeout waiting for a valid sample from the optical sample when "Start Now" is hit in the Make Run menu)
  _VERSION_STRING_        "Blah"                     (The version string that will be seen when the About button is used in WOTID)
  _SYSTEM_INFO_           0       [0 = OFF, 1 = ON]  (Whether to print CPU speed, memory free, uptime etc. in the About box)
  _LED_PIN_               6                          (Pin the builtin Teensy LED is on, 6 on Teensy++ 2.0, 11 on Teensy 2.0)
  _WOTID_FRONTEND_DELAY_  1500    [1.5 seconds]      (WOTID has a massive delay between indicating it's ready to accept data, and when it's actually ready to accept data)
  _SAMPLE_PAUSE_          2       [2 micro, 0 = OFF] (WOTID seems to indicate it needs 2 microseconds between sets of samples for timing reasons, example "HIGH,HIGH" then wait 2 seconds)
  _BETWEEN_SAMPLE_PAUSE_  2       [2 micro, 0 = OFF] (WOTID seems to indicate it needs 2 microseconds between individual samples for timing reasons, example "HIGH" then wait 2 micros "HIGH")
  _CALIBRATION_SAMPLES_   15                         (The Test() function used by WOTID's calibration tool, the documentation by default specifies 15 samples but depending on how fast the drum is spinning, 15 samples could only last 3 seconds, if you wanted it to run for afew minutes maybe a value of 1500 samples)

*/
#define _MOI_ (float)11.83
#define _RPM_CALIBRATION_ 4000
// How many pulses per revolution
#define _PULSES_PER_REV_ 4
// Circumfereance in mm
#define _CIRCUMFERENCE_ 1426.283
long int _rpm_milliseconds_ = 0;
#define _PHP_OUTPUT_ 1

#define _LOGGING_ 0
#define _SIMULATE_DRUM_ 0
#define _SIMULATE_GEAR_RATIO_ 0
#define _COM_BAUD_ 19200
#define _DEBUG_ 0
#define _EXTERNAL_RPM_SENSOR_ 0
#define _PIN_ 0
#define _DRUM_HILO_ 0
#define _TOOTH_1_ HIGH
#define _TOOTH_2_ HIGH
#define _TOOTH_SKIP_ 0
#define _RPM_ HIGH
#define _IGNORE_STARTVALUE_ 1
#define _STARTCOUNT_BUFFER_ 5
#define _OPTICAL_TIMEOUT_ 1000000
#define _SERIAL_BUFFER_ 8
#define _FILTER_SLOW_SAMPLES_ 0
#define _END_RUN_ 4
#define _MINIMUM_SAMPLES_ 20
#define _CLOCK_FREQUENCY_ 1
#define _MAXIMUM_MICROSECOND_ 65535
#define _MAKERUN_TIMEOUT_ 10000
//#define _MAXIMUM_MICROSECOND_ (int)(65535 / _CLOCK_FREQUENCY_) // not used
#define _VERSION_STRING_ "Quan-Time WOTID firmware. Version 0.32"
#define _SYSTEM_INFO_ 0
#define _LED_PIN_ 6
#define _WOTID_FRONTEND_DELAY_ 1500
#define _SAMPLE_PAUSE_ 2
#define _BETWEEN_SAMPLE_PAUSE_ 2
#define _CALIBRATION_SAMPLES_ 15
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
int ledState = 0;
/* Logging Global Variables */
#if (_LOGGING_ == 1)
  int playback_string[_MAX_LINES_][_LINE_LENGTH_]; // _MAX_LINES_ * _LINE_LENGTH = the ammount of bytes this will allocate (200 * 15 = 3000bytes for example, Teensy++ 2.0 has 8192 bytes total), this really should be made a local variable somehow, it's an evil global variable
  int playback_buttonState = 0; // Status of button, whether it's been pressed or notr
#endif
/* End Logging Globals */
/* End Global Variables */
