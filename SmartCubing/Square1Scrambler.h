//
//  Square1Scrambler.h
//  CubeTimer Scramblers
//
//  Adapted from Jaap Scherphuis' Square-1 scrambler with permission, as obtained from http://www.worldcubeassociation.org/regulations/scrambles.zip
//

#import <Foundation/Foundation.h>

@interface Square1Scrambler : NSObject

-(bool)doMove:(int)m;
-(NSString*)generateScrambleString;
-(void) scramble;

@end
