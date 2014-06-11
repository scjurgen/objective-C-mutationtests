//
//  LocalSunRise.h
//  testMutationsTDD
//
//  Created by Schwietering, Jürgen on 09.05.14.
//  Copyright (c) 2014 Jürgen Schwietering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    SUNRISE = 0,
    SUNSET = 1
} SUNUPORDOWN;

extern double calcDayOfYear(int year, int month, int day);
extern double torusValue(double in, double min, double max);

@interface LocalSunRise : NSObject

- (int)calculateSunrise:(NSDate*)date
               location:(CLLocationCoordinate2D)location;
@end
