//
//  SQShape.h
//  CubeTimer Scramblers
//
//  Adapted from JFly's public domain sq12phase project, as obtained from https://github.com/cubing/tnoodle/tree/master/sq12phase/src/cs/sq12phase
//

#import <Foundation/Foundation.h>

@interface SQShape : NSObject

+(int) getShape2Idx:(int) shp;
+(int*) ShapeIdx;
+(int*) ShapePrun;
+(int*) TwistMove;
+(int*) TopMove;
+(int*) BottomMove;
+(void) initialise;

@property (nonatomic) int top, bottom, parity;

@end
