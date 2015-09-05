//
//  TwoPhaseScrambler
//  CubeTimer Scramblers
//

@interface TwoPhaseScrambler : NSObject

+(NSString*) generateRandomCube;
-(NSString*)scramble;

@property (nonatomic, strong) NSMutableArray *cachedScrambles;

@end
