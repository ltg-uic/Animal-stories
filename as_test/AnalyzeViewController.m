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
@property (strong, nonatomic) NSMutableDictionary *dataPoints;
@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSMutableArray *lines;
@property (strong, nonatomic) NSMutableArray *totals;
@end


@implementation AnalyzeViewController
@synthesize captureRecords = _captureRecords;
@synthesize tableData = _tableData;
@synthesize currentImage = _currentImage;
@synthesize begin = _begin;
@synthesize end = _end;
@synthesize dataPoints = _dataPoints;
@synthesize labels = _labels;
@synthesize lines = _lines;
@synthesize totals = _totals;
@synthesize tap = _tap;
@synthesize timeLineContainer = _timeLineContainer;

-(AnalyzeViewController *) init{
    _captureRecords = [[NSMutableDictionary alloc] init];
    _tableData = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataPoints = [[NSMutableDictionary alloc] init];
    _labels = [[NSMutableArray alloc] init];
    _lines = [[NSMutableArray alloc] init];
    _totals = [[NSMutableArray alloc] init];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"%@", _dataPoints);
    //clear last visualization
    for( NSString *view in _dataPoints){
        [[_dataPoints objectForKey:view ] removeFromSuperview];
    }
    for(UILabel *label in _labels){
        [label removeFromSuperview];
    }
    for(UILabel *line in _lines){
        [line removeFromSuperview];
    }
    for(UILabel *total in _totals){
        [total removeFromSuperview];
    }
    [_dataPoints removeAllObjects];
    [_labels removeAllObjects];
    [_lines removeAllObjects];
    [_totals removeAllObjects];
    NSLog(@"%@", _dataPoints);
    
    
    //NSInteger yDist = (CGRectGetHeight([self.view frame]) - 300)/([_tableData count] + 1);
    NSInteger yDist = 50;
    int totals[[_tableData count] +1];
    for (int i = 0; i < [_tableData count] + 1 ; i++){
        totals[i] = 0;
        UILabel *blackLine = [[UILabel alloc] initWithFrame:CGRectMake(105, 15 + (yDist * i), 814, 3)];
        blackLine.backgroundColor = [UIColor blackColor];
        [self.timeLineContainer addSubview:blackLine];
        [_lines addObject: blackLine];
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(30, (yDist * i), 100, 30 )];
        //NSLog(@"%f", (CGRectGetMaxY(self.currentImage.frame) + (yDist * i)) );
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        if( i == [_tableData count]){
            label.text = @"No Tags";
        } else  label.text = [_tableData objectAtIndex:i];
        [self.timeLineContainer addSubview:label];
        [_labels addObject:label];
    }
    for(NSString* record in _captureRecords){
        if ([[[_captureRecords objectForKey:record] tagData] count] == 0){
            totals[[_tableData count]]++;
            UIImageView *circle =[[UIImageView alloc] initWithImage:[UIImage imageNamed: @"unsorted.png"]];
            circle.center = CGPointMake([self mapTimeToDisplay: [[_captureRecords objectForKey:record] firstImageTime]  withBeginTime:_begin withEndTime: _end beginX:105 width:814], 15 + (yDist * [_tableData count] + 1));
            [self.timeLineContainer addSubview: circle];
            [_dataPoints setValue:circle forKey: record];
        } else {
            for( Tag * tag in [[_captureRecords objectForKey:record] tagData]){
                for (int i = 0; i < [_tableData count]; i++){
                    UIImageView *circle;
                    if([[[tag uiTag] text] isEqual: [_tableData objectAtIndex:i]]){
                        circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"sorted.png"]];
                        circle.center = CGPointMake([self mapTimeToDisplay: [[_captureRecords objectForKey:record] firstImageTime]  withBeginTime:_begin withEndTime: _end beginX:105 width:814], 15 + (yDist * i));
                        [self.timeLineContainer addSubview: circle];
                        [_dataPoints setValue:circle forKey: record];
                        totals[i]++;
                        //NSLog(@"%d, %d, %@, %@ \n", i, totals[i], [[tag uiTag] text], [_captureRecords objectForKey:record]);
                        
                    }
                }
            }
        }
        
    }
    for(int i= 0; i <[_tableData count] + 1; i++){
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(930, (yDist * i), 100, 30 )];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = [[NSString alloc] initWithFormat:@"%d", totals[i]];
        [self.timeLineContainer addSubview:label];
        [_totals addObject:label];
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

- (IBAction)tapAction:(UITapGestureRecognizer *)tapInstance {
    CGPoint tapLocation = [tapInstance locationInView:tapInstance.view];
    NSLog(@"tapView: %@" , tapInstance.view);
    for(NSString *circleRecord in _dataPoints){
        if(CGRectContainsPoint([[_dataPoints objectForKey:circleRecord] frame], tapLocation)){
            
            self.currentImage.animationImages = [[self.captureRecords objectForKey:circleRecord] pathNames];
            self.currentImage.animationDuration = 6;
            [self.currentImage startAnimating];
            
        }
    }
    
}

@end
