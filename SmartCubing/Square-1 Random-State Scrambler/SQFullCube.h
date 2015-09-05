//
//  SQFullCube.h
//  CubeTimer Scramblers
//
//  Adapted from JFly's public domain sq12phase project, as obtained from https://github.com/cubing/tnoodle/tree/master/sq12phase/src/cs/sq12phase
//

#import <Foundation/Foundation.h>
#import "RandomNumber.h"
@class SQSquare;
@interface SQFullCube : NSObject

-(int) getShapeIdx;
-(void) doMove:(int) move;
-(void) getSquare:(SQSquare*) sq;
-(void) copy:(SQFullCube*)fullCube;
+(SQFullCube*) randomCube;
@property (nonatomic) int ul, ur, dl, dr, ml;

@end
