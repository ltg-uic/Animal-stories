//
//  CaptureRecord.h
//  as_test
//
//  Created by Tia Shelley on 2/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"

@interface CaptureRecord : NSObject{

}
@property NSMutableArray *pathNames;
@property int imgSet;
@property NSString *scientist;
@property NSMutableArray *tagData;
@property NSDate *firstImageTime;


//  Creates a new record, using the imgSet as the identifier. After a new record is created, all following records with the same imgSet# are just additional pathNames, and so we use the "addPathName" method.

-(CaptureRecord*)  initWithPathName: (NSString *) pathName identifier:(int) imgSet author:(NSString *) scientist atTime: (NSDate *) dateTime;

- (void) addPathName: (NSString *) pathName;

//partnered methods that deal with the tags when the image switches
- (void) addTagsToView: (UIView *) view;
- (void) removeTagsFromView;

//adds a created Tag to the CaptureRecord
- (Tag *) addTag: (Tag *) newTag;

//removes a tag from the array (IE: the user deleted the tag
- (void) removeTag: (Tag *) deletedTag;

//specialized logging method that specifically prints the set of pathnames included, the imgSet identifier, the group that owns the images, and the number of tags present in the image.
- (void) print;
@end

