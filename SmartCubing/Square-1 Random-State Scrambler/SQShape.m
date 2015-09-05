//
//  SQShape.m
//  CubeTimer Scramblers
//
//  Adapted from JFly's public domain sq12phase project, as obtained from https://github.com/cubing/tnoodle/tree/master/sq12phase/src/cs/sq12phase
//

#import "SQShape.h"
#import "Util.h"

@implementation SQShape
@synthesize top, bottom, parity;

//1 = corner, 0 = edge.
static int halflayer[] = {0x00, 0x03, 0x06, 0x0c, 0x0f, 0x18, 0x1b, 0x1e,
    0x30, 0x33, 0x36, 0x3c, 0x3f};

static int ShapeIdx[3678];
static int ShapePrun[3768 * 2];

static int TopMove[3678 * 2];
static int BottomMove[3678 * 2];
static int TwistMove[3678 * 2];

unsigned int bitCount(unsigned int v) {
   // unsigned int v; // count bits set in this (32-bit value)
    unsigned int c; // store the total here
    
    c = v - ((v >> 1) & 0x55555555);
    c = ((c >> 2) & 0x33333333) + (c & 0x33333333);
    c = ((c >> 4) + c) & 0x0F0F0F0F;
    c = ((c >> 8) + c) & 0x00FF00FF;
    c = ((c >> 16) + c) & 0x0000FFFF;
    return c;
}

+(int*) ShapeIdx { return ShapeIdx; }

+(int*) ShapePrun { return ShapePrun; }

+(int*) TwistMove { return TwistMove; }
+(int*) TopMove { return TopMove; }
+(int*) BottomMove {return  BottomMove; }

+(int) getShape2Idx:(int) shp {
    int ret = binarySearch(ShapeIdx, shp & 0xffffff, 3678) <<1 | shp>>24;
    return ret;
}

-(int) getIdx {
    int ret = binarySearch(ShapeIdx, top<<12|bottom, 3678)<<1|parity;
    return ret;
}

-(void) setIdx:(int)idx {
    parity = idx & 1;
    top = ShapeIdx[idx >> 1];
    bottom = top & 0xfff;
    top >>= 12;
}

-(int) topMove {
    int move = 0;
    int moveParity = 0;
    do {
        if ((top & 0x800) == 0) {
            move += 1;
            top = top << 1;
        } else {
            move += 2;
            top = (top << 2) ^ 0x3003;
        }
        moveParity = 1 - moveParity;
    } while ((bitCount(top & 0x3f) & 1) != 0);
    if ((bitCount(top)&2)==0) {
        parity ^= moveParity;
    }
    return move;
}

-(int) bottomMove {
    int move = 0;
    int moveParity = 0;
    do {
        if ((bottom & 0x800) == 0) {
            move +=1;
            bottom = bottom << 1;
        } else {
            move +=2;
            bottom = (bottom << 2) ^ 0x3003;
        }
        moveParity = 1 - moveParity;
    } while ((bitCount(bottom & 0x3f) & 1) != 0);
    if ((bitCount(bottom)&2)==0) {
        parity ^= moveParity;
    }
    return move;
}

-(void) twistMove {
    int temp = top & 0x3f;
    
    int p1 = bitCount(temp);
    int p3 = bitCount(bottom&0xfc0);
    parity ^= 1 & ((p1&p3)>>1);
    
    top = (top & 0xfc0) | ((bottom >> 6) & 0x3f);
    bottom = (bottom & 0x3f) | temp << 6;
}


+(void) initialise {
    static BOOL alreadyInited = NO;
    if (alreadyInited) {
        return;
    }
    int count = 0;
    for (int i=0; i<13*13*13*13; i++) {
        int dr = halflayer[i % 13];
        int dl = halflayer[i / 13 % 13];
        int ur = halflayer[i / 13 / 13 % 13];
        int ul = halflayer[i / 13 / 13 / 13];
        int value = ul<<18|ur<<12|dl<<6|dr;
        if (bitCount(value) == 16) {
            ShapeIdx[count++] = value;
        }
    }
    SQShape *s = [[SQShape alloc] init];
    for (int i=0; i<3678*2; i++) {
        [s setIdx:i];
        TopMove[i] = s.topMove;
        TopMove[i] |= [s getIdx] << 4;
        [s setIdx:i];
        BottomMove[i] = s.bottomMove;
        BottomMove[i] |= [s getIdx] << 4;
        [s setIdx:(i)];
        [s twistMove];
        TwistMove[i] = [s getIdx];
    }
    for (int i=0; i<3768*2; i++) {
        ShapePrun[i] = -1;
    }
    
    //0 110110110110 011011011011
    //1 110110110110 110110110110
    //1 011011011011 011011011011
    //0 011011011011 110110110110
    ShapePrun[[SQShape getShape2Idx:(0x0db66db)]] = 0;
    ShapePrun[[SQShape getShape2Idx:(0x1db6db6)]] = 0;
    ShapePrun[[SQShape getShape2Idx:(0x16db6db)]] = 0;
    ShapePrun[[SQShape getShape2Idx:(0x06dbdb6)]] = 0;
    int done = 4;
    int done0 = 0;
    int depth = -1;
    while (done != done0) {
        done0 = done;
        ++depth;
        for (int i=0; i<3768*2; i++) {
            if (ShapePrun[i] == depth) {
                // try top
                int m = 0;
                int idx = i;
                do {
                    idx = TopMove[idx];
                    m += idx & 0xf;
                    idx >>= 4;
                    if (ShapePrun[idx] == -1) {
                        ++done;
                        ShapePrun[idx] = depth + 1;
                    }
                } while (m != 12);
                
                // try bottom
                m = 0;
                idx = i;
                do {
                    idx = BottomMove[idx];
                    m += idx & 0xf;
                    idx >>= 4;
                    if (ShapePrun[idx] == -1) {
                        ++done;
                        ShapePrun[idx] = depth + 1;
                    }
                } while (m != 12);
                
                // try twist
                idx = TwistMove[i];
                if (ShapePrun[idx] == -1) {
                    ++done;
                    ShapePrun[idx] = depth + 1;
                }
            }
        }
    }
    alreadyInited = YES;
}


@end
