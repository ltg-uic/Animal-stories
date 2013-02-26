//
//  SecondViewController.m
//  as_test
//
//  Created by Tia Shelley on 1/16/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "AnalyzeViewController.h"
#import "CaptureRecord.h"

@interface AnalyzeViewController ()

@end


@implementation AnalyzeViewController
@synthesize captureRecords = _captureRecords;
@synthesize tableData = _tableData;
@synthesize currentImage = _currentImage;
@synthesize begin = _begin;
@synthesize end = _end;

-(AnalyzeViewController *) init{
    _captureRecords = [[NSMutableDictionary alloc] init];
    _tableData = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{

    NSInteger yDist = (CGRectGetHeight([self.view frame]) - 300)/([_tableData count] + 1);
    int totals[[_tableData count] +1];
    for (int i = 0; i < [_tableData count] + 1 ; i++){
        totals[i] = 0;
        UILabel *blackLine = [[UILabel alloc] initWithFrame:CGRectMake(105, 316 + (yDist * i), 814, 3)];
        blackLine.backgroundColor = [UIColor blackColor];
        [self.view addSubview:blackLine];
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(30, 300 + (yDist * i), 100, 30 )];
        //NSLog(@"%f", (CGRectGetMaxY(self.currentImage.frame) + (yDist * i)) );
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        if( i == [_tableData count]){
            label.text = @"No Tags";
        } else  label.text = [_tableData objectAtIndex:i];
        [self.view addSubview:label];
    }
    for(CaptureRecord* record in _captureRecords){
        if ([[[_captureRecords objectForKey:record] tagData] count] == 0){
            totals[[_tableData count]]++;
            UIImageView *circle =[[UIImageView alloc] initWithImage:[UIImage imageNamed: @"unsorted.png"]];
            circle.center = CGPointMake([self mapTimeToDisplay: [[_captureRecords objectForKey:record] firstImageTime]  withBeginTime:_begin withEndTime: _end beginX:105 width:814], 316 + (yDist * [_tableData count] + 1));
            [self.view addSubview: circle];
        } else {
            for( Tag * tag in [[_captureRecords objectForKey:record] tagData]){
                for (int i = 0; i < [_tableData count]; i++){
                    UIImageView *circle;
                    if([[[tag uiTag] text] isEqual: [_tableData objectAtIndex:i]]){
                        circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"sorted.png"]];
                        circle.center = CGPointMake([self mapTimeToDisplay: [[_captureRecords objectForKey:record] firstImageTime]  withBeginTime:_begin withEndTime: _end beginX:105 width:814], 316 + (yDist * i));
                        [self.view addSubview: circle];
                        totals[i]++;
                        
                    }
                }
            }
        }
        
    }
    for(int i= 0; i <[_tableData count] + 1; i++){
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(930, 300 + (yDist * i), 100, 30 )];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = [[NSString alloc] initWithFormat:@"%d", totals[i]];
        [self.view addSubview:label];
    }
    
}

- (void)printData {
    NSLog(@"%@", self.captureRecords);
    for (CaptureRecord *record in self.captureRecords){
        [[self.captureRecords objectForKey: record] print];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int) mapTimeToDisplay : (NSDate *) imageTime withBeginTime : (NSDate *) begin withEndTime : (NSDate *) end beginX : (int) x width : (int) w{
    NSTimeInterval totalTime = [end timeIntervalSinceDate:begin];
    NSTimeInterval currentTimeDistance = [imageTime timeIntervalSinceDate:begin];
    return x + ( w * currentTimeDistance/totalTime );
}

@end
