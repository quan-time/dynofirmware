 // To compile: gcc filename.c -o outputname.exe (or just "outputname" instead of "outputname.exe" in linux)
 // To execute: outputname.exe (windows) or ./outputname.exe (linux)
 // To enable all warnings, put -Wall before gcc

#include <stdio.h> // printf
#include <math.h> // M_PI
#include <stdlib.h> // abs
float _gear_ratio_;

void wotid_full_dynorun(); // this contains all 107 samples of the following. source file: https://github.com/quan-time/dynofirmware/blob/master/sample-data/RAWDATA.DAT
void calculate_data(unsigned long sample[], int arraycount);

int main(void)
{

	printf("============== START ==============\n");
	wotid_full_dynorun();

	printf("============== FINISH ==============\n");

	return 1;
}

void wotid_full_dynorun()
{
	unsigned long sample[300];
	int i = 0;
	_gear_ratio_ = (float)3.75;

	sample[i++] = 0x510E; // 20750 microseconds, the time it took for the drum to turn 1/4
	sample[i++] = 0x4EE2; // 20194 microseconds. the drum has gained in speed, only 20194 microseconds to complete the same 1/4 turn
	sample[i++] = 0x4CE5;
	sample[i++] = 0x4B15;
	sample[i++] = 0x4968;
	sample[i++] = 0x47D8;
	sample[i++] = 0x465F;
	sample[i++] = 0x450B;
	sample[i++] = 0x43D0;
	sample[i++] = 0x429F;
	sample[i++] = 0x4180;
	sample[i++] = 0x4076;
	sample[i++] = 0x3F78;
	sample[i++] = 0x3E77;
	sample[i++] = 0x3D83;
	sample[i++] = 0x3C9A;
	sample[i++] = 0x3BAD;
	sample[i++] = 0x3ACC;
	sample[i++] = 0x39F5;
	sample[i++] = 0x392A;
	sample[i++] = 0x3866;
	sample[i++] = 0x37A5;
	sample[i++] = 0x36ED;
	sample[i++] = 0x3640;
	sample[i++] = 0x3596;
	sample[i++] = 0x34EC;
	sample[i++] = 0x3444;
	sample[i++] = 0x33AA;
	sample[i++] = 0x330E;
	sample[i++] = 0x3277;
	sample[i++] = 0x31E9;
	sample[i++] = 0x3156;
	sample[i++] = 0x30CB;
	sample[i++] = 0x3046;
	sample[i++] = 0x2FC0;
	sample[i++] = 0x2F41;
	sample[i++] = 0x2EC0;
	sample[i++] = 0x2E49;
	sample[i++] = 0x2DD2;
	sample[i++] = 0x2D5D;
	sample[i++] = 0x2CED;
	sample[i++] = 0x2C84;
	sample[i++] = 0x2C1A;
	sample[i++] = 0x2BB2;
	sample[i++] = 0x2B4D;
	sample[i++] = 0x2AEC;
	sample[i++] = 0x2A8B;
	sample[i++] = 0x2A2E;
	sample[i++] = 0x29D1;
	sample[i++] = 0x2976;
	sample[i++] = 0x291D;
	sample[i++] = 0x28C5;
	sample[i++] = 0x2872;
	sample[i++] = 0x281F;
	sample[i++] = 0x27CE;
	sample[i++] = 0x2780;
	sample[i++] = 0x2732;
	sample[i++] = 0x26E4;
	sample[i++] = 0x2696;
	sample[i++] = 0x264F;
	sample[i++] = 0x2604;
	sample[i++] = 0x25BF;
	sample[i++] = 0x257A;
	sample[i++] = 0x2539;
	sample[i++] = 0x24F6;
	sample[i++] = 0x24BA;
	sample[i++] = 0x247E;
	sample[i++] = 0x2445;
	sample[i++] = 0x240E;
	sample[i++] = 0x23D6;
	sample[i++] = 0x23A1;
	sample[i++] = 0x236A;
	sample[i++] = 0x2335;
	sample[i++] = 0x2300;
	sample[i++] = 0x22C9;
	sample[i++] = 0x2293;
	sample[i++] = 0x225D;
	sample[i++] = 0x2227;
	sample[i++] = 0x21F1;
	sample[i++] = 0x21BA;
	sample[i++] = 0x2186;
	sample[i++] = 0x2154;
	sample[i++] = 0x2121;
	sample[i++] = 0x20F0;
	sample[i++] = 0x20BD;
	sample[i++] = 0x208C;
	sample[i++] = 0x205D;
	sample[i++] = 0x2031;
	sample[i++] = 0x2003;
	sample[i++] = 0x1FD4;
	sample[i++] = 0x1FA8;
	sample[i++] = 0x1F7D;
	sample[i++] = 0x1F51;
	sample[i++] = 0x1F24;
	sample[i++] = 0x1EFD;
	sample[i++] = 0x1ED6;
	sample[i++] = 0x1EB0;
	sample[i++] = 0x1E89;
	sample[i++] = 0x1E65;
	sample[i++] = 0x1E40;
	sample[i++] = 0x1E1C;
	sample[i++] = 0x1DFD;
	sample[i++] = 0x1DDD;
	sample[i++] = 0x1DBB;
	sample[i++] = 0x1D95;
	sample[i++] = 0x1D74;
	sample[i++] = 0x1D53;
	sample[i++] = 0x1D34;
	sample[i++] = 0x1D13;
	sample[i++] = 0x1CF1;
	sample[i++] = 0x1CD2;
	sample[i++] = 0x1CB1;
	sample[i++] = 0x1C96;
	sample[i++] = 0x1C7A;
	sample[i++] = 0x1C5B;
	sample[i++] = 0x1C3C;
	sample[i++] = 0x1C21;
	sample[i++] = 0x1C05;
	sample[i++] = 0x1BE9;
	sample[i++] = 0x1BCD;
	sample[i++] = 0x1BB3;
	sample[i++] = 0x1B97;
	sample[i++] = 0x1B79;
	sample[i++] = 0x1B5F;
	sample[i++] = 0x1B48;
	sample[i++] = 0x1B2E;
	sample[i++] = 0x1B12;
	sample[i++] = 0x1AF7;
	sample[i++] = 0x1ADF;
	sample[i++] = 0x1AC6;
	sample[i++] = 0x1AAF;
	sample[i++] = 0x1A95;
	sample[i++] = 0x1A79;
	sample[i++] = 0x1A5F;
	sample[i++] = 0x1A49;
	sample[i++] = 0x1A36;
	sample[i++] = 0x1A1E;
	sample[i++] = 0x1A01;
	sample[i++] = 0x19EA;
	sample[i++] = 0x19D6;
	sample[i++] = 0x19A9;
	sample[i++] = 0x1992;
	sample[i++] = 0x1966;
	sample[i++] = 0x1952;
	sample[i++] = 0x1927;
	sample[i++] = 0x1911;
	sample[i++] = 0x18EA;
	sample[i++] = 0x18D5;
	sample[i++] = 0x18AD;
	sample[i++] = 0x189B;
	sample[i++] = 0x1872;
	sample[i++] = 0x1861;
	sample[i++] = 0x183B;
	sample[i++] = 0x182A;
	sample[i++] = 0x1808;
	sample[i++] = 0x17F4;
	sample[i++] = 0x17D6;
	sample[i++] = 0x17C5;
	sample[i++] = 0x17A3;
	sample[i++] = 0x1794;
	sample[i++] = 0x1774;
	sample[i++] = 0x1764;
	sample[i++] = 0x1746;
	sample[i++] = 0x1736;
	sample[i++] = 0x1719;
	sample[i++] = 0x170A;
	sample[i++] = 0x16ED;
	sample[i++] = 0x16DF;
	sample[i++] = 0x16C3;
	sample[i++] = 0x16B5;
	sample[i++] = 0x1698;
	sample[i++] = 0x168B;
	sample[i++] = 0x1671;
	sample[i++] = 0x1662;
	sample[i++] = 0x164A;
	sample[i++] = 0x163C;
	sample[i++] = 0x1622;
	sample[i++] = 0x1618;
	sample[i++] = 0x15FE;
	sample[i++] = 0x15F2;
	sample[i++] = 0x15DC;
	sample[i++] = 0x15CD;
	sample[i++] = 0x15B6;
	sample[i++] = 0x15AC;
	sample[i++] = 0x1595;
	sample[i++] = 0x158A;
	sample[i++] = 0x1577;
	sample[i++] = 0x1569;
	sample[i++] = 0x1553;
	sample[i++] = 0x154A;
	sample[i++] = 0x1533;
	sample[i++] = 0x152A;
	sample[i++] = 0x1515;
	sample[i++] = 0x1509;
	sample[i++] = 0x14F9;
	sample[i++] = 0x14EF;
	sample[i++] = 0x14DB;
	sample[i++] = 0x14D2;
	sample[i++] = 0x14BD;
	sample[i++] = 0x14B6;
	sample[i++] = 0x14A4;
	sample[i++] = 0x149A;
	sample[i++] = 0x1487;
	sample[i++] = 0x147F;
	sample[i++] = 0x146B;
	sample[i++] = 0x146B;
	sample[i++] = 0x1462;
	sample[i++] = 0x1457;
	sample[i++] = 0x1452;
	sample[i++] = 0x144E;
	sample[i++] = 0x1444;
	sample[i++] = 0x1440;
	sample[i++] = 0x143E;
	sample[i++] = 0x143D;
	sample[i++] = 0x144D;
	sample[i++] = 0x1456;

	calculate_data(sample, i);

	return;
}


void calculate_data(unsigned long sample[], int arraycount)
{
	float drumrpm[3];
	float angular_velocity[3];
	float power;

	int i = 0;
	int elements = 5; // only step through the first x repititions
	//int elements = arraycount-2; // step through the entire ~213 repititons

	const float _MOI_ = 11.83; 	// Moment of Inertia of the drum. 11.83kg/m^2
	const unsigned int _PULSES_PER_REV_ = 4; 	// Sensor wheel has 4 teeth, it takes 4 pulses to complete a full drum revolution

	float times[3] = {0}; // Known. Previous three times for the spokes
	float angular_velocity_rad = 0; // Angular velocity in rad/s
	float energy[2] = {0}; // Angular acceleration measurement


	while(i < elements)
	{

		printf("--------------- repetition: %i ---------------\n",i);

		times[0] = sample[i]; // last sample
		times[1] = sample[i+1]; // the 2nd to last sample
		times[2] = sample[i+2]; // current sample

		if ((times[0] == 0) || (times[1] == 0) || (times[2] == 0))
			break;

		printf("times[0]: %2.f micros	times[1] %2.f micros	times[2] %2.f micros\n",times[0],times[1],times[2]);

		drumrpm[0] = (60000. / ((times[0] / 1000.) * _PULSES_PER_REV_)); // convert times[0] to drumrpm
		drumrpm[1] = (60000. / ((times[1] / 1000.) * _PULSES_PER_REV_)); // convert times[1] to drumrpm
		drumrpm[2] = (60000. / ((times[2] / 1000.) * _PULSES_PER_REV_)); // convert times[2] to drumrpm

		printf("drumrpm[0]: %f drumrpm[1] %f drumrpm[2] %f\n",drumrpm[0],drumrpm[1],drumrpm[2]);

		angular_velocity[0] = ((drumrpm[0]/60.) * (2.*M_PI)); // convert times[0]'s RPM to rads/s
		angular_velocity[1] = ((drumrpm[1]/60.) * (2.*M_PI)); // convert times[1]'s RPM to rads/s
		angular_velocity[2] = ((drumrpm[2]/60.) * (2.*M_PI)); // convert times[2]'s RPM to rads/s

		// Start your code

		// Calculate angular velocity
		angular_velocity_rad = (250 * M_PI) / (times[1] - times[0]); // Number of radians divided by time to cover that angle multiplied by 1000 to convert ms to s.

		// Energy calculation, E = (1/2)Iw² for a rotating mass
		energy[1] = (_MOI_ * angular_velocity[1] * angular_velocity[1]) / 2; // inertia, I assume this should be _MOI_, the moment of inertia of 11.83kg/m^2. Also why is angular_velocity[1] being squared?

		power = 2 * (energy[1] - energy[0]) / (times[2] - times[1]); // Power is change in energy over change in time.. is this meant to be in watts or torque?

		printf("Watts: %f	Kilowatts: %f\n", power, power/1000);

		// Transmit calculated power to PC through whatever interface you want.

		// Prepare for next cycle
		//times[0] = times[1]; // unnecessary check top of while loop
		//times[1] = times[2]; // same as above
		energy[0] = energy[1];

		// End your code

		i++;
	}

	return;
}