//
//  TabController.m
//  as_test
//
//  Created by Tia Shelley on 3/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "TabController.h"
#import "LabelViewController.h"

@interface TabController ()

@end

@implementation TabController

@synthesize scientist = _scientist;
@synthesize user = _user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    LabelViewController *vc = [self.viewControllers objectAtIndex:0];
    vc.scientist = self.scientist;
    vc.user = self.user;

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
