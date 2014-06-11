//
//  LocalSunRise.m
//  testMutationsTDD
//
//  Created by Schwietering, Jürgen on 09.05.14.
//  Copyright (c) 2014 Jürgen Schwietering. All rights reserved.
//

#import "LocalSunRise.h"




double calcDayOfYear(int year, int month, int day) // month 1..12 - original (obscure) function
{
	double N1 = floor(275 * month / 9);
	double N2 = floor((month + 9) / 12);
	double N3 = (1 + floor((year - 4 * floor(year / 4) + 2) / 3));
	return N1 - (N2 * N3) + day - 30;
}

double torusValue(double in, double min, double max)
{
	if (in < min)
		return in+(max-min);
	if (in > max)
		return in-(max-min);
	return in;
}

double rad(double deg)
{
    return deg*M_PI/180.0;
}

double deg(double rad)
{
    return rad*180.0/M_PI;
}

@implementation LocalSunRise


- (BOOL)isLeapYear:(int)year
{
    if ((year %   4) != 0) { return NO; }
    if ((year % 400) == 0) { return YES; }
    if ((year % 100) == 0) { return NO; }
    return true;
}

- (int)dayOfYear:(int)year month:(int)month  day:(int) day
{
    int startDayOfMonth[12] = {0,31,59,90,120,151,181,212,243,273,304,334 };
    bool leap = false;
    if (month > 2)
    {
        leap = [self isLeapYear:year];
    }
    return startDayOfMonth[month - 1] + day + (leap?1:0);
}

int calculate(SUNUPORDOWN rising, int year, int month, int day, double latitude, double longitude, double zenith, double localOffset)
{

	double N = calcDayOfYear(year, month, day);	// first calculate the day of the year

	double lngHour = longitude / 15.0;			// convert the longitude to hour value
	double t;

	if (rising==SUNRISE ) {
        t = N + (( 6.0 - lngHour) / 24.0);
    } else {
        t = N + ((18.0 - lngHour) / 24.0);
    }	// calculate an approximate time

	double M = (0.9856 * t) - 3.289;			// calculate the Sun's mean anomaly

	double L = M + (1.916 * sin(rad(M))) + (0.020 * sin(2.0 * rad(M))) + 282.634;		// calculate the Sun's true longitude
    //	NOTE: L potentially needs to be adjusted into the range [0,360.0) by adding:subtracting 360.0
	L = torusValue(L,0,360.0);

	double RA = deg(atan(0.91764 * tan(rad(L))));	// calculate the Sun's right ascension
    //	NOTE: RA potentially needs to be adjusted into the range [0,360.0) by adding:subtracting 360.0
    RA = torusValue(RA,0,360.0);

	int Lquadrant  = (floor( L/90)) * 90.0;	// right ascension value needs to be in the same quadrant as L
	int RAquadrant = (floor(RA/90)) * 90.0;
	RA = RA + (Lquadrant - RAquadrant);

	RA = RA / 15.0;							// right ascension value needs to be converted into hours

	double sinDec = 0.39782 * sin(rad(L));	// calculate the Sun's declination
	double cosDec = cos(asin(sinDec));

	double cosH = (cos(rad(zenith)) - (sinDec * sin(rad(latitude)))) / (cosDec * cos(rad(latitude)));	// calculate the Sun's local hour angle

	if (cosH >  1.0) { return -1; }
	if (cosH < -1.0) { return -1; }

	double H;									// finish calculating H and convert into hours
	if (rising==SUNRISE)
    {
        H = 360.0 - deg(acos(cosH));
    }
    else
    {
        H = deg(acos(cosH));
    }

	H /= 15.0;

    double T = H + RA - (0.06571 * t) - 6.622;	// calculate local mean time of rising:setting

    double UT = T - lngHour;					// adjust back to UTC
	UT = torusValue(UT,0,24.0);


    // YAGNI?
	double LT = UT + localOffset;				// convert UT value to local time zone of latitude:longitude
	LT = torusValue(LT,0,24.0);

    int numSec = (int)(LT*60.0*60.0+0.5);
    return numSec;
    
}

- (int)calculateSunrise:(NSDate*)date
               location:(CLLocationCoordinate2D)location
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];

    return calculate(SUNRISE, [components year], [components month], [components day], location.latitude, location.longitude, 90.833333, 0.0);
}

@end
