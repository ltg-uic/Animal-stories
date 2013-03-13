//
//  LineDrawingView.m
//  as_test
//
//  Created by Tia Shelley on 3/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "LineDrawingView.h"

@implementation LineDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.path =[[UIBezierPath alloc] init];
        self.path.lineCapStyle=kCGLineCapRound;
        self.path.miterLimit=0;
        self.path.lineWidth=3.0;
        self.brushPattern=[UIColor blackColor];
        self.path2 =[[UIBezierPath alloc] init];
        self.path2.lineCapStyle=kCGLineCapRound;
        self.path2.miterLimit=0;
        self.path2.lineWidth=3.0;

    }
    return self;
}

- (UIBezierPath *)drawLeftLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    //NSLog(@"%@, %@", NSStringFromCGPoint(fromPoint), NSStringFromCGPoint(toPoint));
    [self.path moveToPoint:fromPoint];
    [self.path addLineToPoint:toPoint];
    [self setNeedsDisplay];
    [self.path closePath];
    return self.path;
    
}
- (UIBezierPath *)drawRightLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    //NSLog(@"%@, %@", NSStringFromCGPoint(fromPoint), NSStringFromCGPoint(toPoint));
    [self.path2 moveToPoint:fromPoint];
    [self.path2 addLineToPoint:toPoint];
    [self setNeedsDisplay];
    [self.path2 closePath];
    return self.path2;
    
}

- (UIBezierPath *)drawBothLinesFromPoint: (CGPoint)fromPoint toPoint:(CGPoint)toPoint andPoint2: (CGPoint)fromPoint2 toPoint:(CGPoint)toPoint2{
    [self.path moveToPoint:fromPoint];
    [self.path addLineToPoint:toPoint];
    [self.path moveToPoint:fromPoint2];
    [self.path addLineToPoint: toPoint2];
    [self setNeedsDisplay];
    return self.path;
}

- (void)drawRect:(CGRect)rect
{
    [self.brushPattern setStroke];
    [self.path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    [self.path2 strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    // Drawing code
    //[myPath stroke];
}

-(void) clearScreen{
    [self.path removeAllPoints];
    [self.path2 removeAllPoints];
    [self setNeedsDisplay];
}

@end
