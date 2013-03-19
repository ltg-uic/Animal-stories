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

SDWebImageDownloader *downloader;

-(CaptureRecord*)  initWithPathName: (NSString *) pathName identifier:(int) imgSet author:(NSString *) scientist atTime: (NSDate *) dateTime withRecord: (int) recordNum notes: (NSString *) notes{
    pathName = [pathName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.urlArray = [[NSMutableArray alloc] initWithObjects: pathName, nil];
    _recordNumber = recordNum;
//    [SDWebImageDownloader.sharedDownloader
//     downloadImageWithURL:[NSURL URLWithString: pathName]
//     options:0
//     progress:^(NSUInteger receivedSize, long long expectedSize){
//         // NSLog(@"Img Set: %d %d / %llu", imgSet, receivedSize, expectedSize);
//     }
//     completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//         //NSLog(@"%@", error);
//         if(image){
//             _pathNames = [[NSMutableArray alloc] initWithObjects: image, nil];
//         }
//     }];
    //  UIImage *firstImage = [[UIImage alloc] initWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:pathName]]];
    //   _pathNames = [[NSMutableArray alloc] initWithObjects: firstImage, nil];
    //    UIImage *firstImage = setImageFromURL
    _imgSet = imgSet;
    _scientist = [ [NSString alloc] initWithString: scientist];
    _tagData = [[NSMutableArray alloc] init];
    _firstImageTime = dateTime;
    _notes = [notes mutableCopy];
    return self;
}

- (Tag *) addTag: (Tag *) newTag{
    for(Tag * tag2 in _tagData){
        if ([[[tag2 uiTag] text] isEqual: @"Untagged"]){
            [tag2 removeLabelFromView];
            [_tagData removeObject: tag2];
        }
    }
    [_tagData addObject: newTag];
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
    for (Tag * tag in _tagData){
        if ([tag.uiTag.text isEqualToString:tagName]){
            [_tagData removeObject: tag];
        }
    }
}

- (void) addPathName: (NSString *) pathName{
    pathName = [pathName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //    UIImage *nextImage = [[UIImage alloc] initWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:pathName]]];

    [self.urlArray addObject:pathName];
}

- (void) loadImages {
    _pathNames = [[NSMutableArray alloc] init];
    NSLog(@"Loading images for imgset: %d, %@", self.imgSet, self.urlArray);
    for (NSString *pathName in self.urlArray){
        [SDWebImageDownloader.sharedDownloader
         downloadImageWithURL:[NSURL URLWithString:pathName]
         options:0
         progress:^(NSUInteger receivedSize, long long expectedSize){
             // NSLog(@"%d", receivedSize);
         }
         completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
             if(image) {
             [_pathNames addObject:image];
             }
         }];
    }
    
}

- (void) removeImages {
    //NSLog(@"Removing images for imgset: %d", self.imgSet);
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
        if ([[tag tagText] isEqual: @"Untagged "]) return YES;
    }
    return NO;
}

- (void) print{
    NSLog(@"PathNames: %@ \n imgSet: %d \n Scientist: %@ \n Tag Count: %d \n \n", _pathNames, _imgSet, _scientist, [_tagData count]);
}

- (void) updateDB : (NSURL *) server{
    NSString *stringText = [NSString stringWithFormat:@"deleteTagData.php?imgSetID=%d", _imgSet];
    [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@", addLabelData);
    for( Tag* tag in _tagData){
        NSString *stringText = [NSString stringWithFormat:@"insertTagData.php?imgSetID=%d&tag=%@&x=%f&y=%f", _imgSet, tag.uiTag.text, tag.uiTag.frame.origin.x, tag.uiTag.frame.origin.y];
        [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"%@ \n, %@", stringText, addLabelData);
    }
    
}

@end
