//
//  MapViewController.h
//  as_test
//
//  Created by Brenda on 2/28/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import <MapKit/MapKit.h>
#define METERS_PER_MILE 1609.344

@interface MapViewController : MKMapView

@property (weak, nonatomic) IBOutlet MKMapView *_mapView;

@end
