//
//  FirstViewController.m
//  as_test
//
//  Created by Tia Shelley on 1/16/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "LabelViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "CaptureRecord.h"



@interface LabelViewController ()

@property (weak, nonatomic) IBOutlet UITextView *notesBox;
@property (weak, nonatomic) IBOutlet UIImageView *currentImage;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRecognizer2;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *dragGesture;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *dragGesture2;
@property (strong, nonatomic) NSMutableArray *labelsAddedToImage;
@property (nonatomic) NSInteger currentLabelIndex;
@property (strong, nonatomic) NSMutableData *tagListData;
@property (strong, nonatomic) Tag *activeTag;
@property (strong, nonatomic) NSMutableArray *circleList;
@property UIAlertView *delete;
@property UIAlertView *edit;
@property NSFileHandle *file;

@end

@implementation LabelViewController

@synthesize circleList = _circleList;
@synthesize currentLabelIndex = _currentLabelIndex;
@synthesize labelTable = _labelTable;
@synthesize notesBox = _notesBox;
@synthesize currentImage = _currentImage;
@synthesize tableData = _tableData;
@synthesize editModeButton = _editModeButton;
@synthesize addLabelText = _addLabelText;
@synthesize tagListData = _tagListData;
@synthesize captureRecords = _captureRecords;
@synthesize rightArrowButton = _rightArrowButton;
@synthesize leftArrowButton = _leftArrowButton;
@synthesize activeTag = _activeTag;
@synthesize scientist = _scientist;
@synthesize user = _user;
@synthesize av = _av;
@synthesize file = _file;

NSURL *server;
NSMutableString *currentCaptureRecord;
NSIndexPath *path;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.circleList = [[NSMutableArray alloc] init];
    currentCaptureRecord = [[NSMutableString alloc] initWithString:@"0 "];
    //_scientist = @"TheSquirrelKids";
    NSLog(@"%@", self.scientist);
    server = [NSURL URLWithString: @"http://10.0.1.100/~evl/as/"];
    NSString* GMTOffset = @"-0600";
    //instantiates the labelTable
    _labelTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 59, 320, 460) style: UITableViewStylePlain];
    NSString *fileListURL = [[NSString alloc] initWithFormat:@"filelistplusdata.php?scientist=%@", _scientist ];
    NSString *captureData = [NSString stringWithContentsOfURL:[NSURL URLWithString: fileListURL relativeToURL:server] encoding:NSUTF8StringEncoding error: nil];
    //NSLog(@"%@", captureData);
    captureData = [captureData stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *captureDataArray = [captureData componentsSeparatedByString: @"\n"];
    _captureRecords = [[NSMutableDictionary alloc] init];
    
    //for each entry line, which represents an image, checks to see if there is an existing record for that imageSet. If not, it creates a new record, and adds to the dictionary. Else, adds the new image to the existing record.
    NSDateFormatter* formattedDate = [[NSDateFormatter alloc] init];
    [formattedDate setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *begin = [NSDate distantFuture];
    NSDate *end = [NSDate distantPast];
    self.totalNumberOfRecords.text = [[NSString alloc] initWithFormat: @"%d records", captureDataArray.count];
    for( int i = 0; i < captureDataArray.count; i++){
        NSString *recordText = [ [captureDataArray objectAtIndex:i ] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *record = [recordText componentsSeparatedByString: @"\t"];
        if(![_captureRecords objectForKey: [record objectAtIndex:1]]){
            //processes dateTime data
            NSString* dateTime = [[NSString alloc] initWithFormat: @"%@ %@ %@", [record objectAtIndex:5], [record objectAtIndex:6], GMTOffset] ;
            //NSLog(@"%@, %@", dateTime, [formattedDate dateFromString:dateTime ]);
            NSString* pathName = [@"images/" stringByAppendingString:[record objectAtIndex:2]];
            NSDate* fileDate = [formattedDate dateFromString:dateTime];
            if ( [begin earlierDate: fileDate] == fileDate) begin = fileDate;
            if ( [end laterDate: fileDate] == fileDate) end = fileDate;
            CaptureRecord *newRecord = [[ CaptureRecord alloc] initWithPathName:[[server absoluteString] stringByAppendingString: pathName ] identifier: [[record objectAtIndex: 1] intValue]  author:[record objectAtIndex: 3] atTime: [formattedDate dateFromString:dateTime]];
            [_captureRecords setObject:newRecord forKey:[record objectAtIndex:1]];
        }else {
            [[_captureRecords objectForKey: [record objectAtIndex:1] ] addPathName: [[server absoluteString] stringByAppendingString:[record objectAtIndex:2]]];
        }
    }
    [formattedDate setDateStyle: NSDateFormatterShortStyle];
    [formattedDate setTimeStyle: NSDateFormatterShortStyle];
    UILabel* beginningTime = [[UILabel alloc] initWithFrame: CGRectMake(55, 675, 200, 30)];
    beginningTime.textColor = [UIColor blackColor];
    beginningTime.backgroundColor = [UIColor clearColor];
    beginningTime.font = [UIFont systemFontOfSize:12];
    beginningTime.text = [formattedDate stringFromDate: begin];
    UILabel* endTime = [[UILabel alloc] initWithFrame: CGRectMake(878, 675, 200, 30)];
    endTime.textColor = [UIColor blackColor];
    endTime.backgroundColor = [UIColor clearColor];
    endTime.font = [UIFont systemFontOfSize:12];
    endTime.text = [formattedDate stringFromDate: end];
    //instantiates tableData from the web: later need to make this user specific.
    NSString *tagListURL = [[NSString alloc] initWithFormat:@"taglist.php?scientist=%@", self.scientist];
    NSString *tagList = [NSString stringWithContentsOfURL: [NSURL URLWithString: tagListURL relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
    tagList = [tagList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _tableData = [[ tagList componentsSeparatedByString:@"\n"] mutableCopy];
    
    //instantiates labels
    _labelsAddedToImage = [[NSMutableArray alloc] init];
    
    NSString *tagPosURL = [[NSString alloc] initWithFormat:@"getalltags.php?scientist=%@", self.scientist];
    NSString *tagPositions = [NSString stringWithContentsOfURL: [NSURL URLWithString: tagPosURL relativeToURL: server] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@", tagPositions);
    tagPositions = [tagPositions stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *tagPos = [tagPositions componentsSeparatedByString:@"\n"];
    for(int i = 0; i < tagPos.count; i++){
        NSString *recordText = [ [tagPos objectAtIndex:i ] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSLog(@"%@", recordText);
        NSArray *record = [recordText componentsSeparatedByString: @"\t"];
        //NSLog(@"%@, %d", [record objectAtIndex:0], [[record objectAtIndex:0] intValue]);
        if([_captureRecords objectForKey: [record objectAtIndex:0] ]){
            Tag* lastTag = [[_captureRecords objectForKey: [record objectAtIndex:0]] addTag: [[Tag alloc] initWithCenter:CGPointMake([[record objectAtIndex:2] intValue], [[record objectAtIndex: 3] intValue]) withIdentifier:[[record objectAtIndex: 0] intValue] withText:[[record objectAtIndex: 1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ] ]];
            [lastTag addLabelToView:self.view];
            
        }
    }
    
    //[self imageList];
    [_addLabelText setAlpha:1.0];
    //NSLog(@"%@", [_captureRecords description]);
    

    
    [self loadView];
    _av = [self.tabBarController.viewControllers objectAtIndex:1];
    self.av.tableData = _tableData;
    self.av.begin = begin;
    self.av.end = end;
    self.begin = begin;
    self.end = end;
    self.addLabelText.delegate = self;
    [self.view addSubview:beginningTime];
    [self.view addSubview:endTime];
    if (![[_captureRecords objectForKey:currentCaptureRecord] pathNames]){
        self.currentImage.image = [UIImage imageNamed:@"startImage.png"];
        [NSString stringWithFormat:@"%d ", -1];
    } else {
    self.currentImage.animationImages = [[_captureRecords objectForKey:currentCaptureRecord] pathNames];
    }
    self.currentImage.animationDuration = 1;
    [self.currentImage startAnimating];
    //NSLog(@"Key: %@, %@", currentCaptureRecord,[_captureRecords objectForKey:currentCaptureRecord]);
    //NSLog(@"%@", self.currentImage.image);
    
    self.labelTable.allowsSelectionDuringEditing = YES;
    _totalNumberOfRecords.text = [[NSString alloc] initWithFormat: @"%d", [_captureRecords count]];
    _addLabelText.borderStyle = UITextBorderStyleRoundedRect;
    _addLabelText.alpha = 0.0;
    
    //instantiates swipeRecognizers; one each for left and right

    _swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRecognizer:)];
    _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _swipeRecognizer.numberOfTouchesRequired = 2;
    [self.currentImage addGestureRecognizer:_swipeRecognizer];
    _swipeRecognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRecognizer:)];
    _swipeRecognizer2.numberOfTouchesRequired = 2;
    [self.currentImage addGestureRecognizer:_swipeRecognizer2];
    _dragGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action: @selector(handleDrag:)];
    _dragGesture2 =[[UIPanGestureRecognizer alloc] initWithTarget:self action: @selector(handleDrag:)];
    [self.currentImage addGestureRecognizer:_dragGesture2];
    [self.labelTable addGestureRecognizer:_dragGesture];
    
    [self drawTimeLineCirclesWithHighlight:nil];
    NSDate *date = [NSDate date];
    [formattedDate setTimeStyle: nil];
    [formattedDate setDateFormat: @"yy-MM-dd"];
    
    NSString *fileNameEnding = [NSString stringWithFormat:@"%@%@%@.txt", _user, _scientist, [formattedDate stringFromDate: date]];
    NSLog(@"%@", fileNameEnding);
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:fileNameEnding];
    
    //create file if it doesn't exist
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    //append text to file (you'll probably want to add a newline every write)
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [file seekToEndOfFile];
    [file writeData:[fileNameEnding dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

- (void) viewWillDisappear:(BOOL)animated{
    self.av.captureRecords = _captureRecords;
}
//Gesture Processing

//handles drags
- (IBAction)handleDrag: (UIPanGestureRecognizer *) recognizer{


    //first case: there is a label selected on the left and we're creating a new label to drag onto the view for the first time.
    //second case: there is an existing label on the image and we're moving it
    if(recognizer.view == _labelTable){
        NSIndexPath* test = [_labelTable indexPathForRowAtPoint: [recognizer locationInView:recognizer.view]];
        if([recognizer state] == UIGestureRecognizerStateBegan){
            CGPoint gestureBegan = [recognizer locationInView:self.view];
            UILabel *duplicate = [[UILabel alloc] initWithFrame:(CGRectMake(gestureBegan.x, gestureBegan.y, 100, 30))];
            duplicate.text = [_tableData objectAtIndex: test.row];
            duplicate.textColor =  [UIColor whiteColor];
            duplicate.textAlignment = NSTextAlignmentCenter;
            duplicate.backgroundColor = [[UIColor alloc] initWithWhite:0.3 alpha:0.5];
            //duplicate.shadowColor =[UIColor blackColor];
            _activeTag = [[Tag alloc] initWithUIlabel:duplicate andID: [[_captureRecords objectForKey:currentCaptureRecord] imgSet]];
            
            //[_labelsAddedToImage addObject: duplicate];
            [self.view addSubview: duplicate];
            //NSLog(@"%@ , %@", duplicate, _labelsAddedToImage);
            [recognizer setTranslation:CGPointZero inView:self.view];
        } else if([recognizer state]  == UIGestureRecognizerStateChanged){
            
            CGPoint translation = [recognizer translationInView:self.view];
            //NSLog(@"%f, %f", translation.x, translation.y);
            [_activeTag moveTagToPosition:CGPointMake([_activeTag center].x + translation.x, [_activeTag center].y + translation.y)];
            [recognizer setTranslation:CGPointZero inView:self.view];
        }else if([recognizer state] == UIGestureRecognizerStateEnded){
            //label has been dropped onto the image
            [_labelTable deselectRowAtIndexPath:test animated: YES];
            [[_captureRecords objectForKey:currentCaptureRecord] addTag: _activeTag];
            //Confirm that the label is within the image: if not, remove it from the list
            if (!CGRectContainsPoint(self.currentImage.frame, [_activeTag center]) ){
                [_activeTag.uiTag removeFromSuperview ];
                //[[_captureRecords objectForKey:currentCaptureRecord] removeTag: _activeTag];

            }
            _activeTag = nil;
        }
        
    } else {
        //handles moving labels that have already been placed on the image
        if([recognizer state]  == UIGestureRecognizerStateBegan){
            //check if any labels have been selected
            for( Tag * tag in [[_captureRecords objectForKey:currentCaptureRecord] tagData]){
                if( CGRectContainsPoint( [tag.uiTag frame], [recognizer locationInView:self.view] )){
                    _activeTag = tag;
                }
            }
            
        } else if( [recognizer state] == UIGestureRecognizerStateChanged && _activeTag != nil) {
            CGPoint translation = [recognizer translationInView:[ _activeTag.uiTag superview]];
            [_activeTag moveTagToPosition:CGPointMake([_activeTag center].x + translation.x, [_activeTag center].y + translation.y)];
            [recognizer setTranslation:CGPointZero inView:[_activeTag.uiTag superview]];
        } else if ([recognizer state] == UIGestureRecognizerStateEnded && _activeTag != nil){
            //NSLog(@"%@, %@", NSStringFromCGPoint([[_labelsAddedToImage objectAtIndex: _currentLabelIndex] center]), NSStringFromCGRect(self.currentImage.frame));
            if (!CGRectContainsPoint(self.currentImage.frame, [_activeTag center]) ){
                [_activeTag.uiTag removeFromSuperview ];
                [[_captureRecords objectForKey:currentCaptureRecord] removeTag: _activeTag];
            }
            _activeTag = nil;
        }
    }
    
}


//hides keyboard when enter is clicked
- (BOOL) textFieldShouldReturn: (UITextField *) textField{
    return [textField resignFirstResponder];
}

//handles swipe in both direction
- (IBAction)handleSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"swipe recognized");
    NSInteger currentRecordNum = [currentCaptureRecord intValue];
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        currentRecordNum++;
        if(currentRecordNum == _captureRecords.count) currentRecordNum = 1;
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        currentRecordNum--;
        if(currentRecordNum < 1) currentRecordNum = _captureRecords.count-1;
    }
    [[_captureRecords objectForKey:currentCaptureRecord] removeTagsFromView];
    currentCaptureRecord = [NSString stringWithFormat:@"%d ", currentRecordNum];
    //NSLog(@"%@", currentCaptureRecord);
    self.currentImage.animationImages = [[_captureRecords objectForKey: currentCaptureRecord] pathNames];
    self.currentImage.animationDuration = 1;
    [self.currentImage startAnimating];
    [[_captureRecords objectForKey:currentCaptureRecord] addTagsToView: self.view];
    
}

//End of Gesture Recognition processing

//map function for placing the circles on the timeline

- (int) mapTimeToDisplay : (NSDate *) imageTime withBeginTime : (NSDate *) begin withEndTime : (NSDate *) end beginX : (int) x width : (int) w{
    NSTimeInterval totalTime = [end timeIntervalSinceDate:begin];
    NSTimeInterval currentTimeDistance = [imageTime timeIntervalSinceDate:begin];
    return x + ( w * currentTimeDistance/totalTime );
}


- (void) drawTimeLineCirclesWithHighlight : (CaptureRecord *) captureKey {
    //NSLog(@"%@", self.circleList);
    for(UIImageView* circle in self.circleList){
        //NSLog(@"%@", circle);
        [circle removeFromSuperview];
    }
    [self.circleList removeAllObjects];
    
    UIImageView *highlight;
    for(CaptureRecord* record in _captureRecords){
        UIImageView *circle;
        if([[_captureRecords objectForKey: record ] isUntagged]){
            circle = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unsorted.png"]];
        } else {
            circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"sorted.png"]];
        }
        circle.center = CGPointMake([self mapTimeToDisplay: [[_captureRecords objectForKey:record] firstImageTime]  withBeginTime:self.begin withEndTime:self.end beginX:105 width:814], 678);
        
        if([_captureRecords objectForKey:record] == captureKey){
            //NSLog(@"%@%@", [_captureRecords objectForKey:record], captureKey);

            highlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"highlight.png"]];
            highlight.center = circle.center;
            //NSLog(@"%@", highlight);
            [self.view addSubview: highlight];
            [self.circleList addObject:highlight];

        }


        [self.view addSubview: circle];
        [self.circleList addObject:circle];

        _labelTable.editing = NO;
        
    }
}

//Begin button processing

- (IBAction)editPressed {
    if (_labelTable.editing){
        [self setEditing: NO animated: NO];
        editModeButton.titleLabel.text = @"Edit Mode";
        [_addLabelText setAlpha:0.0];
    } else {
        editModeButton.titleLabel.text = @"Done";
        [self setEditing: YES animated: YES];
        [_addLabelText setAlpha:1.0];
    }
}

- (IBAction)arrowPressed:(UIButton *)sender {
    NSInteger currentRecordNum = [currentCaptureRecord intValue];

    [[_captureRecords objectForKey:currentCaptureRecord] removeTagsFromView];
    [[_captureRecords objectForKey:currentCaptureRecord] updateDB:server];
    
    do {
        if(sender == _rightArrowButton){
            currentRecordNum++;
            if(currentRecordNum == _captureRecords.count) currentRecordNum = 1;
        } else if(sender == _leftArrowButton){
            currentRecordNum--;
            if(currentRecordNum < 1) currentRecordNum = _captureRecords.count-1;
        }
        currentCaptureRecord = [NSString stringWithFormat:@"%d ", currentRecordNum];
    } while (![_captureRecords objectForKey: currentCaptureRecord]);
    //NSLog(@"%@", currentCaptureRecord);
    self.currentImage.animationImages = [[_captureRecords objectForKey: currentCaptureRecord] pathNames];
    self.currentImage.animationDuration = 1;
    [self.currentImage startAnimating];
    [[_captureRecords objectForKey:currentCaptureRecord] addTagsToView: self.view];
    [self drawTimeLineCirclesWithHighlight:[_captureRecords objectForKey:currentCaptureRecord]];
    self.av.captureRecords = self.captureRecords;
    //NSLog(@"%@, %@", self.currentImage.isAnimating? @"YES" : @"NO", self.currentImage.animationImages);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_labelTable setEditing:editing animated:animated];
}

- (IBAction)addNewLabel {
    //NSLog(@"%@", _addLabelText.text);
    NSString *stringText = [NSString stringWithFormat: @"insertTag.php?scientist=%@&tag=%@", _scientist, _addLabelText.text];
    //NSLog(@"%@", stringText);
    [_tableData addObject: _addLabelText.text];
    [_labelTable reloadData];
    NSString *addLabelData = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", addLabelData);
    _addLabelText.text = @"";
}


#pragma mark - TableView Data Source methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableData count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    }
    //NSLog(@"Test String: %@", [_tableData objectAtIndex: indexPath.row]);
    cell.textLabel.text = [_tableData objectAtIndex: indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (_labelTable.editing){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            path = indexPath;
            [self alertStatusDelete: @"Are you sure you want to delete this tag? Doing so will remove this tag from all the images that have this tag." : @"Delete a tag"];
        }
    } 
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"selected row");
    if(_labelTable.editing){
        path = indexPath;
        [self alertStatusEdit:@"Change the name of your label" : @"Edit Label"];
    }
    
}


- (void) alertStatusDelete:(NSString *)msg :(NSString *)title
{
    self.delete = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    [self.delete show];
}

- (void) alertStatusEdit:(NSString *)msg :(NSString *)title
{
    self.edit = [[UIAlertView alloc] initWithTitle: title message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
   self.edit.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [self.edit textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField.placeholder = [_tableData objectAtIndex:path.row];
    [self.edit show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (actionSheet == self.delete){
        if (buttonIndex == actionSheet.firstOtherButtonIndex)
        {
            NSString *tagName = [_tableData objectAtIndex:path.row];
            NSLog(@"%@", tagName);
            NSString *stringText = [NSString stringWithFormat:@"deleteTag.php?scientist=%@&tag=%@", _scientist, tagName];
            NSString *addLabelData = [NSString stringWithContentsOfURL:[NSURL URLWithString: stringText relativeToURL:server] encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@", addLabelData);
            //removes the tags from all records
            for(CaptureRecord * record in _captureRecords){
                [[_captureRecords objectForKey:record] removeTags: tagName];
            }
            [_tableData removeObjectAtIndex:path.row];
            [_labelTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            //Does not actually remove the tag
            NSLog(@"cancel");
        }
    } else {
        
        if (buttonIndex == actionSheet.firstOtherButtonIndex){
            NSString *oldTagName = [_tableData objectAtIndex:path.row];
            NSString *newTagName = [[self.edit textFieldAtIndex:0] text];
            NSLog(@"%@, %@", oldTagName, newTagName);
            for(CaptureRecord *record in _captureRecords){
                [[_captureRecords objectForKey:record] renameTag:oldTagName withTag: newTagName];
            }
            [_tableData replaceObjectAtIndex:path.row withObject: newTagName];
            [_labelTable reloadData];
            
        } else {
            NSLog(@"cancel");
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editing ;
}

@end