//
//  LineDrawingView.h
//  as_test
//
//  Created by Tia Shelley on 3/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineDrawingView : UIView{
    
}
@property UIBezierPath *path;
@property UIBezierPath *path2;
@property UIColor *brushPattern;
-(UIBezierPath *) drawRightLineFromPoint: (CGPoint) fromPoint toPoint: (CGPoint) toPoint;
-(UIBezierPath *) drawLeftLineFromPoint: (CGPoint) fromPoint toPoint: (CGPoint) toPoint;
-(void) clearScreen;
- (UIBezierPath *)drawBothLinesFromPoint: (CGPoint)fromPoint toPoint:(CGPoint)toPoint andPoint2: (CGPoint)fromPoint2 toPoint:(CGPoint)toPoint2;
@end
