//
//  SQFullCube.m
//  CubeTimer Scramblers
//
//  Adapted from JFly's public domain sq12phase project, as obtained from https://github.com/cubing/tnoodle/tree/master/sq12phase/src/cs/sq12phase
//

#import "SQFullCube.h"
#import "SQSquare.h"
#import "SQShape.h"

@interface SQFullCube ()

@property (nonatomic) SInt16 *prm;
@property (nonatomic) int *arr;

@end

@implementation SQFullCube
@synthesize ul, ur, dl, dr, ml, prm, arr;
- (id)init
{
    self = [super init];
    if (self) {
        self.ul = 0x011233;
        self.ur = 0x455677;
        self.dl = 0x998bba;
        self.dr = 0xddcffe;
        self.ml = 0;
        self.prm = malloc(sizeof(SInt16) * 8);
        self.arr = malloc(sizeof(int) * 16);
    }
    return self;
}

-(void) dealloc {
    free(prm);
    free(arr);
}

-(int) compareTo:(SQFullCube*) f {
    if (ul != f.ul) {
        return ul - f.ul;
    }
    if (ur != f.ur) {
        return ur - f.ur;
    }
    if (dl != f.dl) {
        return dl - f.dl;
    }
    if (dr != f.dr) {
        return dr - f.dr;
    }
    return ml - f.ml;
}


+(SQFullCube*) randomCube {
    int shape = [SQShape ShapeIdx][randomnumber(3678)];
    SQFullCube *f = [[SQFullCube alloc] init];
    int corner = 0x01234567 << 1 | 0x11111111;
    int edge = 0x01234567 << 1;
    int n_corner = 8, n_edge = 8;
    int rnd, m;
    for (int i=0; i<24; i++) {
        if (((shape >> i) & 1) == 0) {//edge
            rnd = randomnumber(n_edge) << 2;
            [f setPiece:23-i value:((edge >> rnd) & 0xf)];
            m = (1 << rnd) - 1;
            edge = (edge & m) + ((edge >> 4) & ~m);
            --n_edge;
        } else {//corner
            rnd = randomnumber(n_corner) << 2;
            [f setPiece:23-i value:((corner >> rnd) & 0xf)];
            [f setPiece:22-i value:((corner >> rnd) & 0xf)];
            m = (1 << rnd) - 1;
            corner = (corner & m) + ((corner >> 4) & ~m);
            --n_corner;
            ++i;
        }
    }
    f.ml = randomnumber(2);
    return f;
}

-(void) copy:(SQFullCube *)c {
    self.ul = c.ul;
    self.ur = c.ur;
    self.dl = c.dl;
    self.dr = c.dr;
    self.ml = c.ml;
}

/**
 * @param move
 * 0 = twist
 * [1, 11] = top move
 * [-1, -11] = bottom move
 * for example, 6 == (6, 0), 9 == (-3, 0), -4 == (0, 4)
 */
-(void) doMove:(int) move {
    move <<= 2;
    if (move > 24) {
        move = 48 - move;
        int temp = ul;
        ul = (ul>>move | ur<<(24-move)) & 0xffffff;
        ur = (ur>>move | temp<<(24-move)) & 0xffffff;
    } else if (move > 0) {
        int temp = ul;
        ul = (ul<<move | ur>>(24-move)) & 0xffffff;
        ur = (ur<<move | temp>>(24-move)) & 0xffffff;
    } else if (move == 0) {
        int temp = ur;
        ur = dl;
        dl = temp;
        ml = 1-ml;
    } else if (move >= -24) {
        move = -move;
        int temp = dl;
        dl = (dl<<move | dr>>(24-move)) & 0xffffff;
        dr = (dr<<move | temp>>(24-move)) & 0xffffff;
    } else if (move < -24) {
        move = 48 + move;
        int temp = dl;
        dl = (dl>>move | dr<<(24-move)) & 0xffffff;
        dr = (dr>>move | temp<<(24-move)) & 0xffffff;
    }
}

-(SInt16) pieceAt:(int) idx {
    int ret;
    if (idx < 6) {
        ret = ul >> ((5-idx) << 2);
    } else if (idx < 12) {
        ret = ur >> ((11-idx) << 2);
    } else if (idx < 18) {
        ret = dl >> ((17-idx) << 2);
    } else {
        ret = dr >> ((23-idx) << 2);
    }
    return (SInt16) (ret & 0x0f);
}

-(void) setPiece:(int)idx value:(int) value {
    if (idx < 6) {
        ul &= ~(0xf << ((5-idx) << 2));
        ul |= value << ((5-idx) << 2);
    } else if (idx < 12) {
        ur &= ~(0xf << ((11-idx) << 2));
        ur |= value << ((11-idx) << 2);
    } else if (idx < 18) {
        dl &= ~(0xf << ((17-idx) << 2));
        dl |= value << ((17-idx) << 2);
    } else {
        dr &= ~(0xf << ((23-idx) << 2));
        dr |= value << ((23-idx) << 2);
    }
}


-(int) getParity {
    //		int[] arr = new int[16];
    int cnt = 0;
    arr[0] = [self pieceAt:0];
    for (int i=1; i<24; i++) {
        if ([self pieceAt:i] != arr[cnt]) {
            arr[++cnt] = [self pieceAt:i];
        }
    }
    int p = 0;
    for (int a=0; a<16; a++){
        for(int b=a+1 ; b<16 ; b++){
            if (arr[a] > arr[b]) p^=1;
        }
    }
    return p;
}

-(int) getShapeIdx {
    int urx = ur & 0x111111;
    urx |= urx >> 3;
    urx |= urx >> 6;
    urx = (urx&0xf) | ((urx>>12)&0x30);
    int ulx = ul & 0x111111;
    ulx |= ulx >> 3;
    ulx |= ulx >> 6;
    ulx = (ulx&0xf) | ((ulx>>12)&0x30);
    int drx = dr & 0x111111;
    drx |= drx >> 3;
    drx |= drx >> 6;
    drx = (drx&0xf) | ((drx>>12)&0x30);
    int dlx = dl & 0x111111;
    dlx |= dlx >> 3;
    dlx |= dlx >> 6;
    dlx = (dlx&0xf) | ((dlx>>12)&0x30);
    return [SQShape getShape2Idx:([self getParity]<<24 | ulx<<18 | urx<<12 | dlx<<6 | drx)];
}

/*void print() {
    System.out.println(Integer.toHexString(ul));
    System.out.println(Integer.toHexString(ur));
    System.out.println(Integer.toHexString(dl));
    System.out.println(Integer.toHexString(dr));
}*/


-(void) getSquare:(SQSquare*) sq {
    //TODO
    //		byte[] prm = new byte[8];
    for (int a=0;a<8;a++) {
        prm[a] = (SInt16) ([self pieceAt:(a*3+1)]>>1);
    }
    //convert to number
    sq.cornperm = [[SQSquare square] get8Perm:prm];
    
    int a, b;
    //Strip top layer edges
    sq.topEdgeFirst = [self pieceAt:0] == [self pieceAt:1];
    a = sq.topEdgeFirst ? 2 : 0;
    for(b=0; b<4; a+=3, b++) prm[b]=(SInt16)([self pieceAt:(a)] >> 1);
    
    sq.botEdgeFirst = [self pieceAt:12] == [self pieceAt:13];
    a = sq.botEdgeFirst ? 14 : 12;
    
    //		if(pieceAt(12)==pieceAt(13)){ a=14; sq.botEdgeFirst=false; }
    //		else{ a=12; sq.botEdgeFirst=true;  }
    for( ; b<8; a+=3, b++) prm[b]=(SInt16)([self pieceAt:(a)]>>1);
    sq.edgeperm= [[SQSquare square] get8Perm:prm];
    
    
    sq.ml = ml;
}

@end
