//
//  CoordCube.m
//  CubeTimer Scramblers
//
//  Adapted from Chen Shuang's min2phase implementation of the Kociemba algorithm, as obtained from https://github.com/ChenShuang/min2phase
//
//  Copyright (c) 2011, Shuang Chen
//  All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  Neither the name of the creator nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "CubieCube.h"
static const int N_MOVES = 18;
static const int N_MOVES2 = 10;

static const int N_SLICE = 495;
static const int N_TWIST_SYM = 324;
static const int N_FLIP_SYM = 336;
static const int N_PERM_SYM = 2768;
static const int N_MPERM = 24;

extern int SymInv[];
extern int permMult[24][24];
extern int FlipS2R[];
extern int TwistS2R[];
extern int EPermS2R[];
extern int ud2std[];
extern int SymInv[16];
extern int SymMult[16][16];
//extern int SymMove[16][18];
extern int Sym8Mult[8][8];
extern int Sym8Move[8][18];
extern int SymMultInv[8][8];
extern int SymMoveUD[16][10];
extern int Sym8MultInv[8][8];
extern int SymStateTwist[324];
extern int SymStateFlip[336];
extern int SymStatePerm[2768];
extern int e2c[];
//XMove = Move Table
//XPrun = Pruning Table
//XConj = Conjugate Table

//phase1
int UDSliceMove[N_SLICE][N_MOVES];
int TwistMove[N_TWIST_SYM][N_MOVES];
int FlipMove[N_FLIP_SYM][N_MOVES];
int UDSliceConj[N_SLICE][8];
int UDSliceTwistPrun[N_SLICE * N_TWIST_SYM / 8 + 1];
int UDSliceFlipPrun[N_SLICE * N_FLIP_SYM / 8];
//int TwistFlipPrun[N_FLIP_SYM * N_TWIST_SYM * 8 / 8]; //Using TWIST_FLIP_PRUN

//phase2
 int CPermMove[N_PERM_SYM][N_MOVES];
 int EPermMove[N_PERM_SYM][N_MOVES2];
 int MPermMove[N_MPERM][N_MOVES2];
 int MPermConj[N_MPERM][16];
 int MCPermPrun[N_MPERM * N_PERM_SYM / 8];
 int MEPermPrun[N_MPERM * N_PERM_SYM / 8];

void setPruning(int table[], int index, int value) {
    table[index >> 3] ^= (0x0f ^ value) << ((index & 7) << 2);
}

int getPruning(int table[], int index) {
    return (table[index >> 3] >> ((index & 7) << 2)) & 0x0f;
} 

void initUDSliceMoveConj(){
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_SLICE; i++) {
        c.UDSlice = i;
        for (int j=0; j<N_MOVES; j+=3) {
            [CubieCube EdgeMultWithCubeA:c cubeB:[[CubieCube moveCube] objectAtIndex:j] cubeProd:d];
            UDSliceMove[i][j] = (int) d.UDSlice;
        }
        for (int j=0; j<16; j+=2) {
            [CubieCube EdgeConjugateWithCubeA:c idx:SymInv[j] cubeB:d];
            UDSliceConj[i][((unsigned)j >> (unsigned)1)] = (int) (d.UDSlice & 0x1ff);
        }
    }
    for (int i=0; i<N_SLICE; i++) {
        for (int j=0; j<N_MOVES; j+=3) {
            int udslice = UDSliceMove[i][j];
            for (int k=1; k<3; k++) {
                int cx = UDSliceMove[udslice & 0x1ff][j];
                udslice = permMult[udslice>>(unsigned)9][cx>>(unsigned)9]<<9|(cx&0x1ff);
                UDSliceMove[i][j+k] = (int)udslice;
            }
        }
    }
}

void initFlipMove() {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_FLIP_SYM; i++) {
        c.flip = FlipS2R[i]; 
        for (int j=0; j<N_MOVES; j++) {
            [CubieCube EdgeMultWithCubeA:c cubeB:[[CubieCube moveCube] objectAtIndex:j] cubeProd:d];
            FlipMove[i][j] = (int) d.flipSym;
        }
    }
}

void initTwistMove() {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_TWIST_SYM; i++) {
        c.twist = TwistS2R[i];
        for (int j=0; j<N_MOVES; j++) {
            [CubieCube CornMultWithCubeA:c cubeB:[[CubieCube moveCube] objectAtIndex:j] cubeProd:d];
            TwistMove[i][j] = (int)d.twistSym;
        }
    }
}

void initCPermMove() {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_PERM_SYM; i++) {
        c.CPerm = EPermS2R[i];
        for (int j=0; j<N_MOVES; j++) {
            [CubieCube CornMultWithCubeA:c cubeB:[[CubieCube moveCube] objectAtIndex:j] cubeProd:d];
            CPermMove[i][j] = (int) d.CPermSym;
        }
    }
}

void initEPermMove() {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_PERM_SYM; i++) {
        c.EPerm = EPermS2R[i];
        for (int j=0; j<N_MOVES2; j++) {
            [CubieCube EdgeMultWithCubeA:c cubeB:[[CubieCube moveCube] objectAtIndex:ud2std[j]] cubeProd:d];
            EPermMove[i][j] = (int) d.EPermSym;
        }
    }
}

void initMPermMoveConj() {
    CubieCube *c = [[CubieCube alloc] init];
    CubieCube *d = [[CubieCube alloc] init];
    for (int i=0; i<N_MPERM; i++) {
        c.MPerm = i;
        for (int j=0; j<N_MOVES2; j++) {
            [CubieCube EdgeMultWithCubeA:c cubeB:[[CubieCube moveCube] objectAtIndex:ud2std[j]] cubeProd:d];
            MPermMove[i][j] = (int) d.MPerm;
        }
        for (int j=0; j<16; j++) {
            [CubieCube EdgeConjugateWithCubeA:c idx:SymInv[j] cubeB:d];
            MPermConj[i][j] = (int) d.MPerm;
        }
    }
}
/*
void initTwistFlipPrun() {
    int depth = 0;
    int done = 8;
    BOOL inv;
    int select;
    int check;
    //		TwistFlipPrun = new int[N_FLIP_SYM * N_TWIST_SYM * 8 / 8];
    for (int i=0; i<N_FLIP_SYM*N_TWIST_SYM*8/8; i++) {
        TwistFlipPrun[i] = -1;
    }
    for (int i=0; i<8; i++) {
        setPruning(TwistFlipPrun, i, 0);
    }
    while (done < N_FLIP_SYM*N_TWIST_SYM*8) {
        inv = depth > 6;
        select = inv ? 0x0f : depth;
        check = inv ? depth : 0x0f;
        depth++;
        for (int i=0; i<N_FLIP_SYM*N_TWIST_SYM*8; i++) {
            if (getPruning(TwistFlipPrun, i) == select) {
                int twist = i / 2688;
                int flip = i % 2688;
                int fsym = i & 7;
                (unsigned)flip >>= (unsigned)3;
                for (int m=0; m<N_MOVES; m++) {
                    int twistx = TwistMove[twist][m];
                    int tsymx = twistx & 7;
                    twistx >>= (unsigned)3;
                    int flipx = FlipMove[flip][Sym8Move[fsym][m]];
                    int fsymx = Sym8MultInv[Sym8Mult[flipx & 7][fsym]][tsymx];
                    flipx >>= (unsigned)3;
                    int idx = ((twistx * 336 + flipx) << 3 | fsymx);
                    if (getPruning(TwistFlipPrun, idx) == check) {
                        done++;
                        if (inv) {
                            setPruning(TwistFlipPrun, i, depth);
                            break;
                        } else {
                            setPruning(TwistFlipPrun, idx, depth);
                            int sym = SymStateTwist[twistx];
                            int symF = SymStateFlip[flipx];
                            if (sym != 1 || symF != 1) {
                                for (int j=0; j<8; j++, symF >>= 1) {
                                    if ((symF & 1) == 1) {
                                        int fsymxx = Sym8MultInv[fsymx][j];
                                        for (int k=0; k<8; k++) {
                                            if ((sym & (1 << k)) != 0) {
                                                int idxx = twistx * 2688 + (flipx << 3 | Sym8MultInv[fsymxx][k]);
                                                if (getPruning(TwistFlipPrun, idxx) == 0x0f) {
                                                    setPruning(TwistFlipPrun, idxx, depth);
                                                    done++;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //			System.out.println(String.format("%2d%10d", depth, done));
    }
}*/

void initRawSymPrun(int PrunTable[],  int INV_DEPTH,
                            int* RawMove,  int* RawConj,
                        int *SymMove,  int* SymState,
                    int* SymSwitch,  int* moveMap,  int SYM_SHIFT, int N_RAW, int N_SYM, int N_MOVES, int N_SYMMOVES, int RawConjSize) {
    
    int SYM_MASK = (1 << SYM_SHIFT) - 1;
    int N_SIZE = N_RAW * N_SYM;
    
    for (int i=0; i<(N_RAW*N_SYM+7)/8; i++) {
        PrunTable[i] = -1;
    }
    setPruning(PrunTable, 0, 0);
    
    int depth = 0;
    int done = 1;
    static int timesHit = 0;
    static int timesHitSecond = 0;
    while (done < N_SIZE) {
        BOOL inv = depth > INV_DEPTH;
        int select = inv ? 0x0f : depth;
        int check = inv ? depth : 0x0f;
        depth++;
        for (int i=0; i<N_SIZE;) {
            int val = PrunTable[i>>3];
            if (!inv && val == -1) {
                i += 8;
                continue;
            }
            for (int end=MIN(i+8, N_SIZE); i<end; i++, val>>=4) {
                if ((val & 0x0f)/*getPruning(PrunTable, i)*/ == select) {
                    int raw = i % N_RAW;
                    int sym = i / N_RAW;
                    for (int m=0; m<N_MOVES; m++) {
                        int index = (moveMap == NULL ? m : moveMap[m]);
                        int symx = SymMove[sym * N_SYMMOVES + index]; //Watch out for this
                        int rawIndex1 = RawMove[raw * N_MOVES + m] & 0x1ff;
                        int rawx = RawConj[rawIndex1 * RawConjSize + (symx & SYM_MASK)];
                        symx >>= (unsigned)SYM_SHIFT;
                        int idx = symx * N_RAW + rawx;
                        if (getPruning(PrunTable, idx) == check) {
                            done += 1;
                            
                            timesHit += 1;
                            
                            if (inv) {
                                setPruning(PrunTable, i, depth);
                                break;
                            } else {
                                setPruning(PrunTable, idx, depth);
                                for (int j=1, symState = SymState[symx]; (symState >>= 1) != 0; j++) {
                                    if ((symState & 1) == 1) {
                                        int idxx = symx * N_RAW + RawConj[rawx * RawConjSize + j ^ (SymSwitch == NULL ? 0 : SymSwitch[j])]; //Null?
                                        if (getPruning(PrunTable, idxx) == 0x0f) {
                                            setPruning(PrunTable, idxx, depth);
                                            done++;
                                            
                                            timesHitSecond++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //			System.out.println(String.format("%2d%10d", depth, done));
    }
	
}
             
void initSliceTwistPrun() {
    initRawSymPrun(UDSliceTwistPrun, 6, (int*)UDSliceMove, (int*)UDSliceConj, (int*)TwistMove, (int*)SymStateTwist, NULL, NULL, 3, 495, 324, 18, 18, 8);
}
             
void initSliceFlipPrun() {
    initRawSymPrun(UDSliceFlipPrun, 6,
                   (int*)UDSliceMove, (int*)UDSliceConj,
                   (int*)FlipMove, (int*)SymStateFlip,
                   NULL, NULL, 3, 495, 336, 18, 18, 8
                   );
}

void initMEPermPrun() {
    initRawSymPrun(MEPermPrun, 7, 
                   (int*)MPermMove, ( int*)MPermConj,
                   (int*)EPermMove, (int*)SymStatePerm,
                   NULL, NULL, 4, 24, 2768, 10, 10, 16
                   );
}

void initMCPermPrun() {
    initRawSymPrun(MCPermPrun, 10, 
                   ( int*)MPermMove, ( int*)MPermConj,
                   ( int*)CPermMove, (int*)SymStatePerm,
                   e2c, ud2std, 4, 24, 2768, 10, 18, 16
                   );
}