//
//  SecondViewController.h
//  as_test
//
//  Created by Tia Shelley on 1/16/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineDrawingView.h"

@interface AnalyzeViewController : UIViewController <UIGestureRecognizerDelegate>
{
    NSMutableArray* tableData;
    NSMutableDictionary* captureRecords;
    IBOutlet UIImageView *currentImage;
    IBOutlet LineDrawingView *lineView;

}

@property (strong, nonatomic) NSMutableArray* tableData;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;
@property (strong, nonatomic) IBOutlet UIImageView *canvasForLines;
@property IBOutlet LineDrawingView *lineView;
@property (strong, nonatomic) NSMutableDictionary* captureRecords;
@property (strong, nonatomic)IBOutlet UIImageView *currentImage;
@property (strong, nonatomic) NSDate * begin;
@property (strong, nonatomic) NSDate * end;
@property (strong, nonatomic) IBOutlet UIScrollView *timeLineContainer;
@property NSFileHandle *file;


@end
