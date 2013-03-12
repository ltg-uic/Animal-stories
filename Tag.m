//
//  Tag.m
//  as_test
//
//  Created by Tia Shelley on 2/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize imgSet = _imgSet;
@synthesize center = _center;
@synthesize labelText = _labelText;
@synthesize labelFrame = _labelFrame;
@synthesize uiTag = _uiTag;

-(Tag*) initWithCenter : (CGPoint) center withIdentifier: (int) imgSet withText: (NSString*) labelText{
    _imgSet = imgSet;
    _center = center;
    _labelText = [[NSString alloc] initWithString: labelText];
    _labelFrame = CGRectMake(center.x, center.y, 100, 60);
    _uiTag = [[UILabel alloc] initWithFrame:_labelFrame];
    _uiTag.text = _labelText;
    _uiTag.textColor = [UIColor whiteColor];
    _uiTag.backgroundColor = [[UIColor alloc] initWithWhite:0.3 alpha:0.5];
    _uiTag.textAlignment = NSTextAlignmentCenter;
    [_uiTag setAlpha:1.0];
    _uiTag.shadowColor =[UIColor blackColor];
    
    return self;
}

-(Tag *) initWithUIlabel : (UILabel *) label andID: (int) imgSet{
    _uiTag = label;
    _imgSet = imgSet;
    _center = [label center];
    _labelFrame = [label frame];
    _labelText = [ label text];
    return self;
}

-(void) moveTagToPosition: (CGPoint) center{
    _center = center;
    _uiTag.center = center;
}

-(BOOL) isPointInFrame: (CGPoint) point{
    return CGRectContainsPoint(_labelFrame, point);
}

-(void) addLabelToView: (UIView*) view{
    [view addSubview: _uiTag];
}

-(void) removeLabelFromView{
    [_uiTag removeFromSuperview];
}

- (NSString *) tagText{
    return _uiTag.text;
}

@end
