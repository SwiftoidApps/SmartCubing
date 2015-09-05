//
//  SQSquare.h
//  CubeTimer
//
//  CubeTimer Scramblers
//
//  Adapted from JFly's public domain sq12phase project, as obtained from https://github.com/cubing/tnoodle/tree/master/sq12phase/src/cs/sq12phase
//

#import <Foundation/Foundation.h>

@interface SQSquare : NSObject

-(void) set8Perm:(SInt16*) arr idx:(int) idx;
-(UInt16) get8Perm:(SInt16*)arr;
-(int) get8Comb:(SInt16*)arr;

@property (nonatomic) int edgeperm, cornperm, ml;
@property (nonatomic) BOOL topEdgeFirst, botEdgeFirst;

+(SQSquare*) square;
+(SInt16*) SquarePrun;

+(UInt16*) TwistMove;
+(UInt16*) TopMove;
+(UInt16*) BottomMove;

@end
