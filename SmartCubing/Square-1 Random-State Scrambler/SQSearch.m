//
//  SQSearch.m
//  CubeTimer Scramblers
//
//  Adapted from JFly's public domain sq12phase project, as obtained from https://github.com/cubing/tnoodle/tree/master/sq12phase/src/cs/sq12phase
//

#import "SQSearch.h"
#import "SQFullCube.h"
#import "SQShape.h"
#import "SQSquare.h"

@interface SQSearch ()

@property (nonatomic, strong) SQFullCube *c, *d;
@property (nonatomic) int length1, maxlen2;
@property (nonatomic, strong) NSString *solveString;
@property (nonatomic, strong) SQSquare *sq;

@end

@implementation SQSearch
@synthesize length1, maxlen2, c, d, sq;

static int move[100];

+(int) getNParity:(int) idx n:(int) n {
    int p = 0;
    for (int i=n-2; i>=0; i--) {
        p ^= idx % (n-i);
        idx /= (n-i);
    }
    return p & 1;
}
- (id)init
{
    self = [super init];
    if (self) {
        self.d = [[SQFullCube alloc] init];
        
        [SQShape initialise];
       // [SQSquare init];
        self.sq = [[SQSquare alloc] init];
    }
    return self;
}

/*
public static void main(String[] args) {
    long t = System.nanoTime();
    
    //		FullCube f;// = new FullCube("");
    //		System.out.println(f.getParity());
    //		System.out.println(f.getShapeIdx());
    //		System.out.println(Shape.ShapePrun[f.getShapeIdx()]);
    //		int a = Square.SquarePrun[0];
    //		Random gen = new Random(1000L);
    new Search().solution(new FullCube(""));
    System.out.println((System.nanoTime()-t)/1e9 + " seconds to initialize");
    
    
    t = System.nanoTime();
    for (int x=0; x<1000; x++) {
		
        //		System.out.println(m);
        //		System.out.println(Integer.toBinaryString(Shape.ShapeIdx[shape>>1]));
        //		System.out.println(Integer.toBinaryString(Shape.ShapeIdx[f.getShapeIdx()>>1]));
        //			assert f.getShapeIdx() == shape;
        //			f.print();
        Search s = new Search();
        //			s.solution(FullCube.randomCube());
        System.out.println(s.solution(FullCube.randomCube()));
        System.out.println((System.nanoTime()-t)/1e9/(x+1));
        //			t = System.nanoTime();
    }
    
}*/

-(NSString*) solution:(SQFullCube*) cube {
    self.c = cube;
    self.solveString = nil;
    int shape = [c getShapeIdx];
    for (length1= [SQShape ShapePrun][shape]; length1<100; length1++) {
        maxlen2 = MIN(31 - length1, 17);
        if ([self phase1:shape prunVal:[SQShape ShapePrun][shape] maxLength:length1 depth:0 lm:-1]) {
            break;
        }
    }
    return _solveString;
}

-(BOOL) phase1:(int) shape prunVal:(int)prunvalue maxLength:(int)maxl depth:(int) depth lm:(int) lm {
    
    if (prunvalue==0 && maxl<4) {
        return maxl==0 && [self init2];
    }
    
    //try each possible move. First twist;
    if (lm != 0) {
        int shapex = [SQShape TwistMove][shape];
        int prunx = [SQShape ShapePrun][shapex];
        if (prunx < maxl) {
            move[depth] = 0;
            if ([self phase1:shapex prunVal:prunx maxLength:maxl-1 depth:depth+1 lm:0]) {
                return true;
            }
        }
    }
    
    //Try top layer
    int shapex = shape;
    if(lm <= 0){
        int m = 0;
        while (true) {
            m += [SQShape TopMove][shapex];
            shapex = m >> 4;
            m &= 0x0f;
            if (m >= 12) {
                break;
            }
            int prunx = [SQShape ShapePrun][shapex];
            if (prunx > maxl) {
                break;
            } else if (prunx < maxl) {
                move[depth] = m;
                if ([self phase1:shapex prunVal:prunx maxLength:maxl-1 depth:depth+1 lm:1]) {
                    return true;
                }
            }
        }
    }
    
    shapex = shape;
    //Try bottom layer
    if(lm <= 1){
        int m = 0;
        while (true) {
            m += [SQShape BottomMove][shapex];
            shapex = m >> 4;
            m &= 0x0f;
            if (m >= 6) {
                break;
            }
            int prunx = [SQShape ShapePrun][shapex];
            if (prunx > maxl) {
                break;
            } else if (prunx < maxl) {
                move[depth] = -m;
                if ([self phase1:shapex prunVal:prunx maxLength:maxl-1 depth:depth+1 lm:2]) {
                    return true;
                }
            }
        }
    }
    
    return false;
}

//static int count = 0;


-(BOOL) init2 {
    //		System.out.print(count++);
    //		System.out.print('\r');
    [d copy:c];
    for (int i=0; i<length1; i++) {
        [d doMove:(move[i])];
    }
    assert([SQShape ShapePrun][[d getShapeIdx]] == 0);
    //		if(1==1)return false;
    //		Square sq = new Square();
    [d getSquare:(sq)];
    //TODO
    
    int edge = sq.edgeperm;
    int corner = sq.cornperm;
    int ml = sq.ml;
    //		int shp = sq.topEdgeFirst ? 0 : 1;
    //		shp |= sq.botEdgeFirst ? 0 : 2;
    
    int prun = MAX([SQSquare SquarePrun][sq.edgeperm<<1|ml], [SQSquare SquarePrun][sq.cornperm<<1|ml]);
    
    for (int i=prun; i<maxlen2; i++) {
        //			System.out.println(i);
        if (sq1phase2(edge, corner, sq.topEdgeFirst, sq.botEdgeFirst, ml, i, length1, 0)) {
            
            self.solveString = [SQSearch move2string:(i + length1)];
            
            //Unnecessary Code. Just for checking whether the solution is correct.
            	//			for (int j=0; j<i; j++) {
            	//				[d doMove:(move[length1+j])];
            	//			}
            //				System.out.println();
           // NSLog(@"%i, %X, %X, %X, %X", [d getShapeIdx], d.ul, d.ur, d.dl, d.dr);
            //				System.out.println(Integer.toHexString(d.ul));
            //				System.out.println(Integer.toHexString(d.ur));
            //				System.out.println(Integer.toHexString(d.dl));
            //				System.out.println(Integer.toHexString(d.dr));
          //  sol_string = move2string(i + length1);
           // NSLog(@"move2string: %@", [SQSearch move2string:(i + length1)]);
            return true;
        }
    }
    
    return false;
}

//static int pruncomb[100];

+(NSString*) move2string:(int) len {
    //TODO whether to invert the solution or not should be set by params.
    NSMutableString *s = [[NSMutableString alloc] init];
    int top = 0, bottom = 0;
    for (int i=len-1; i>=0; i--) {
        int val = move[i];
        if (val > 0) {
            val = 12 - val;
            top = (val > 6) ? (val-12) : val;
        } else if (val < 0) {
            val = 12 + val;
            bottom = (val > 6) ? (val-12) : val;
        } else {
            if (top == 0 && bottom == 0) {
                [s appendString:@" / "];
            } else {
                [s appendFormat:@"(%i,%i) / ", top, bottom];
            }
            top = bottom = 0;
        }
    }
    if (top == 0 && bottom == 0) {
    } else {
        [s appendFormat:@"(%i,%i)", top, bottom];
    }
    return s;// + " (" + len + "t)";
}

BOOL sq1phase2(int edge, int corner, BOOL topEdgeFirst, BOOL botEdgeFirst, int ml, int maxl, int depth, int lm) {
    if (maxl == 0 && !topEdgeFirst && botEdgeFirst/*edge==0 && corner==0 && !topEdgeFirst && botEdgeFirst && ml==0*/) {
        assert(edge==0 && corner==0 && ml==0);
        return true;
    }
    const UInt16 *TwistMove = [SQSquare TwistMove];
    const UInt16 *TopMove = [SQSquare TopMove];
    const UInt16 *BottomMove = [SQSquare BottomMove];
    const SInt16 *SquarePrun = [SQSquare SquarePrun];
    
    //try each possible move. First twist;
    if(lm!=0 && topEdgeFirst == botEdgeFirst) {
        int edgex = TwistMove[edge];
        int cornerx = TwistMove[corner];
        
        if (SquarePrun[edgex<<1|(1-ml)] < maxl && SquarePrun[cornerx<<1|(1-ml)] < maxl) {
            move[depth] = 0;
            if (sq1phase2(edgex, cornerx, topEdgeFirst, botEdgeFirst, 1-ml, maxl-1, depth+1, 0)) {
                return true;
            }
        }
    }
    
    //Try top layer
    if (lm <= 0){
        BOOL topEdgeFirstx = !topEdgeFirst;
        int edgex = topEdgeFirstx ? TopMove[edge] : edge;
        int cornerx = topEdgeFirstx ? corner : TopMove[corner];
        int m = topEdgeFirstx ? 1 : 2;
        int prun1 = SquarePrun[edgex<<1|ml];
        int prun2 = SquarePrun[cornerx<<1|ml];
        while (m < 12 && prun1 <= maxl && prun1 <= maxl) {
            if (prun1 < maxl && prun2 < maxl) {
                move[depth] = m;
                if (sq1phase2(edgex, cornerx, topEdgeFirstx, botEdgeFirst, ml, maxl-1, depth+1, 1)) {
                    return true;
                }
            }
            topEdgeFirstx = !topEdgeFirstx;
            if (topEdgeFirstx) {
                edgex = TopMove[edgex];
                prun1 = SquarePrun[edgex<<1|ml];
                m += 1;
            } else {
                cornerx = TopMove[cornerx];
                prun2 = SquarePrun[cornerx<<1|ml];
                m += 2;
            }
        }
    }
    
    if (lm <= 1){
        BOOL botEdgeFirstx = !botEdgeFirst;
        int edgex = botEdgeFirstx ? BottomMove[edge] : edge;
        int cornerx = botEdgeFirstx ? corner : BottomMove[corner];
        int m = botEdgeFirstx ? 1 : 2;
        int prun1 = SquarePrun[edgex<<1|ml];
        int prun2 = SquarePrun[cornerx<<1|ml];
        while (m < (maxl > 6 ? 6 : 12) && prun1 <= maxl && prun1 <= maxl) {
            if (prun1 < maxl && prun2 < maxl) {
                move[depth] = -m;
                if (sq1phase2(edgex, cornerx, topEdgeFirst, botEdgeFirstx, ml, maxl-1, depth+1, 2)) {
                    return true;
                }
            }
            botEdgeFirstx = !botEdgeFirstx;
            if (botEdgeFirstx) {
                edgex = BottomMove[edgex];
                prun1 = SquarePrun[edgex<<1|ml];
                m += 1;
            } else {
                cornerx = BottomMove[cornerx];
                prun2 = SquarePrun[cornerx<<1|ml];
                m += 2;
            }
        }
    }
    return false;
}


@end
