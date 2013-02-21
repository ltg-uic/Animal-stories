//
//  Tag.h
//  as_test
//
//  Created by Tia Shelley on 2/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tag : NSObject{
    
}
@property int imgSet;
@property CGPoint center;
@property NSString *labelText;
@property UILabel   *uiTag;
@property CGRect labelFrame;

-(void)moveTagToPosition : (CGPoint) center;
-(Tag*)initWithCenter : (CGPoint) center withIdentifier: (int) imgSet withText: (NSString*) labelText;
-(void)addLabelToView: (UIView*) view;
-(Tag *) initWithUIlabel : (UILabel *) label andID: (int) imgSet;
-(void)removeLabelFromView;
- (NSString *) tagText;
@end
