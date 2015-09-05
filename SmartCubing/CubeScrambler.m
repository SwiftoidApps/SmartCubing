//
//  CubeScrambler.m
//  CubeTimer Scramblers
//
//  Adapted from Jaap Scherphuis' cube scrambler with permission, as obtained from http://www.worldcubeassociation.org/regulations/scrambles.zip
//

#import "CubeScrambler.h"

@implementation CubeScrambler
@synthesize size, seqlen;

static int numcub = 1;
static bool mult=false;

//int seq[1][1];

-(id) initWithSize:(int)sizeToSet andLength:(int)lengthToSet {
    self = [super init];
    if(self) {
        size = sizeToSet;
        seqlen = lengthToSet;
        seq = malloc(100 * sizeof(int));
        [self generateSequenceOfScrambles];
    }
    return self;
}

- (id)init
{
    return [self initWithSize:3 andLength:25];
}

// append set of moves along an axis to current sequence in order
-(int*) appendMoveSequence:(int*)sq ofCount:(int) sqIndex withAxsl:(int*)axsl andTl:(int)tl andLa:(int)la {
	for( int sl = 0; sl < tl; sl++){	// for each move type
		if(axsl[sl] != 0 /* axsl[sl]*/){				// if it occurs
			int q = (axsl[sl]-1);
            
			// get semi-axis of this move
			int sa = la;
			int m = sl;
			if(sl+sl+1>=tl){ // if on rear half of this axis
				sa+=3; // get semi-axis (i.e. face of the move)
				m=tl-1-m; // slice number counting from that face
				q=2-q; // opposite direction when looking at that face
			}
            
			// store move
            //Returning negatives = bad!
            sq[sqIndex] = (m*6+sa)*4+q;
            if (sqIndex >= seqcount) {
                seqcount++;
            }
        }
        
	}
    return sq;
}

// generate sequence of scambles
-(void)generateSequenceOfScrambles{
	//tl=number of allowed moves (twistable layers) on axis -- middle layer ignored
	int tl = size;
    seq = malloc(100 * sizeof(int));

	if(mult || (size&1)!=0 ) tl--;
	//set up bookkeeping
    int axsl[tl];
    int axam[] = {0,0,0};
	int la; // last axis moved
    
	// for each cube scramble
	for(int  n=0; n < numcub; n++){
		// initialise this scramble
		la = -1;
		// reset slice/direction counters
		for( int i=0; i<tl; i++) {
            axsl[i] = 0;
        }
		axam[0] = axam[1] = axam[2] = 0;
		int moved = 0;
        
		// while generated sequence not long enough
		while(seqcount + moved <= seqlen /*sequence length*/ ){
            //Dlog(@"[seq count] = %i", [seq count]);
			int ax, sl, q;
			do{
				do{
					// choose a random axis
                    ax = randomnumber(3);
                    
					// choose a random move type on that axis
					sl= randomnumber(tl);
					// choose random amount
					q= randomnumber(3);
                    
				}while( ax==la && axsl[(int)sl] !=0 );		// loop until have found an unused movetype
			}while( ax==la					// loop while move is reducible: reductions only if on same axis as previous moves
                   && !mult				// multislice moves have no reductions so always ok
                   && tl==size				// only even-sized cubes have reductions (odds have middle layer as reference)
                   && (
                       2*axam[0]==tl ||	// reduction if already have half the slices move in same direction
                       2*axam[1]==tl ||
                       2*axam[2]==tl ||
                       (
                        2*(axam[(int)q]+1)==tl	// reduction if move makes exactly half the slices moved in same direction and
                        &&
                        axam[0]+axam[1]+axam[2]-axam[(int)q] > 0 // some other slice also moved
						)
                       )
                   );
            
			// if now on different axis, dump cached moves from old axis
			if( ax!=la ) {
                seq = [self appendMoveSequence:seq ofCount:seqcount withAxsl:axsl andTl:tl andLa:la];
				// reset slice/direction counters
				for( int i=0; i<tl; i++)  axsl[i]=0;
				axam[0]=axam[1]=axam[2]=0;
				moved = 0;
				// remember new axis
				la=ax;
			}
            
			// adjust counters for this move
			axam[q] = axam[q] + 1;// adjust direction count
			moved++;
			axsl[(int)sl]=q+1;// mark the slice has moved amount
            
		}
		// dump the last few moves
        seq = [self appendMoveSequence:seq ofCount:seqcount withAxsl:axsl andTl:tl andLa:la];
    }
    
}

-(NSString *) generateScrambleString {
	NSMutableString *s= [NSMutableString string];
    int j;
	for(int i=0; i<(seqcount - 1); i++){
		if( i!=0 ) [s appendString:@" "];
		int k = seq[i] >>2;
        
		j = k%6;
        k=(k-j)/6;
		if( k && size<=5 && !mult ) {
            const unichar wantedChar = [@"dlburf" characterAtIndex:j];
            [s appendString:[NSString stringWithCharacters:&wantedChar length:1]];
            //	s+="dlburf".charAt(j);	// use lower case only for inner slices on 4x4x4 or 5x5x5
		}else{
			if(size<=5 && mult ){
                const unichar wantedChar = [@"DLBURF" characterAtIndex:j];
                [s appendString:[NSString stringWithCharacters:&wantedChar length:1]];
                //	s+="DLBURF".charAt(j);
				if(k>0) [s appendString:@"w"];	// use w only for double layers on 4x4x4 and 5x5x5
			}
			else{
				if(k>0) [s appendFormat:@"%i", (k+1)];
                const unichar wantedChar = [@"DLBURF" characterAtIndex:j];
                [s appendString:[NSString stringWithCharacters:&wantedChar length:1]];
				//s+="DLBURF".charAt(j);
			}
		}
        j = seq[i]&3;
		//j=seq[n][i]&3;
        if(j!=0) {
            const unichar wantedChar = [@" 2'" characterAtIndex:j];
            [s appendString:[NSString stringWithCharacters:&wantedChar length:1]];
        }
        //s+=" 2'".charAt(j);
	}
	return s;
}

-(void) dealloc {
    free(seq);
}

@end
