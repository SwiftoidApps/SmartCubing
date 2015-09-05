//
//  CTScrambleManager.m
//  CubeTimer Scramblers
//

#import "CTScrambleManager.h"
#import "CubeScrambler.h"
#import "TwoPhaseScrambler.h"
#import "ClockScrambler.h"
#import "TwoByTwoRandomState.h"
#import "MegaminxScrambler.h"
#import "Square1Scrambler.h"
#import "PyraminxRandomStateScrambler.h"
#import "SQFullCube.h"
#import "SQSearch.h"

@implementation CTScrambleManager
@synthesize scrambler, twoPhaseScrambler, twoByTwoRandomState, square1RandomState;

-(id)init {
    if (self = [super init]) {
    }
    return self;
}

-(NSString*) scrambleForPuzzleType:(NSString *)puzzleType competitionLength:(BOOL)competitionLength {
    unichar firstChar = [puzzleType characterAtIndex:0];
    switch (firstChar) {
        case '2': {
            if (!self.twoByTwoRandomState) {
                self.twoByTwoRandomState = [[TwoByTwoRandomState alloc] init];
            }
            return [twoByTwoRandomState scramble];
            
        }
            break;
        case '3': {
            if (!self.twoPhaseScrambler) {
                self.twoPhaseScrambler = [[TwoPhaseScrambler alloc] init];
            }
            return [twoPhaseScrambler scramble];
        }
            
            break;
        case '4':
            self.scrambler = [[CubeScrambler alloc] initWithSize:4 andLength:competitionLength ? 40 : 30];
            return [scrambler generateScrambleString];
            break;
        case '5':
            self.scrambler = [[CubeScrambler alloc] initWithSize:5 andLength:competitionLength ? 60 : 30];
            return [scrambler generateScrambleString];
            break;
        case '6':
            self.scrambler = [[CubeScrambler alloc] initWithSize:6 andLength:competitionLength ? 80 : 30];
            return [scrambler generateScrambleString];
            break;
        case '7':
            self.scrambler = [[CubeScrambler alloc] initWithSize:7 andLength:competitionLength ? 100 : 30];
            return [scrambler generateScrambleString];
            break;
        case '8':
            self.scrambler = [[CubeScrambler alloc] initWithSize:8 andLength:competitionLength ? 100 : 30];
            return [scrambler generateScrambleString];
            break;
        case '9':
            self.scrambler = [[CubeScrambler alloc] initWithSize:9 andLength:competitionLength ? 100 : 30];
            return [scrambler generateScrambleString];
            break;
        case '1':
            if ([puzzleType rangeOfString:@"10"].location != NSNotFound) {
                self.scrambler = [[CubeScrambler alloc] initWithSize:10 andLength:competitionLength ? 100 : 30];
                return [scrambler generateScrambleString];
            } else {
                self.scrambler = [[CubeScrambler alloc] initWithSize:11 andLength:competitionLength ? 100 : 30];
                return [scrambler generateScrambleString];
            }
            break;
        case 'C':
            return [ClockScrambler generateScrambleString];
            break;
        case 'M': {
            MegaminxScrambler *megaminxScrambler = [[MegaminxScrambler alloc] init];
            return [megaminxScrambler generateScrambleString];
        }
            break;
        case 'S': {
            if (!self.square1RandomState) {
                self.square1RandomState = [[SQSearch alloc] init];
            }
            return [square1RandomState solution:[SQFullCube randomCube]];
        }
            break;
        case 'P': {
            PyraminxRandomStateScrambler *pyraminxScrambler = [[PyraminxRandomStateScrambler alloc] init];
            return [pyraminxScrambler scramble];
        }
        default:
            return @"No Scramble Available";
            break;
    }
    return @"No Scramble Available";
}

+(CTScrambleManager*) sharedScrambleManager {
        static dispatch_once_t pred = 0;
        __strong static CTScrambleManager *_sharedObject = nil;
        dispatch_once(&pred, ^{
            _sharedObject = [[self alloc] init]; // or some other init method
        });
        return _sharedObject;
}
@end
