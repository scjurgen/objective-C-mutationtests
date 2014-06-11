//
//  LocalSunRise.m
//  testMutationsTDD
//
//  Created by Schwietering, Jürgen on 09.05.14.
//  Copyright (c) 2014 Jürgen Schwietering. All rights reserved.
//

/*
 
 xcodebuild test -scheme testMutationsTDD -destination "name=iPhone Retina (4-inch)"

 */


#import <XCTest/XCTest.h>
#import "LocalSunRise.h"

static CLLocationCoordinate2D berlinLocation       = {+52.5166667,  +13.3833333};
static CLLocationCoordinate2D sydneyLocation       = {-33.8678500, +151.2073200};
static CLLocationCoordinate2D longyearbyenLocation = {+78.2186000,  +15.6400700};
static CLLocationCoordinate2D riodejaneiroLocation = {-22.9027800,  -43.2075000};
static CLLocationCoordinate2D habanaLocation       = {+23.1330200,  -82.3830400};

static CLLocationCoordinate2D northPoleLocation = {+90.0,0.0};
static CLLocationCoordinate2D southPoleLocation = {-90.0,0.0};



#define January_01_2014 (1388534400)
#define March_24_2014 (1332547200)
#define March_25_2014 (1332633600)

@interface LocalSunRiseUnitTests : XCTestCase
{
    LocalSunRise *sr;
}

@end

@implementation LocalSunRiseUnitTests

- (void)setUp
{
    [super setUp];
    sr = [[LocalSunRise alloc] init];
}

- (void)tearDown
{
    sr = nil;
    [super tearDown];
}


- (void)testTorusValue_PositiveOver_inRange
{
    XCTAssertEqual(6.0,torusValue(366, 0.0, 360.0));
    XCTAssertEqual(12.0,torusValue(372, 6.0, 366.0));
}

- (void)testTorusValue_NegativeUnder_inRange
{
    XCTAssertEqual(6.0,torusValue(-18.0, 0.0, 24.0));
}


- (void)testDayOfYear_lastOfLeapYearWith366_366
{
    XCTAssertEqual(366, calcDayOfYear(2004,12,31));
    XCTAssertEqual(366, calcDayOfYear(2012,12,31));
    XCTAssertEqual(366, calcDayOfYear(2000,12,31));
}

- (void)testDayOfYear_lastOfYearWith365_365
{
    XCTAssertEqual(365, calcDayOfYear(2011,12,31));
    XCTAssertEqual(365, calcDayOfYear(2013,12,31));
    XCTAssertEqual(365, calcDayOfYear(2014,12,31));
}

- (void)testSunrise_FirstOfJanuary2014NorthPole_invalid
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:January_01_2014];
    int sunrise = [sr calculateSunrise:date location:northPoleLocation];
    int expectedTime = -1;
    XCTAssertEqualWithAccuracy(sunrise/60.0, expectedTime, 1, @"Sunrise time is wrong");
}

- (void)testSunrise_FirstOfJanuary2014Berlin_0817
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:January_01_2014];
    int sunrise = [sr calculateSunrise:date location:berlinLocation];
    int expectedTime = 7*60+17;
    XCTAssertEqualWithAccuracy(sunrise/60.0, expectedTime, 1, @"Sunrise time is wrong");
}

- (void)testSunrise_24OfMarch2012Berlin_0459
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:March_24_2014];
    int sunrise = [sr calculateSunrise:date location:berlinLocation];
    int expectedTime = 4*60+59;
    XCTAssertEqualWithAccuracy(sunrise/60.0, expectedTime, 1, @"Sunrise time is wrong");
}

- (void)testSunrise_25OfMarch2012Berlin_0457
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:March_25_2014];
    int sunrise = [sr calculateSunrise:date location:berlinLocation];
    int expectedTime = 4*60+57;
    XCTAssertEqualWithAccuracy(sunrise/60.0, expectedTime, 1, @"Sunrise time is wrong");
}

@end
