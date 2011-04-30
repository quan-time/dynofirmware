 // To compile: gcc filename.c -o outputname.exe (or just "outputname" instead of "outputname.exe" in linux)
 // To execute: outputname.exe (windows) or ./outputname.exe (linux)
 // To enable all warnings, put -Wall before gcc

#include <stdio.h> // printf
#include <math.h> // M_PI
float _gear_ratio_;

void wotid_dynorun(); // contains the first 3 samples (of 107 possible): source file: https://github.com/quan-time/dynofirmware/blob/master/sample-data/RAWDATA.DAT
void wotid_full_dynorun(); // this contains all 107 samples of the above
// Don't use the 2 below
void zzr_dynorun(); // my bike (zzr250), doesn't work in WOTID.. but prints over 1000kw so useless
void zzr_full_dynorun();
void calculate_stuff(unsigned long sample[]);

int main(void)
{

/*
Uncomment the
wotid_dynorun and zzr_dynorun only go through the first 3 sets of samples (4 individual data points)
While *_full_dynorun go through the entire dynorun start to finish with 107+ sets of samples
*/

	printf("============== START ==============\n");
	//wotid_full_dynorun();
	wotid_dynorun();
	//zzr_dynorun();
	//zzr_full_dynorun();

	printf("============== FINISH ==============\n");

	return 1;
}

void wotid_dynorun()
{
	unsigned long sample[3];
	_gear_ratio_ = (float)3.75;

	// What are these numbers? Each one is how long the drum took to do 1/4 of a revolution
	// Just 2 pairs of data sets (each data set is 2 samples)

	// By using diameter of 460mm, known inertia of 11.83kg/m^2, 4 pulses per revolution, 1mhz (1 million counts per second and gear ratio (engine:drum rpm) of 3.75, WOTID has the following for each of the 3

	/*
	RPM: 2714
	ft-lbs: 121.1
	kg/m: 16.7
	hp: 62.5
	ps: 63.5
	kw: 45.7
	*/
	sample[0] = 0x510E; // convert hex to decimal = 20750
	sample[1] = 0x4EE2; // convert hex to decimal = 20194;
	calculate_stuff(sample);

	/*
	RPM 2860
	ft-lbs: 117.5
	kg/m: 16.3
	hp: 64
	ps: 64.9
	kw: 47.7
	*/
	sample[0] = 0x4CE5;
	sample[1] = 0x4B15;
	calculate_stuff(sample);

	/*
	RPM: 2996
	ft-lbs: 115.9
	kg/m: 16
	hp: 66.1
	ps: 67
	kw: 49.3
	*/
	sample[0] = 0x4968;
	sample[1] = 0x47D8;
	calculate_stuff(sample);

	return;
}
void zzr_dynorun()
{
	unsigned long sample[3];
	_gear_ratio_ = (float)4.8;

	sample[0] = 0x4C77;
	sample[1] = 0x4B56;
	calculate_stuff(sample);
	sample[0] = 0x4C15;
	sample[1] = 0x4AD4;
	calculate_stuff(sample);

	//sample[0] = 0x4B55;
	//sample[1] = 0x4A20;
	//calculate_stuff(sample);

	return;
}

void zzr_full_dynorun()
{
	unsigned long sample[3];
	_gear_ratio_ = (float)4.8;

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
	sample[0] = 0x1600;
	sample[1] = 0x1601;
	calculate_stuff(sample);

	return;
}

void wotid_full_dynorun()
{
	unsigned long sample[3];
	_gear_ratio_ = (float)3.75;

	sample[0] = 0x510E;
	sample[1] = 0x4EE2;
	calculate_stuff(sample);
	sample[0] = 0x4CE5;
	sample[1] = 0x4B15;
	calculate_stuff(sample);
	sample[0] = 0x4968;
	sample[1] = 0x47D8;
	calculate_stuff(sample);
	sample[0] = 0x465F;
	sample[1] = 0x450B;
	calculate_stuff(sample);
	sample[0] = 0x43D0;
	sample[1] = 0x429F;
	calculate_stuff(sample);
	sample[0] = 0x4180;
	sample[1] = 0x4076;
	calculate_stuff(sample);
	sample[0] = 0x3F78;
	sample[1] = 0x3E77;
	calculate_stuff(sample);
	sample[0] = 0x3D83;
	sample[1] = 0x3C9A;
	calculate_stuff(sample);
	sample[0] = 0x3BAD;
	sample[1] = 0x3ACC;
	calculate_stuff(sample);
	sample[0] = 0x39F5;
	sample[1] = 0x392A;
	calculate_stuff(sample);
	sample[0] = 0x3866;
	sample[1] = 0x37A5;
	calculate_stuff(sample);
	sample[0] = 0x36ED;
	sample[1] = 0x3640;
	calculate_stuff(sample);
	sample[0] = 0x3596;
	sample[1] = 0x34EC;
	calculate_stuff(sample);
	sample[0] = 0x3444;
	sample[1] = 0x33AA;
	calculate_stuff(sample);
	sample[0] = 0x330E;
	sample[1] = 0x3277;
	calculate_stuff(sample);
	sample[0] = 0x31E9;
	sample[1] = 0x3156;
	calculate_stuff(sample);
	sample[0] = 0x30CB;
	sample[1] = 0x3046;
	calculate_stuff(sample);
	sample[0] = 0x2FC0;
	sample[1] = 0x2F41;
	calculate_stuff(sample);
	sample[0] = 0x2EC0;
	sample[1] = 0x2E49;
	calculate_stuff(sample);
	sample[0] = 0x2DD2;
	sample[1] = 0x2D5D;
	calculate_stuff(sample);
	sample[0] = 0x2CED;
	sample[1] = 0x2C84;
	calculate_stuff(sample);
	sample[0] = 0x2C1A;
	sample[1] = 0x2BB2;
	calculate_stuff(sample);
	sample[0] = 0x2B4D;
	sample[1] = 0x2AEC;
	calculate_stuff(sample);
	sample[0] = 0x2A8B;
	sample[1] = 0x2A2E;
	calculate_stuff(sample);
	sample[0] = 0x29D1;
	sample[1] = 0x2976;
	calculate_stuff(sample);
	sample[0] = 0x291D;
	sample[1] = 0x28C5;
	calculate_stuff(sample);
	sample[0] = 0x2872;
	sample[1] = 0x281F;
	calculate_stuff(sample);
	sample[0] = 0x27CE;
	sample[1] = 0x2780;
	calculate_stuff(sample);
	sample[0] = 0x2732;
	sample[1] = 0x26E4;
	calculate_stuff(sample);
	sample[0] = 0x2696;
	sample[1] = 0x264F;
	calculate_stuff(sample);
	sample[0] = 0x2604;
	sample[1] = 0x25BF;
	calculate_stuff(sample);
	sample[0] = 0x257A;
	sample[1] = 0x2539;
	calculate_stuff(sample);
	sample[0] = 0x24F6;
	sample[1] = 0x24BA;
	calculate_stuff(sample);
	sample[0] = 0x247E;
	sample[1] = 0x2445;
	calculate_stuff(sample);
	sample[0] = 0x240E;
	sample[1] = 0x23D6;
	calculate_stuff(sample);
	sample[0] = 0x23A1;
	sample[1] = 0x236A;
	calculate_stuff(sample);
	sample[0] = 0x2335;
	sample[1] = 0x2300;
	calculate_stuff(sample);
	sample[0] = 0x22C9;
	sample[1] = 0x2293;
	calculate_stuff(sample);
	sample[0] = 0x225D;
	sample[1] = 0x2227;
	calculate_stuff(sample);
	sample[0] = 0x21F1;
	sample[1] = 0x21BA;
	calculate_stuff(sample);
	sample[0] = 0x2186;
	sample[1] = 0x2154;
	calculate_stuff(sample);
	sample[0] = 0x2121;
	sample[1] = 0x20F0;
	calculate_stuff(sample);
	sample[0] = 0x20BD;
	sample[1] = 0x208C;
	calculate_stuff(sample);
	sample[0] = 0x205D;
	sample[1] = 0x2031;
	calculate_stuff(sample);
	sample[0] = 0x2003;
	sample[1] = 0x1FD4;
	calculate_stuff(sample);
	sample[0] = 0x1FA8;
	sample[1] = 0x1F7D;
	calculate_stuff(sample);
	sample[0] = 0x1F51;
	sample[1] = 0x1F24;
	calculate_stuff(sample);
	sample[0] = 0x1EFD;
	sample[1] = 0x1ED6;
	calculate_stuff(sample);
	sample[0] = 0x1EB0;
	sample[1] = 0x1E89;
	calculate_stuff(sample);
	sample[0] = 0x1E65;
	sample[1] = 0x1E40;
	calculate_stuff(sample);
	sample[0] = 0x1E1C;
	sample[1] = 0x1DFD;
	calculate_stuff(sample);
	sample[0] = 0x1DDD;
	sample[1] = 0x1DBB;
	calculate_stuff(sample);
	sample[0] = 0x1D95;
	sample[1] = 0x1D74;
	calculate_stuff(sample);
	sample[0] = 0x1D53;
	sample[1] = 0x1D34;
	calculate_stuff(sample);
	sample[0] = 0x1D13;
	sample[1] = 0x1CF1;
	calculate_stuff(sample);
	sample[0] = 0x1CD2;
	sample[1] = 0x1CB1;
	calculate_stuff(sample);
	sample[0] = 0x1C96;
	sample[1] = 0x1C7A;
	calculate_stuff(sample);
	sample[0] = 0x1C5B;
	sample[1] = 0x1C3C;
	calculate_stuff(sample);
	sample[0] = 0x1C21;
	sample[1] = 0x1C05;
	calculate_stuff(sample);
	sample[0] = 0x1BE9;
	sample[1] = 0x1BCD;
	calculate_stuff(sample);
	sample[0] = 0x1BB3;
	sample[1] = 0x1B97;
	calculate_stuff(sample);
	sample[0] = 0x1B79;
	sample[1] = 0x1B5F;
	calculate_stuff(sample);
	sample[0] = 0x1B48;
	sample[1] = 0x1B2E;
	calculate_stuff(sample);
	sample[0] = 0x1B12;
	sample[1] = 0x1AF7;
	calculate_stuff(sample);
	sample[0] = 0x1ADF;
	sample[1] = 0x1AC6;
	calculate_stuff(sample);
	sample[0] = 0x1AAF;
	sample[1] = 0x1A95;
	calculate_stuff(sample);
	sample[0] = 0x1A79;
	sample[1] = 0x1A5F;
	calculate_stuff(sample);
	sample[0] = 0x1A49;
	sample[1] = 0x1A36;
	calculate_stuff(sample);
	sample[0] = 0x1A1E;
	sample[1] = 0x1A01;
	calculate_stuff(sample);
	sample[0] = 0x19EA;
	sample[1] = 0x19D6;
	calculate_stuff(sample);
	sample[0] = 0x19A9;
	sample[1] = 0x1992;
	calculate_stuff(sample);
	sample[0] = 0x1966;
	sample[1] = 0x1952;
	calculate_stuff(sample);
	sample[0] = 0x1927;
	sample[1] = 0x1911;
	calculate_stuff(sample);
	sample[0] = 0x18EA;
	sample[1] = 0x18D5;
	calculate_stuff(sample);
	sample[0] = 0x18AD;
	sample[1] = 0x189B;
	calculate_stuff(sample);
	sample[0] = 0x1872;
	sample[1] = 0x1861;
	calculate_stuff(sample);
	sample[0] = 0x183B;
	sample[1] = 0x182A;
	calculate_stuff(sample);
	sample[0] = 0x1808;
	sample[1] = 0x17F4;
	calculate_stuff(sample);
	sample[0] = 0x17D6;
	sample[1] = 0x17C5;
	calculate_stuff(sample);
	sample[0] = 0x17A3;
	sample[1] = 0x1794;
	calculate_stuff(sample);
	sample[0] = 0x1774;
	sample[1] = 0x1764;
	calculate_stuff(sample);
	sample[0] = 0x1746;
	sample[1] = 0x1736;
	calculate_stuff(sample);
	sample[0] = 0x1719;
	sample[1] = 0x170A;
	calculate_stuff(sample);
	sample[0] = 0x16ED;
	sample[1] = 0x16DF;
	calculate_stuff(sample);
	sample[0] = 0x16C3;
	sample[1] = 0x16B5;
	calculate_stuff(sample);
	sample[0] = 0x1698;
	sample[1] = 0x168B;
	calculate_stuff(sample);
	sample[0] = 0x1671;
	sample[1] = 0x1662;
	calculate_stuff(sample);
	sample[0] = 0x164A;
	sample[1] = 0x163C;
	calculate_stuff(sample);
	sample[0] = 0x1622;
	sample[1] = 0x1618;
	calculate_stuff(sample);
	sample[0] = 0x15FE;
	sample[1] = 0x15F2;
	calculate_stuff(sample);
	sample[0] = 0x15DC;
	sample[1] = 0x15CD;
	calculate_stuff(sample);
	sample[0] = 0x15B6;
	sample[1] = 0x15AC;
	calculate_stuff(sample);
	sample[0] = 0x1595;
	sample[1] = 0x158A;
	calculate_stuff(sample);
	sample[0] = 0x1577;
	sample[1] = 0x1569;
	calculate_stuff(sample);
	sample[0] = 0x1553;
	sample[1] = 0x154A;
	calculate_stuff(sample);
	sample[0] = 0x1533;
	sample[1] = 0x152A;
	calculate_stuff(sample);
	sample[0] = 0x1515;
	sample[1] = 0x1509;
	calculate_stuff(sample);
	sample[0] = 0x14F9;
	sample[1] = 0x14EF;
	calculate_stuff(sample);
	sample[0] = 0x14DB;
	sample[1] = 0x14D2;
	calculate_stuff(sample);
	sample[0] = 0x14BD;
	sample[1] = 0x14B6;
	calculate_stuff(sample);
	sample[0] = 0x14A4;
	sample[1] = 0x149A;
	calculate_stuff(sample);
	sample[0] = 0x1487;
	sample[1] = 0x147F;
	calculate_stuff(sample);
	sample[0] = 0x146B;
	sample[1] = 0x146B;
	calculate_stuff(sample);
	sample[0] = 0x1462;
	sample[1] = 0x1457;
	calculate_stuff(sample);
	sample[0] = 0x1452;
	sample[1] = 0x144E;
	calculate_stuff(sample);
	sample[0] = 0x1444;
	sample[1] = 0x1440;
	calculate_stuff(sample);
	sample[0] = 0x143E;
	sample[1] = 0x143D;
	calculate_stuff(sample);
	sample[0] = 0x144D;
	sample[1] = 0x1456;
	calculate_stuff(sample);

	return;
}

void calculate_stuff(unsigned long sample[])
{
	float enginerpm;
	float enginerpm2;
	float drumrpm;
	float drumrpm2;
	float rpm;
	float rpm_gain;
	float angular_velocity;
	float engine_rads;
	float drum_rads;
	float gain_rads;
	float angular_acceleration;
	float torque;
	float ftlbs;
	//float nm;
	float kgm;
	float power;
	float kilowatts;
	float horsepower;
	signed int difference;
	float microseconds_to_seconds;
	//const int diameter = 460; 	// diameter of drum, not used in any calculations
	//const int radius = (diameter/2); 	// same as above, not used
	const float _MOI_ = (float)(11.83); 	// Moment of Inertia of the drum. 11.83kg/m^2
	const unsigned int _PULSES_PER_REV_ = 4; 	// Sensor wheel has 4 teeth, 1 pulse indicates a 1/4 revolution

	//printf("Moment of Inertia (MOI): %f\nSamples per Revolution: %i\n",_MOI_,_PULSES_PER_REV_);

	if (sample[1] > sample[0])
		difference = (sample[1] - sample[0]); // if sample1 is 25000 micros and sample0 is 24000 micros, difference is 1000micros. the change in time
	else
		difference = (sample[0] - sample[1]); // so not a negative figure

	microseconds_to_seconds = (float)(difference / 1000000.); // divide by "/1000000" to convert microseconds to seconds, so we can this to measure the change in time with the angular acceleration math (radians per second / seconds)

	drumrpm = (float)(60000. / ((sample[0] / 1000.) * _PULSES_PER_REV_)); // convert sample0 to drumrpm
	drumrpm2 = (float)(60000. / ((sample[1] / 1000.) * _PULSES_PER_REV_)); // convert sample1 to drumrpm

	enginerpm = (float)(drumrpm * _gear_ratio_); // convert drum rpm to engine rpm using a known gear ratio (engine:drum rpm)
	enginerpm2 = (float)(drumrpm2 * _gear_ratio_);

	rpm = (float)drumrpm; // do we use drum rpm or engine rpm for our power/torque calculations?

	rpm_gain = (float)(drumrpm2 - drumrpm); // rpm gained between the 2 samples in that set

	// Angular Velocity: (RPM)/60 * 2Pi = Rad/s or (2000rpm / 60 = 33.33rps * 2PRad = 209 Rad/s)
	// We convert RPM to Rad/s

	drum_rads = (float)((drumrpm/60.) * (2.*M_PI)); // convert RPM to radians per second
	engine_rads = (float)((enginerpm/60.) * (2.*M_PI));
	gain_rads = (float)((rpm_gain/60.) * (2.*M_PI)); // rads measured between the first and second sample of the set

	angular_velocity = (float)drum_rads; // do we use drum rads or engine rads for our torque/power calculations

	/*
	a = Dw / Dt     Angular acceleration (a) equals change in angular velocity (w) per change in time.

	angular_acceleration = (angular_velocity / ?) ? being in microseconds between samples

	For the formula to work, the acceleration has to be in radians/second/second. (rad/sec2). There are 2Prads in one revolution.

	Angular velocity (w) is simply how quickly something turns, like RPM, or Revolutions per Minute.
	To keep the units consistent, you want to use radians per second (1 revolution = 6.28 radians (2P) before you plug it into any calculation,
	but it's easier to think of RPM. If you go from say, 5,000 rpm to 10,000 rpm in five seconds, the Angular Acceleration is 1,000 rpm per second.
	My front-end program only works in rads/sec, then I convert these to rpm's where needed.
	*/

	// 90% sure the problem is the below line, I think 'microseconds_to_seconds' needs to be converted to a SI unit

	angular_acceleration = (float)(angular_velocity / gain_rads);

	printf("angular acceleration: %f	drum rads: %f	bike rads: %f	microseconds: %f\n", angular_acceleration, drum_rads, engine_rads, microseconds_to_seconds );

	/*
	The relationship for rotational motion is; Torque (t) = Rotational Inertia (I) times Angular acceleration (a)
	t = I * a

	torque = (_MOI_ * angular_acceleration)
	*/
	torque = (float)(_MOI_ * angular_acceleration); // MOI = motion of inertia, we know the drum is 11.83 as defined in config.h

	ftlbs = (float)(torque / 1.35581794833);

	kgm = (float)(torque / 9.81);

	// P = t * w (Power = torque * angular velocity).
	power = (float)(torque * angular_velocity);

	// Horsepower = (Torque * RPM)/5252

	horsepower = (float)((ftlbs * rpm) / 5252.);

	// Kilowatts = (Torque * RPM) / 9549

	kilowatts = (float)((torque * rpm) / 9549.);

	printf("rpm: %f\n torque: %f\n  torque(ft-lbs): %f\n  torque(kgm): %f\n power: %f\n  power(hp): %f\n  power(kw): %f\ndifference (microseconds): %u\n drum rads: %f\n bike rads: %f\n gained rads: %f\nrpm gain (rpm): %f\n--------------------------------------------------\n", rpm*_gear_ratio_, torque, ftlbs, kgm, power, horsepower, kilowatts, difference, drum_rads, engine_rads, gain_rads, rpm_gain*_gear_ratio_ );

	return;
}