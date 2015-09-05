//
//  MegaminxScrambler.m
//  CubeTimer Scramblers
//
//  Adapted from Jaap Scherphuis' Megaminx scrambler with permission, as obtained from http://www.worldcubeassociation.org/regulations/scrambles.zip
//

#import "MegaminxScrambler.h"

@implementation MegaminxScrambler
- (id)init
{
    self = [super init];
    if (self) {
        [self scramble];
        // Initialization code here.
    }
    
    return self;
}

static const int linelen=10;
static const int linenbr=7;


-(void) scramble {
	int i;
    seq = [NSMutableArray array];
    for(i=0; i<linenbr*linelen; i++){
        [seq insertObject:@((int)(randomnumber(2))) atIndex:i];
    }

}

-(NSString*) generateScrambleString{
    NSMutableString *s = [NSMutableString string];
	int i,j;
	for(j=0; j<linenbr; j++){
		for(i=0; i<linelen; i++){
			if (i%2)
			{
				if ([[seq objectAtIndex:j*linelen + i] intValue] != 0) [s appendString:@"D++ "];
				else [s appendString:@"D-- "];
			}
			else
			{
				if ([[seq objectAtIndex:j*linelen + i] intValue] != 0) [s appendString:@"R++ "];
				else [s appendString:@"R-- "];
			}
		}
		if ([[seq objectAtIndex:(j+1)*linelen - 1] intValue] != 0) [s appendString:@"U \n"];
		else [s appendString:@"U' \n"];
	}
	return s;
}


@end
