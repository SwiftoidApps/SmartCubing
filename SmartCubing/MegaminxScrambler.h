//
//  MegaminxScrambler.h
//  CubeTimer Scramblers
//
//  Adapted from Jaap Scherphuis' Megaminx scrambler with permission, as obtained from http://www.worldcubeassociation.org/regulations/scrambles.zip

#import <Foundation/Foundation.h>

@interface MegaminxScrambler : NSObject {
    NSMutableArray *seq;
}

-(void)scramble;
-(NSString*)generateScrambleString;

@end
