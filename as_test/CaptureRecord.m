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

SDWebImageDownloader *downloader;

-(CaptureRecord*)  initWithPathName: (NSString *) pathName identifier:(int) imgSet author:(NSString *) scientist atTime: (NSDate *) dateTime{
    pathName = [pathName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SDWebImageDownloader.sharedDownloader
     downloadImageWithURL:[NSURL URLWithString:pathName]
     options:0
     progress:^(NSUInteger receivedSize, long long expectedSize){
        // NSLog(@"Img Set: %d %d / %llu", imgSet, receivedSize, expectedSize);
     }
     completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
         //NSLog(@"%@", error);
         if(image){
             _pathNames = [[NSMutableArray alloc] initWithObjects: image, nil];
         }
     }];
  //  UIImage *firstImage = [[UIImage alloc] initWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:pathName]]];
 //   _pathNames = [[NSMutableArray alloc] initWithObjects: firstImage, nil];
//    UIImage *firstImage = setImageFromURL
    _imgSet = imgSet;
    _scientist = [ [NSString alloc] initWithString: scientist];
    _tagData = [[NSMutableArray alloc] init];
    _firstImageTime = dateTime;
    return self;
}

- (Tag *) addTag: (Tag *) newTag{
    [_tagData addObject: newTag];
    return newTag;
}

-(void) removeTag: (Tag *) deletedTag{
    [_tagData removeObject: deletedTag];
}

- (void) addPathName: (NSString *) pathName{
    pathName = [pathName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //    UIImage *nextImage = [[UIImage alloc] initWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:pathName]]];
    [SDWebImageDownloader.sharedDownloader
     downloadImageWithURL:[NSURL URLWithString:pathName]
     options:0
     progress:^(NSUInteger receivedSize, long long expectedSize){
        // NSLog(@"%d", receivedSize);
     }
     completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
         if(image) [_pathNames addObject:image];
     }];
    
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
        if ([[tag tagText] isEqual: @"Untagged "]) return YES;
    }
    return NO;
}

- (void) print{
    NSLog(@"PathNames: %@ \n imgSet: %d \n Scientist: %@ \n Tag Count: %d \n \n", _pathNames, _imgSet, _scientist, [_tagData count]);
}

- (void) updateDB : (NSURL *) server{
    NSString *stringText = [NSString stringWithFormat:@"deleteTagData.php?imgSetID=%d", _imgSet];
    NSString *addLabelData = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", addLabelData);
    for( Tag* tag in _tagData){
        NSString *stringText = [NSString stringWithFormat:@"insertTagData.php?imgSetID=%d&tag=%@&x=%f&y=%f", _imgSet, tag.uiTag.text, tag.uiTag.center.x, tag.uiTag.center.y];
        NSString *addLabelData = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@", addLabelData);
    }
    
}

@end
