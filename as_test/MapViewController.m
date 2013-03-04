//
//  MapViewController.m
//  as_test
//
//  Created by Brenda on 2/28/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "MapViewController.h"

@implementation MapViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    //1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 41.8678;
    zoomLocation.longitude= -87.7966;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [__mapView regionThatFits:viewRegion];
    // 4
    [__mapView setRegion:adjustedRegion animated:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
