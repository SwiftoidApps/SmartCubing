//
//  CTScrambleManager.h
//  CubeTimer Scramblers
//

#import <Foundation/Foundation.h>

@class CubeScrambler, ClockScrambler, TwoPhaseScrambler, TwoByTwoRandomState, SQSearch;

@interface CTScrambleManager : NSObject

-(NSString*) scrambleForPuzzleType:(NSString*)puzzleType competitionLength:(BOOL)competitionLength;

@property (nonatomic, strong) CubeScrambler *scrambler;
@property (nonatomic, strong) TwoPhaseScrambler *twoPhaseScrambler;
@property (nonatomic, strong) TwoByTwoRandomState *twoByTwoRandomState;
@property (nonatomic, strong) SQSearch *square1RandomState;

+(CTScrambleManager*) sharedScrambleManager;

@end
