//
//  SecondViewController.m
//  as_test
//
//  Created by Tia Shelley on 1/16/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "AnalyzeViewController.h"
#import "CaptureRecord.h"
#import "REDRangeSlider.h"

@interface AnalyzeViewController ()
@property (strong, nonatomic) NSMutableDictionary *dataPoints;
@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSMutableArray *lines;
@property (strong, nonatomic) NSMutableArray *totals;
@property (strong, nonatomic) REDRangeSlider *timeSlider;
@property (strong, nonatomic) UILabel *beginLabel;
@property (strong, nonatomic) UILabel *endLabel;
@property (strong, nonatomic) UILabel *leftLabel;
@property (strong, nonatomic) UILabel *rightLabel;
@property UIBezierPath *leftLine;
@property UIBezierPath *rightLine;
@property UIImageView *highlight;
@property UIImage *sorted;
@property UIImage *unsorted;
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
@synthesize timeLineContainer = _timeLineContainer;
@synthesize timeSlider = _timeSlider;
@synthesize beginLabel = _beginLabel;
@synthesize endLabel = _endLabel;
@synthesize rightLabel = _rightLabel;
@synthesize leftLabel = _leftLabel;
@synthesize rightLine = _rightLine;
@synthesize leftLine = _leftLine;
@synthesize canvasForLines = _canvasForLines;
@synthesize lineView = _lineView;
@synthesize tap;
@synthesize highlight = _highlight;

NSInteger yDist = 30;


-(AnalyzeViewController *) init{
    _captureRecords = [[NSMutableDictionary alloc] init];
    _tableData = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDateFormatter* formattedDate = [[NSDateFormatter alloc] init];
    [formattedDate setDateFormat:@"MM/dd/yyyy HH:mm:ss Z"];
    [formattedDate setDateStyle: NSDateFormatterShortStyle];
    [formattedDate setTimeStyle: NSDateFormatterShortStyle];
    
    _dataPoints = [[NSMutableDictionary alloc] init];
    _labels = [[NSMutableArray alloc] init];
    _lines = [[NSMutableArray alloc] init];
    _totals = [[NSMutableArray alloc] init];
    
    _timeSlider = [[REDRangeSlider alloc] initWithFrame: CGRectMake(105, 650, 814, 20)];
    [_timeSlider addTarget:self action:@selector(rangeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    _timeSlider.maxValue = [_end timeIntervalSinceDate:_begin ];
    _timeSlider.minValue = 0;
    
    
    _beginLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 675, 120, 30)];
    _beginLabel.textColor = [UIColor blackColor];
    _beginLabel.backgroundColor = [UIColor clearColor];
    _beginLabel.font = [UIFont systemFontOfSize:12];
    _beginLabel.text = [formattedDate stringFromDate: _begin];
    [self.view addSubview:_beginLabel];
    
    _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(814, 675, 120, 30)];
    _endLabel.textColor = [UIColor blackColor];
    _endLabel.backgroundColor = [UIColor clearColor];
    _endLabel.font = [UIFont systemFontOfSize:12];
    _endLabel.text = [formattedDate stringFromDate:_end];
    [self.view addSubview:_endLabel];
    
    _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 635, 120, 30)];
    _leftLabel.textColor = [UIColor whiteColor];
    _leftLabel.backgroundColor = [UIColor clearColor];
    _leftLabel.font = [UIFont systemFontOfSize:12];
    _leftLabel.text = [formattedDate stringFromDate: _begin];
    [self.view addSubview:_leftLabel];
    
    _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(814, 635, 120, 30)];
    _rightLabel.textColor = [UIColor whiteColor];
    _rightLabel.backgroundColor = [UIColor clearColor];
    _rightLabel.font = [UIFont systemFontOfSize:12];
    _rightLabel.text = [formattedDate stringFromDate:_end];
    [self.view addSubview:_rightLabel];
    
    _lineView = [[LineDrawingView alloc] initWithFrame:CGRectMake(0,0, 1024, 768)];
    
    _lineView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_timeSlider];
    [self.view insertSubview:_lineView belowSubview:_timeSlider];
 
    [self.timeLineContainer setScrollEnabled:YES];
    self.timeLineContainer.showsVerticalScrollIndicator = YES;
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:self.tap];
    self.tap.delegate = self;
    NSLog(@"%@", self.timeLineContainer.gestureRecognizers);
    
    self.highlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"highlight2.png"]];
    self.highlight.center = CGPointMake(-100, 10000);
    [self.timeLineContainer addSubview: self.highlight];
    
    self.sorted = [UIImage imageNamed:@"sorted.png"];
    self.unsorted = [UIImage imageNamed:@"unsorted.png"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Received memory warning");
    int i = 0;
    for (NSString * record in _captureRecords){
        if(record != self.currentRecord && [[[self.captureRecords objectForKey:record] pathNames] count] > 0){
            [[self.captureRecords objectForKey: record] removeImages];
            i++;
        }
        if (i == 10) break;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    self.highlight.center = CGPointMake(-100, 10000);
    NSDateFormatter* formattedDate = [[NSDateFormatter alloc] init];
    [formattedDate setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSString *logData = [NSString stringWithFormat:@"\n%@ : Switched to the Analyze View", [formattedDate stringFromDate:[NSDate date]]];
    [self.file seekToEndOfFile];
    [self.file writeData: [logData dataUsingEncoding:NSUTF8StringEncoding]];

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
    [_tableData insertObject:@"Unlabeled" atIndex: 0];

    _leftLabel.center = CGPointMake(105, 315 + yDist * ([_tableData count] + 2));
    _rightLabel.center = CGPointMake(914, 315 + yDist * ( [_tableData count]+ 2));
    
    self.timeLineContainer.contentSize = CGSizeMake(900, yDist* ([_tableData count] + 4));
    int totals[[_tableData count] + 2];
    for (int i = 0; i < [_tableData count] + 1 ; i++){
        totals[i] = 0;
        UILabel *blackLine = [[UILabel alloc] initWithFrame:CGRectMake(105, 15 + (yDist * i), 814, 3)];
        blackLine.backgroundColor = [UIColor blackColor];
        [self.timeLineContainer addSubview:blackLine];
        [_lines addObject: blackLine];
        
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(30, (yDist * i), 100, 30 )];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        if( i == [_tableData count]){
            label.text = @"No Labels";
        } else  label.text = [_tableData objectAtIndex:i];
        [self.timeLineContainer addSubview:label];
        [_labels addObject:label];
    }
    [self drawCirclesWithBegin:_begin withEndTime:_end andWithTotals:totals];
    //NSLog(@"%@", NSStringFromCGSize(self.timeLineContainer.contentSize));
    


}

- (void)printData {
   // NSLog(@"%@", self.captureRecords);
    for (CaptureRecord *record in self.captureRecords){
        [[self.captureRecords objectForKey: record] print];
    }
}

- (int) mapTimeToDisplay : (NSDate *) imageTime withBeginTime : (NSDate *) begin withEndTime : (NSDate *) end beginX : (int) x width : (int) w{
    NSTimeInterval totalTime = [end timeIntervalSinceDate:begin];
    NSTimeInterval currentTimeDistance = [imageTime timeIntervalSinceDate:begin];
    return x + ( w * currentTimeDistance/totalTime );
}

- (void)rangeSliderValueChanged:(id)sender {
    
    [self updateSliderLabels];
    //[self updateLines];
}

- (void)updateSliderLabels {
    NSDateFormatter* formattedDate = [[NSDateFormatter alloc] init];
    [formattedDate setDateFormat:@"MM/dd/yyyy HH:mm:ss Z"];
    [formattedDate setDateStyle: NSDateFormatterShortStyle];
    [formattedDate setTimeStyle: NSDateFormatterShortStyle];
    
    NSDate *leftTime = [self mapDisplayToTime:self.timeSlider.leftValue withBeginTime:_begin];
    NSDate *rightTime = [self mapDisplayToTime:self.timeSlider.rightValue withBeginTime:_begin];
    NSString *logData = [NSString stringWithFormat:@"\n%@ : changed slider handle positions to left: %@ right: %@", [formattedDate stringFromDate:[NSDate date]], [formattedDate stringFromDate:leftTime], [formattedDate stringFromDate: rightTime]];
    [self.file seekToEndOfFile];
    [self.file writeData: [logData dataUsingEncoding:NSUTF8StringEncoding]];
    _leftLabel.text = [formattedDate stringFromDate: leftTime ];
    _rightLabel.text = [formattedDate stringFromDate:rightTime];
    int totals[[_tableData count] +1];
    [self drawCirclesWithBegin:leftTime withEndTime:rightTime andWithTotals:totals];
}

- (NSDate *) mapDisplayToTime: (int) sliderPosition withBeginTime : (NSDate *) begin {
    NSTimeInterval sliderTime = sliderPosition;
    return [begin dateByAddingTimeInterval:sliderTime];
}

- (void) drawCirclesWithBegin : (NSDate *) beginTime withEndTime: (NSDate *) endTime andWithTotals: (int[]) totals {
    for( NSString *view in _dataPoints){
        [[_dataPoints objectForKey:view ] removeFromSuperview];
    }
    [_dataPoints removeAllObjects];
    
    for(NSString* record in _captureRecords){
        if ([[[_captureRecords objectForKey:record] tagData] count] == 0){

            UIImageView *circle =[[UIImageView alloc] initWithImage:self.unsorted];
            circle.frame = CGRectMake(0, 0, 15, 15);
            circle.center = CGPointMake([self mapTimeToDisplay: [[_captureRecords objectForKey:record] firstImageTime]  withBeginTime:beginTime withEndTime: endTime beginX:105 width:814], 15 + (yDist * [_tableData count]));
            CGRect frame = CGRectMake(105, 0, 814, 395);

            if(CGRectContainsPoint(frame, circle.center)){
                [self.timeLineContainer addSubview: circle];
                NSString *recordNewName = [[NSString alloc] initWithFormat:@"%@ %f%f", record, circle.center.x, circle.center.y];
                [_dataPoints setValue:circle forKey: recordNewName];
               
                totals[[_tableData count]]++;
            }
        } else {
            for( Tag * tag in [[_captureRecords objectForKey:record] tagData]){
                for (int i = 0; i < [_tableData count]; i++){
                    UIImageView *circle;
                    if([[[tag uiTag] text] isEqual: [_tableData objectAtIndex:i]]){
                        circle = [[UIImageView alloc] initWithImage:self.sorted];
                        circle.frame = CGRectMake(0, 0, 15, 15);
                        circle.center = CGPointMake([self mapTimeToDisplay: [[_captureRecords objectForKey:record] firstImageTime]  withBeginTime:beginTime withEndTime: endTime beginX:105 width:814], 15 + (yDist * i));
                        CGRect frame = CGRectMake(105, 0, 814, 395);

                        if(CGRectContainsPoint(frame, circle.center)){
                            [self.timeLineContainer addSubview: circle];
                            NSString *recordNewName = [[NSString alloc] initWithFormat:@"%@ %@%@", record, [[tag uiTag] text], NSStringFromCGPoint([[tag uiTag] center])];
                            [_dataPoints setValue:circle forKey: recordNewName];
                            totals[i]++;
                        }
                        
                    }
                }
            }
        }
        if ([record isEqual: self.currentRecord]){
            self.highlight.alpha = 1.0;
            self.highlight.center = CGPointMake([self mapTimeToDisplay: [[_captureRecords objectForKey:record] firstImageTime]  withBeginTime:beginTime withEndTime: endTime beginX:105 width:814], self.highlight.center.y);
            if (self.highlight.center.x > 814 || self.highlight.center.x < 105){
                self.highlight.alpha = 0.0;
            }
        }
    }
    [self updateTotals: totals];
}

- (void) updateTotals : (int[]) totals{
    for(UILabel *total in _totals){
        [total removeFromSuperview];
    }
    [_totals removeAllObjects];
    for(int i= 0; i <[_tableData count] + 1; i++){
        totals[i] = 0;
        for(NSString *dataRecord in _dataPoints){
            UIImageView *circle = [_dataPoints objectForKey:dataRecord];
            if(circle.center.y == 15 + (yDist * i )){
                totals[i]++;
            }
        }
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(930, (yDist * i), 100, 30 )];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = [[NSString alloc] initWithFormat:@"%d", totals[i]];
        [self.timeLineContainer addSubview:label];
        [_totals addObject:label];
    }
}

- (IBAction)tapAction:(UITapGestureRecognizer *) tapInstance {
    CGPoint tapLocation = [tapInstance locationInView:self.timeLineContainer];
    for(NSString *circleRecord in _dataPoints){
        //NSLog(@"containsData: %@" , NSStringFromCGRect([[_dataPoints objectForKey:circleRecord] frame]));
        if(CGRectContainsPoint([[_dataPoints objectForKey:circleRecord] frame], tapLocation)){
            NSLog(@"circleRecord : %@", circleRecord);
            NSString *circleRecordModified;
            NSRange range = [circleRecord rangeOfString:@" "];
            self.highlight.center = [[_dataPoints objectForKey:circleRecord] center];
            [self.timeLineContainer sendSubviewToBack: self.highlight];
            if(range.location > 0 && range.location < circleRecord.length) circleRecordModified = [circleRecord substringToIndex:range.location];
            //else circleRecordModified = [circleRecord copy];
            self.currentRecord = [circleRecordModified mutableCopy];
            NSLog(@"%@", self.captureRecords);
            if([[[self.captureRecords objectForKey:circleRecordModified] pathNames] count] < 1) [[self.captureRecords objectForKey:circleRecordModified] loadImages];
            self.currentImage.animationImages = [[self.captureRecords objectForKey:circleRecordModified] pathNames];
            self.currentImage.animationDuration = 2;
            [self.currentImage startAnimating];
            NSDateFormatter* formattedDate = [[NSDateFormatter alloc] init];
            [formattedDate setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
            NSString *logData = [NSString stringWithFormat:@"\n%@ : Activated the image(s) for CaptureRecord: %@", [formattedDate stringFromDate:[NSDate date]], circleRecordModified];
//            NSLog(logData);
            [self.file seekToEndOfFile];
            [self.file writeData: [logData dataUsingEncoding:NSUTF8StringEncoding]];
            break;
        }
    }
    
}

- (void) updateLines{
    int multiplier = self.tableData.count + 2;
    NSDate *leftTime = [[NSDate alloc] initWithTimeInterval:self.timeSlider.leftValue sinceDate:self.begin];
    int left = [self mapTimeToDisplay: leftTime withBeginTime:self.begin withEndTime:self.end beginX:105 width:814];
    NSDate *rightTime = [[NSDate alloc] initWithTimeInterval:self.timeSlider.rightValue sinceDate:self.begin];
    int right = [self mapTimeToDisplay: rightTime withBeginTime:self.begin withEndTime:self.end beginX:105 width:814];
    [self.lineView clearScreen];
    self.leftLine =[self.lineView drawLeftLineFromPoint:CGPointMake(left+5, 650) toPoint:CGPointMake(105, multiplier * yDist+305) ];
    self.rightLine =[self.lineView drawRightLineFromPoint:CGPointMake(right-5, 650) toPoint:CGPointMake(920, multiplier * yDist+305)];
    //self.leftLine = [self.lineView drawBothLinesFromPoint:CGPointMake(left, 650) toPoint:CGPointMake(105, self.tableData.count * yDist + 300) andPoint2:CGPointMake(right, 650) toPoint:CGPointMake(919, self.tableData.count *yDist + 300)];
}

@end
