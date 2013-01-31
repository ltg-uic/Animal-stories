//
//  FirstViewController.m
//  as_test
//
//  Created by Tia Shelley on 1/16/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "LabelViewController.h"

@interface LabelViewController ()

@property (weak, nonatomic) IBOutlet UITextView *notesBox;
@property (weak, nonatomic) IBOutlet UIImageView *currentImage;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) NSMutableArray *imageList;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRecognizer2;
@property int imageListPointer;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *dragGesture;
@property (strong, nonatomic) NSMutableArray *labelsAddedToImage;
@end

@implementation LabelViewController


@synthesize labelTable = _labelTable;
@synthesize notesBox = _notesBox;
@synthesize currentImage = _currentImage;
@synthesize progressBar = _progressBar;
@synthesize imageListPointer = _imageListPointer;
@synthesize imageList = _imageList;
@synthesize tableData = _tableData;
@synthesize editModeButton = _editModeButton;
@synthesize addLabelText = _addLabelText;


//this is a placeholder method. In final version, this needs to query
//the database, download the images and then set up the imageList
//imageList will probably need to be composed of a row of data per line
//to match the number of inserted labels, etc.

- (NSMutableArray*)imageList{
    if(!_imageList){
        _imageList = [[NSMutableArray alloc] init];
        [self.imageList addObject: [UIImage imageNamed:@"6990815470_6e5cab95aa_o.jpg"]];
        [self.imageList addObject: [UIImage imageNamed:@"6990815768_ac2f693e04_o.jpg"]];
        [self.imageList addObject: [UIImage imageNamed:@"6990816026_355530e1a3_o.jpg"]];
    }
    return _imageList;
}

//initializes swipeRecognizer, the TableView that contains everything else
//and will eventually use locally stored data to get to the labels the group
//has used before

- (void)viewDidLoad {

    
    //instantiates the labelTable
    _labelTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 59, 320, 460) style: UITableViewStylePlain];
    
    
    //instantiates tableData
    _tableData = [[NSMutableArray alloc] initWithObjects: @"Squirrel", @"Rabbit", @"Cat", nil];
    //NSLog(@"%@", _tableData);
    
    _labelsAddedToImage = [[NSMutableArray alloc] init];
    
    [_addLabelText setAlpha:1.0];

    [super viewDidLoad];
    [self loadView];
    
    //instantiates swipeRecognizers; one each for left and right

    _swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRecognizer:)];
    _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.currentImage addGestureRecognizer:_swipeRecognizer];
    _swipeRecognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRecognizer:)];
    [self.currentImage addGestureRecognizer:_swipeRecognizer2];
    
    _dragGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action: @selector(handleDrag:)];
    [self.view addGestureRecognizer:_dragGesture];
    
}

//handles drags
- (IBAction)handleDrag: (UIPanGestureRecognizer *) recognizer{
    NSIndexPath* test = [_labelTable indexPathForSelectedRow];
    if(test){
        if([recognizer state] == UIGestureRecognizerStateBegan){
            CGPoint gestureBegan = [recognizer locationInView:recognizer.view];
            UILabel *duplicate = [[UILabel alloc] initWithFrame:(CGRectMake(gestureBegan.x, gestureBegan.y, 100, 30))];
            duplicate.text = [_tableData objectAtIndex: test.row];
            duplicate.textColor =  [UIColor whiteColor];
            duplicate.backgroundColor = [UIColor clearColor];
            duplicate.shadowColor =[UIColor blackColor];
            [_labelsAddedToImage addObject: duplicate];
            [self.currentImage addSubview: duplicate];
            //NSLog(@"%@ , %@", duplicate, _labelsAddedToImage);
            [recognizer setTranslation:CGPointZero inView:[duplicate superview]];
        } else if([recognizer state]  == UIGestureRecognizerStateChanged){
        
            CGPoint translation = [recognizer translationInView:[ [_labelsAddedToImage lastObject] superview]];
            //NSLog(@"%f, %f", translation.x, translation.y);
            [[_labelsAddedToImage lastObject] setCenter:CGPointMake([[_labelsAddedToImage lastObject] center].x + translation.x, [[_labelsAddedToImage lastObject] center].y + translation.y)];
            [recognizer setTranslation:CGPointZero inView:[[_labelsAddedToImage lastObject] superview]];
        }else if([recognizer state] == UIGestureRecognizerStateEnded){
            [_labelTable deselectRowAtIndexPath:test animated: YES];
            NSLog(@"%@", NSStringFromCGPoint([[_labelsAddedToImage lastObject] center]));
        }

    }
    
    //next step is creating an else statement that handles moving objects that are already on the image
    
}


//handles swipe in both direction
- (IBAction)handleSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if(self.imageListPointer < self.imageList.count -1) self.imageListPointer++;
        else self.imageListPointer = 0;
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        if(self.imageListPointer > 0 ) self.imageListPointer--;
        else self.imageListPointer = self.imageList.count-1;
    }
	
    self.currentImage.image = [self.imageList objectAtIndex:(self.imageListPointer)];
}

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


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_labelTable setEditing:editing animated:animated];
}

- (IBAction)addNewLabel {
    NSLog(@"%@", _addLabelText.text);
    [_tableData addObject: _addLabelText.text];
    [_labelTable reloadData];
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
    NSLog(@"Test String: %@", [_tableData objectAtIndex: indexPath.row]);
    cell.textLabel.text = [_tableData objectAtIndex: indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (_labelTable.editing){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [_tableData removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } 
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editing ;
}

@end