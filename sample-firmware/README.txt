PROJECT: drum_test (Teensy <-> Terminal):

For debugging the physical drum unit and it's optical sensor, without using WOTID.

Intended to read values from the optical sensor attached to the drum and print them into a Terminal, this firmware will not work with the WOTID frontend.


PROJECT: dyno_simulator (Teensy <-> WOTID):

For debugging information sent from the Teensy unit to the WOTID frontend, without needing the optical sensor plugged in.

Intended to send simulated drum output (optical sensor) data to the WOTID frontend to debug how WOTID handles data and the way data is sent to it.


PROJECT: serial_test (Teensy <-> WOTID)

For debugging how the serial link between Teensy and WOTID behaves and how data is sent between them.

Intended to be used with a program that allows you to split the data of the physical serial com port between 2 (or more) virtual ports. I connect WOTID to one of the virtual ports, and my Terminal program to the other virtual port so anything printed by either Teensy or WOTID appears in the Terminal, also anything written in the Terminal shows up to Teensy and WOTID.


PROJECT: optical_test (Teensy <-> Terminal):

For debugging our photo interrupter (optical sensor), HIGH state indicating the photosensor's IR beam has been disrupted, while LOW state indicating the gate is clear.

Intended to be used with the Arduino serial monitor to isolate our photosensor, debug & diagnose any issues the physical sensor may have without needing to use the main firmware (WOTID.pde)