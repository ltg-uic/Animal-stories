//
//  CaptureRecord.m
//  as_test
//
//  Created by Tia Shelley on 2/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "CaptureRecord.h"
#import "Tag.h"

@implementation CaptureRecord
@synthesize pathNames = _pathNames;
@synthesize imgSet = _imgSet;
@synthesize scientist = _scientist;
@synthesize tagData = _tagData;

-(CaptureRecord*)  initWithPathName: (NSString *) pathName identifier:(int) imgSet author:(NSString *) scientist {
    _pathNames = [_pathNames initWithObjects: pathName, nil];
    _imgSet = imgSet;
    _scientist = [_scientist initWithString: scientist];
    _tagData = [[NSMutableArray alloc] init];
    return self;
}

- (void) addTag: (Tag *) newTag{
    [_tagData addObject: newTag];
}

@end
