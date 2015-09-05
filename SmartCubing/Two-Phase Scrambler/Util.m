//
//  Util.m
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

int cornerFacelet[8][3];
int edgeFacelet[12][2];

extern int fact[];
extern int Cnk[12][12];
extern const int U, D;
extern BOOL ckmv2[11][10];
extern int std2ud[18];
extern int ud2std[];
extern int permMult[24][24];

//Facelets
extern const int U1;
extern const int U2;
extern const int U3;
extern const int U4;
extern const int U5;
extern const int U6;
extern const int U7;
extern const int U8;
extern const int U9;
extern const int R1;
extern const int R2;
extern const int R3;
extern const int R4;
extern const int R5;
extern const int R6;
extern const int R7;
extern const int R8;
extern const int R9;
extern const int F1;
extern const int F2;
extern const int F3;
extern const int F4;
extern const int F5;
extern const int F6;
extern const int F7;
extern const int F8;
extern const int F9;
extern const int D1;
extern const int D2;
extern const int D3;
extern const int D4;
extern const int D5;
extern const int D6;
extern const int D7;
extern const int D8;
extern const int D9;
extern const int L1;
extern const int L2;
extern const int L3;
extern const int L4;
extern const int L5;
extern const int L6;
extern const int L7;
extern const int L8;
extern const int L9;
extern const int B1;
extern const int B2;
extern const int B3;
extern const int B4;
extern const int B5;
extern const int B6;
extern const int B7;
extern const int B8;
extern const int B9;


void toCubieCube(int f[], CubieCube *ccRet) {

    int ori;
    for (int i = 0; i < 8; i++)
        ccRet->cp[i] = 0;// invalidate corners
    for (int i = 0; i < 12; i++)
        ccRet->ep[i] = 0;// and edges
    int col1, col2;
    for (int i=0; i<8; i++) {
        // get the colors of the cubie at corner i, starting with U/D
        for (ori = 0; ori < 3; ori++)
            if (f[cornerFacelet[i][ori]] == U || f[cornerFacelet[i][ori]] == D)
                break;
        col1 = f[cornerFacelet[i][(ori + 1) % 3]];
        col2 = f[cornerFacelet[i][(ori + 2) % 3]];
        
        for (int j=0; j<8; j++) {
            if (col1 == cornerFacelet[j][1]/9 && col2 == cornerFacelet[j][2]/9) {
                // in cornerposition i we have cornercubie j
                ccRet->cp[i] = j;
                ccRet->co[i] = (int) (ori % 3);
                break;
            }
        }
    }
    for (int i=0; i<12; i++) {
        for (int j=0; j<12; j++) {
            if (f[edgeFacelet[i][0]] == edgeFacelet[j][0]/9
                && f[edgeFacelet[i][1]] == edgeFacelet[j][1]/9) {
                ccRet->ep[i] = j;
                ccRet->eo[i] = 0;
                break;
            }
            if (f[edgeFacelet[i][0]] == edgeFacelet[j][1]/9
                && f[edgeFacelet[i][1]] == edgeFacelet[j][0]/9) {
                ccRet->ep[i] = j;
                ccRet->eo[i] = 1;
                break;
            }
        }
    }
}

int binarySearch(int arr[], int key, int length) {
    if (key <= arr[length-1]) {
        int l = 0;
        int r = length-1;
        while (l <= r) {
            int mid = ((unsigned)(l+r)>>(unsigned)1);
            int val = arr[mid];
            if (key > val) {
                l = mid + 1;
            } else if (key < val) {
                r = mid - 1;
            } else {
                return mid;
            }
        }
    }
    return 0xffff;
}

int getNParity(int idx, int n) {
    int p = 0;
    for (int i=n-2; i>=0; i--) {
        p ^= idx % (n-i);
        idx /= (n-i);
    }
    return p & 1;
}

void set8Perm(int arr[], int idx) {
    int val = 0x76543210;
    for (int i=0; i<7; i++) {
        int p = fact[7-i];
        int v = idx / p;
        idx -= v*p;
        v <<= 2;
        arr[i] = (int) ((val >> v) & 07);
        int m = (1 << v) - 1;
        val = (val & m) + ((val >> 4) & ~m);
    }
    arr[7] = (int)val;
}

int get8Perm(int arr[]) {
    int idx = 0;
    int val = 0x76543210;
    for (int i=0; i<7; i++) {
        int v = arr[i] << 2;
        idx = (8 - i) * idx + ((val >> v) & 07);
        val -= 0x11111110 << v;
    }
    return idx;
}

void setNPerm(int arr[], int idx, int n) {
    arr[n-1] = 0;
    for (int i=n-2; i>=0; i--) {
        arr[i] = (int) (idx % (n-i));
        idx /= (n-i);
        for (int j=i+1; j<n; j++) {
            if (arr[j] >= arr[i])
                arr[j]++;
        }
    }
}

int getNPerm(int arr[], int n) {
    int idx=0;
    for (int i=0; i<n; i++) {
        idx *= (n-i);
        for (int j=i+1; j<n; j++) {
            if (arr[j] < arr[i]) {
                idx++;
            }
        }
    }
    return idx;
}

int getComb(int arr[], int mask) {
    int idxC = 0, idxP = 0, r = 4, val = 0x123;
    for (int i=11; i>=0; i--) {
        if ((arr[i] & 0xc) == mask) {
            int v = (arr[i] & 3) << 2;
            idxP = r * idxP + ((val >> v) & 0x0f);
            val -= 0x0111 >> (12-v);
            idxC += Cnk[i][r--];
        }
    }
    return idxP << 9 | (494 - idxC);
}

 void setComb(int arr[], int idx, int mask) {
    int r = 4, fill = 11, val = 0x123;
    int idxC = 494 - (idx & 0x1ff);
    int idxP = ((unsigned)idx >> (unsigned)9);
    for (int i=11; i>=0; i--) {
        if (idxC >= Cnk[i][r]) {
            idxC -= Cnk[i][r--];
            int p = fact[r & 3];
            int v = idxP / p << 2;
            idxP %= p;
            arr[i] = (int) (((val >> v) & 3) | mask);
            int m = (1 << v) - 1;
            val = (val & m) + ((val >> 4) & ~m);
        } else {
            if ((fill & 0xc) == mask) {
                fill -= 4;
            }
            arr[i] = (int) (fill--);
        }
    }
}

void setupUtil() {
    
     int newCornerFacelet[8][3] = { { U9, R1, F3 }, { U7, F1, L3 }, { U1, L1, B3 }, { U3, B1, R3 },
        { D3, F9, R7 }, { D1, L9, F7 }, { D7, B9, L7 }, { D9, R9, B7 } };
     int newEdgeFacelet[12][2] = { { U6, R2 }, { U8, F2 }, { U4, L2 }, { U2, B2 }, { D6, R8 }, { D2, F8 },
        { D4, L8 }, { D8, B8 }, { F6, R4 }, { F4, L6 }, { B6, L4 }, { B4, R6 } };
    for (int a = 0; a < 8; a++) {
        for (int b = 0; b < 3; b++) {
            cornerFacelet[a][b] = newCornerFacelet[a][b];
        }
    }
    for (int a = 0; a < 12; a++) {
        for (int b = 0; b < 12; b++) {
            edgeFacelet[a][b] = newEdgeFacelet[a][b];
        }
    }
    
    for (int i=0; i<10; i++) {
        std2ud[ud2std[i]] = i;
    }
    for (int i=0; i<10; i++) {
        for (int j=0; j<10; j++) {
            int ix = ud2std[i];
            int jx = ud2std[j];
            ckmv2[i][j] = (ix/3 == jx/3) || ((ix/3%3 == jx/3%3) && (ix>=jx));
        }
        ckmv2[10][i] = false;
    }
    fact[0] = 1;
    for (int i=0; i<12; i++) {
        Cnk[i][0] = Cnk[i][i] = 1;
        fact[i+1] = fact[i] * (i+1);
        for (int j=1; j<i; j++) {
            Cnk[i][j] = Cnk[i-1][j-1] + Cnk[i-1][j];
        }
    }
    int arr1[4];
    int arr2[4];
    int arr3[4];
    for (int i=0; i<24; i++) {
        for (int j=0; j<24; j++) {
            setNPerm(arr1, i, 4);
            setNPerm(arr2, j, 4);
            for (int k=0; k<4; k++) {
                arr3[k] = arr1[arr2[k]];
            }
            permMult[i][j] = getNPerm(arr3, 4);
        }
    }
}
