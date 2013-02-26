//
//  SecondViewController.h
//  as_test
//
//  Created by Tia Shelley on 1/16/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnalyzeViewController : UIViewController
{
    NSMutableArray* tableData;
    NSMutableDictionary* captureRecords;

    
}

@property (strong, nonatomic) NSMutableArray* tableData;

@property (strong, nonatomic) NSMutableDictionary* captureRecords;
@end
