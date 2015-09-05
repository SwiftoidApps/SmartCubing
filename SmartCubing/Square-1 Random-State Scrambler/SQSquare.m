//
//  SQSquare.m
//  CubeTimer
//
//  CubeTimer Scramblers
//
//  Adapted from JFly's public domain sq12phase project, as obtained from https://github.com/cubing/tnoodle/tree/master/sq12phase/src/cs/sq12phase
//

#import "SQSquare.h"

@implementation SQSquare

static SInt16 SquarePrun[40320 * 2];			//pruning table; #twists to solve corner|edge permutation

static UInt16 SQTwistMove[40320];			//transition table for twists
static UInt16 SQTopMove[40320];			//transition table for top layer turns
static UInt16 SQBottomMove[40320];			//transition table for bottom layer turns

static int fact[] = {1, 1, 2, 6, 24, 120, 720, 5040};

+(UInt16*) TwistMove { return SQTwistMove; }
+(UInt16*) TopMove { return SQTopMove; }
+(UInt16*) BottomMove { return SQBottomMove; }

static BOOL inited = NO;

-(void) set8Perm:(SInt16*) arr idx:(int) idx {
    int val = 0x76543210;
    for (int i=0; i<7; i++) {
        int p = fact[7-i];
        int v = idx / p;
        idx -= v*p;
        v <<= 2;
        arr[i] = (SInt16) ((val >> v) & 07);
        int m = (1 << v) - 1;
        val = (val & m) + ((val >> 4) & ~m);
    }
    arr[7] = (SInt16)val;
}

-(UInt16) get8Perm:(SInt16*)arr {
    int idx = 0;
    int val = 0x76543210;
    for (int i=0; i<7; i++) {
        int v = arr[i] << 2;
        idx = (8 - i) * idx + ((val >> v) & 07);
        val -= 0x11111110 << v;
    }
    return (UInt16)idx;
}

static int Cnk[12][12];

-(int) get8Comb:(SInt16*)arr {
    int idx = 0, r = 4;
    for (int i=0; i<8; i++) {
        if (arr[i] >= 4) {
            idx += Cnk[7-i][r--];
        }
    }
    return idx;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialise];
    }
    return self;
}

-(void) initialise {
    if (inited) {
        return;
    }
    
    
    
    for (int i=0; i<12; i++) {
        Cnk[i][0] = 1;
        Cnk[i][i] = 1;
        for (int j=1; j<i; j++) {
            Cnk[i][j] = Cnk[i-1][j-1] + Cnk[i-1][j];
        }
    }
    SInt16 pos[8];
    SInt16 temp;
    
    for(int i=0;i<40320;i++){
        //twist
        [self set8Perm:pos idx:i];
        
        temp=pos[2];pos[2]=pos[4];pos[4]=temp;
        temp=pos[3];pos[3]=pos[5];pos[5]=temp;
        SQTwistMove[i]=[self get8Perm:pos];
        
        //top layer turn
        [self set8Perm:pos idx:i];
        temp=pos[0]; pos[0]=pos[1]; pos[1]=pos[2]; pos[2]=pos[3]; pos[3]=temp;
        SQTopMove[i]=[self get8Perm:pos];;
        
        //bottom layer turn
        [self set8Perm:pos idx:i];
        temp=pos[4]; pos[4]=pos[5]; pos[5]=pos[6]; pos[6]=pos[7]; pos[7]=temp;
        SQBottomMove[i]= [self get8Perm:pos];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SQSquareShapePrun" ofType:@"ctdata"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        const char *pathc =  [path cStringUsingEncoding:NSASCIIStringEncoding];
        FILE *file = NULL;
        file = fopen(pathc, "r");
        fread(SquarePrun, sizeof(UInt16), 40320*2, file);
        fclose(file);
        inited = YES;
        return;
    }
    
    for (int i=0; i<40320*2; i++) {
        SquarePrun[i] = -1;
    }
    SquarePrun[0] = 0;
    int depth = 0;
    int done = 1;
    while (done < 40320 * 2) {
        BOOL inv = depth >= 11;
        int find = inv ? -1 : depth;
        int check = inv ? depth : -1;
        ++depth;
    OUT:
        for (int i=0; i<40320*2; i++) {
            if (SquarePrun[i] == find) {
                int idx = i >> 1;
                int ml = i & 1;
                
                //try twist
                int idxx = SQTwistMove[idx]<<1 | (1-ml);
                if(SquarePrun[idxx] == check) {
                    ++done;
                    SquarePrun[inv ? i : idxx] = (SInt16) (depth);
                    if (inv) {
                        i++;
                        goto OUT;
                    }
                }
                
                //try turning top layer
                idxx = idx;
                for(int m=0; m<4; m++) {
                    idxx = SQTopMove[idxx];
                    if(SquarePrun[idxx<<1|ml] == check){
                        ++done;
                        SquarePrun[inv ? i : (idxx<<1|ml)] = (SInt16) (depth);
                        if (inv) {
                            i++;
                            goto OUT;
                        }
                    }
                }
                assert(idxx == idx);
                //try turning bottom layer
                for(int m=0; m<4; m++) {
                    idxx = SQBottomMove[idxx];
                    if(SquarePrun[idxx<<1|ml] == check){
                        ++done;
                        SquarePrun[inv ? i : (idxx<<1|ml)] = (SInt16) (depth);
                        if (inv) {
                            i++;
                            goto OUT;
                        }
                    }
                }
                
            }
        }
    }
    
    inited = YES;
}

+(SQSquare*) square {
    static dispatch_once_t pred = 0;
    __strong static SQSquare *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; 
    });
    return _sharedObject;
}

+(SInt16*) SquarePrun {
    return SquarePrun;
}

@end
