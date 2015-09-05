//
//  SharedVars.c
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

#import <Foundation/Foundation.h>

int SymInv[16];
int SymMult[16][16];
int SymMove[16][18];
int Sym8Mult[8][8];
int Sym8Move[8][18];
int SymMultInv[8][8];
int SymMoveUD[16][10];

int FlipS2R[336];
int TwistS2R[324];
int EPermS2R[2768];
int permMult[24][24];
int Sym8MultInv[8][8];
int SymMoveUD[16][10];
int SymStateTwist[324];
int SymStateFlip[336];
int SymStatePerm[2768];

int MtoEPerm[40320];
BOOL ckmv2[11][10];

const int Ux1 = 0;
const int Ux2 = 1;
const int Ux3 = 2;
const int Rx1 = 3;
const int Rx2 = 4;
const int Rx3 = 5;
const int Fx1 = 6;
const int Fx2 = 7;
const int Fx3 = 8;
const int Dx1 = 9;
const int Dx2 = 10;
const int Dx3 = 11;
const int Lx1 = 12;
const int Lx2 = 13;
const int Lx3 = 14;
const int Bx1 = 15;
const int Bx2 = 16;
const int Bx3 = 17;

//Facelets
const int U1 = 0;
const int U2 = 1;
const int U3 = 2;
const int U4 = 3;
const int U5 = 4;
const int U6 = 5;
const int U7 = 6;
const int U8 = 7;
const int U9 = 8;
const int R1 = 9;
const int R2 = 10;
const int R3 = 11;
const int R4 = 12;
const int R5 = 13;
const int R6 = 14;
const int R7 = 15;
const int R8 = 16;
const int R9 = 17;
const int F1 = 18;
const int F2 = 19;
const int F3 = 20;
const int F4 = 21;
const int F5 = 22;
const int F6 = 23;
const int F7 = 24;
const int F8 = 25;
const int F9 = 26;
const int D1 = 27;
const int D2 = 28;
const int D3 = 29;
const int D4 = 30;
const int D5 = 31;
const int D6 = 32;
const int D7 = 33;
const int D8 = 34;
const int D9 = 35;
const int L1 = 36;
const int L2 = 37;
const int L3 = 38;
const int L4 = 39;
const int L5 = 40;
const int L6 = 41;
const int L7 = 42;
const int L8 = 43;
const int L9 = 44;
const int B1 = 45;
const int B2 = 46;
const int B3 = 47;
const int B4 = 48;
const int B5 = 49;
const int B6 = 50;
const int B7 = 51;
const int B8 = 52;
const int B9 = 53;

//Colors
const int U = 0;
const int R = 1;
const int F = 2;
const int D = 3;
const int L = 4;
const int B = 5;


int ud2std[] = {Ux1, Ux2, Ux3, Rx2, Fx2, Dx1, Dx2, Dx3, Lx2, Bx2};
int std2ud[18];

int Cnk[12][12];
int fact[13];
int permMult[24][24];

int e2c[] = {0, 0, 0, 0, 1, 3, 1, 3, 1, 3, 1, 3, 0, 0, 0, 0};

int urfMove[6][18] = {{0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17},
    {6, 7, 8, 0, 1, 2, 3, 4, 5,15,16,17, 9,10,11,12,13,14},
    {3, 4, 5, 6, 7, 8, 0, 1, 2,12,13,14,15,16,17, 9,10,11},
    {2, 1, 0, 5, 4, 3, 8, 7, 6,11,10, 9,14,13,12,17,16,15},
    {8, 7, 6, 2, 1, 0, 5, 4, 3,17,16,15,11,10, 9,14,13,12},
    {5, 4, 3, 8, 7, 6, 2, 1, 0,14,13,12,17,16,15,11,10, 9}};