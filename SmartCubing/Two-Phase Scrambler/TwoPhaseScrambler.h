//
//  TwoPhaseScrambler
//  CubeTimer Scramblers
//
#import <Foundation/Foundation.h>
#import "RandomNumber.h"

@interface TwoPhaseScrambler : NSObject

+(NSString*) generateRandomCube;
-(NSString*)scramble;

@property (nonatomic, strong) NSMutableArray *cachedScrambles;

@end
