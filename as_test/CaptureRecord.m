//
//  CaptureRecord.m
//  as_test
//
//  Created by Tia Shelley on 2/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "CaptureRecord.h"
#include "CoreGraphics/CoreGraphics.h"
#include "MapKit/MapKit.h"
#include "ImageIO/ImageIO.h"

#import "SDWebImage/SDWebImageDownloader.h"

@implementation CaptureRecord
@synthesize pathNames = _pathNames;
@synthesize imgSet = _imgSet;
@synthesize scientist = _scientist;
@synthesize tagData = _tagData;
@synthesize firstImageTime = _firstImageTime;
@synthesize notes = _notes;
@synthesize recordNumber = _recordNumber;
@synthesize urlArray = _urlArray;
@synthesize timeArray = _timeArray;

-(CaptureRecord*)  initWithPathName: (NSString *) pathName identifier:(int) imgSet author:(NSString *) scientist atTime: (NSDate *) dateTime withRecord: (int) recordNum notes: (NSString *) notes{
    pathName = [pathName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.urlArray = [[NSMutableArray alloc] initWithObjects: pathName, nil];
    _recordNumber = recordNum;
    _imgSet = imgSet;
    _scientist = [ [NSString alloc] initWithString: scientist];
    _tagData = [[NSMutableArray alloc] init];
    _firstImageTime = dateTime;
    _notes = [notes mutableCopy];
    _timeArray = [[NSMutableArray alloc] initWithObjects:dateTime, nil];
    return self;
}

- (Tag *) addTag: (Tag *) newTag{
    bool x = NO;
    for(Tag * tag2 in _tagData){
        if ([[[tag2 uiTag] text] isEqual: @"Unlabeled"]){
            [tag2 removeLabelFromView];
            [_tagData removeObject: tag2];
        }
        if ([[[tag2 uiTag ]text] isEqual: [[newTag uiTag] text]]){
            if ( CGPointEqualToPoint([[tag2 uiTag] center],[[newTag uiTag] center])){
                x = YES;
            }
        }
    }
    if(!x) [_tagData addObject: newTag];
    return newTag;
}

- (void) renameTag: (NSString *) oldTagName withTag: (NSString *) newTagName{
    for (Tag * tag in _tagData){
        if ([tag.uiTag.text isEqualToString:oldTagName]){
            tag.uiTag.text = newTagName;
        }
    }
}

-(void) removeTag: (Tag *) deletedTag{
    [_tagData removeObject: deletedTag];
}

- (void) removeTags: (NSString *) tagName{
    NSMutableArray *tagsToDelete = [[NSMutableArray alloc] init];
    for (Tag * tag in _tagData){
        if ([tag.uiTag.text isEqualToString:tagName]){
            [tagsToDelete addObject: tag];
        }
    }
    for(Tag * tag in tagsToDelete){
        [tag.uiTag removeFromSuperview];
        [_tagData removeObject: tag];
    }
}

- (void) addPathName: (NSString *) pathName atTime: (NSDate *) date{
    pathName = [pathName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.timeArray addObject: date];
    [self.urlArray addObject:pathName];
}

- (int) loadImages {
    NSLog(@"adding images for imgSet: %d", self.recordNumber);
    _pathNames = [[NSMutableArray alloc] init];
    int numberOfImages = 0;
    NSMutableArray *orderedArray = self.urlArray;
    if([[self.timeArray objectAtIndex:0] laterDate: [self.timeArray lastObject] ] == [self.timeArray objectAtIndex:0]){
        NSArray *reverseUrlArray = [[self.urlArray reverseObjectEnumerator] allObjects];
        orderedArray = [reverseUrlArray mutableCopy];
    }
    
    for (NSString *pathName in orderedArray){
        
        int index = [pathName rangeOfString:@"/" options: NSBackwardsSearch].location;
        NSString *fileName = [pathName substringFromIndex:index];
        NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        NSString  *filePath = [NSString stringWithFormat:@"%@%@", documentsDirectory,fileName];
        //NSLog(@"%@", filePath);
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath] ){
            //NSLog(@"File Does Not Already Exist");
            NSURL  *url = [NSURL URLWithString:pathName];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"%@%@", documentsDirectory, fileName);   
            }
        }
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if (image){
            [_pathNames addObject:image];
            numberOfImages++;
        }
    }
    return numberOfImages;
}

- (void) removeImages {
    NSLog(@"Removing images for imgset: %d", self.recordNumber);
    [self.pathNames removeAllObjects];
}

- (void) addTagsToView: (UIView *) view{
    for(Tag * tag in _tagData){
        [tag addLabelToView:view];
    }
    
}

- (void) removeTagsFromView{
    for(Tag * tag in _tagData){
        [tag removeLabelFromView];
    }
}

- (bool) isUntagged{
    for( Tag* tag in _tagData){
        if ([[tag tagText] isEqual: @"Unlabeled "]) return YES;
    }
    return NO;
}

- (void) print{
    NSLog(@"PathNames: %@ \n imgSet: %d \n Scientist: %@ \n Tag Count: %d \n \n", _pathNames, _imgSet, _scientist, [_tagData count]);
}

- (void) updateDB : (NSURL *) server view: (UIView *) view{
    NSString *stringText = [NSString stringWithFormat:@"deleteTagData.php?imgSetID=%d&scientist=%@", _imgSet, _scientist];
   [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"%@", addLabelData);
    NSMutableArray *tagsToDelete = [[NSMutableArray alloc] init];
    for( Tag* tag in _tagData){
        if(CGRectContainsPoint(view.frame, tag.uiTag.frame.origin)){
            NSString *content;
            while (!content){
                NSString *stringText = [NSString stringWithFormat:@"insertTagData.php?imgSetID=%d&tag=%@&x=%f&y=%f&scientist=%@", _imgSet, tag.uiTag.text, tag.uiTag.frame.origin.x, tag.uiTag.frame.origin.y, _scientist];
                content = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
            }
                //NSLog(@"%@ \n, %@", stringText, addLabelData);
        } else {
            [tagsToDelete addObject:tag];
        }
    }
    for (Tag *tag in tagsToDelete){
        [_tagData removeObject: tag];
    }
    
}


@end
