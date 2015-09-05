//
//  CubeScrambler.h
//  CubeTimer Scramblers
//
//  Adapted from Jaap Scherphuis' cube scrambler with permission, as obtained from http://www.worldcubeassociation.org/regulations/scrambles.zip
//

#import <Foundation/Foundation.h>

@interface CubeScrambler : NSObject {
    int *seq;
    int seqcount;
  //  var flat2posit;	//lookup table for drawing cube
}

@property (nonatomic) int size;
@property (nonatomic) int seqlen;

-(void)generateSequenceOfScrambles;
-(NSString *) generateScrambleString;
-(id) initWithSize:(int)sizeToSet andLength:(int)lengthToSet;

@end
