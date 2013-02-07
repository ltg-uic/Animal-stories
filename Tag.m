//
//  Tag.m
//  as_test
//
//  Created by Tia Shelley on 2/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "Tag.h"

@implementation Tag
@synthesize imgSet = _imgSet;
@synthesize center = _center;
@synthesize labelText = _labelText;

-(Tag*) initWithCenter : (CGPoint) center withIdentifier: (int) imgSet withText: (NSString*) labelText{
    _imgSet = imgSet;
    _center = center;
    _labelText = [_labelText initWithString: labelText];
    return self;
}

-(void) moveTagToPosition: (CGPoint) center{
    _center = center;
}


@end
