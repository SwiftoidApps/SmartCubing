//
//  PyraminxRandomStateScrambler.m
//  CubeTimer
//
//  Created by Thomas Roughton on 18/11/12.
//  Copyright (c) 2012 Ingenero Apps. All rights reserved.
//

#import "PyraminxRandomStateScrambler.h"

@interface PyraminxRandomStateScrambler ()

@property (nonatomic, strong) NSMutableArray *seq, *colors, *sol;
@property (nonatomic, strong) NSMutableString *scramblestring;

@end

@implementation PyraminxRandomStateScrambler
@synthesize seq, colors, sol, scramblestring;
/* Base script written by Jaap Scherphuis, jaapsch a t yahoo d o t com */
/* Javascript written by Syoji Takamatsu, , red_dragon a t honki d o t net */
/* Random-State modification by Lucas Garron (lucasg a t gmx d o t de / garron.us) in collaboration with Michael Gottlieb (mzrg.com)*/
/* Optimal modification by Michael Gottlieb (qqwref a t gmail d o t com) from Jaap's code */
/* Version 1.0*/

static const int numcub = 1;



static int colmap[] = {1,1,1,1,1,0,2,0,3,3,3,3,3,
    0,1,1,1,0,2,2,2,0,3,3,3,0,
    0,0,1,0,2,2,2,2,2,0,3,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,4,4,4,4,4,0,0,0,0,
    0,0,0,0,0,4,4,4,0,0,0,0,0,
    0,0,0,0,0,0,4,0,0,0,0,0,0};


-(NSString*) scramble
{
    
        [self initbrd];
        [self calcperm];
        [self dosolve];
        
    self.scramblestring = [NSMutableString string];
    //[self init_colors];
    static const char *primeOrNot[] = {"", "'"};
        for (int i=0;i<sol.count;i++) {
            
            [scramblestring appendFormat:@"%c%s ", "ULRB"[[[sol objectAtIndex:i] intValue]&7], primeOrNot[([[sol objectAtIndex:i] intValue]&8)/8]];
            //scramblestring += ["U","L","R","B"][sol[i]&7] + primeOrNot[(sol[i]&8)/8] + " ";
            int threethousandtwelve[] = {3, 0, 1, 2};
            [self picmove:(threethousandtwelve[[[sol objectAtIndex:i] intValue]&7]) direction:(1+([[sol objectAtIndex:i] intValue]&8)/8)];
        }
        char tips[] = "lrbu"; 
        for (int i=0;i<4;i++) {
            int j = floor(randomnumber(3));
            if (j < 2) {
                [scramblestring appendFormat:@"%c%s ", tips[i], primeOrNot[j]];
                [self picmove:4+1 direction:1+j];
            }
        }
    return scramblestring;
}

static int posit[36];
static int perm[720];   // pruning table for edge permutation
static int twst[2592];   // pruning table for edge orientation+twist
static int permmv[720][4]; // transition table for edge permutation
static int twstmv[2592][4]; // transition table for edge orientation+twist
static int pcperm[6];
static int pcori[10];

-(void) initbrd {
    self.sol = [NSMutableArray array];
    static int positToSet[] = {0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3};
    for (int i = 0; i < 36; i++) {
        posit[i] = positToSet[i];
    }
    static int pcpermToSet[] = {0,1,2,3,4,5};
    for (int i = 0; i < 6; i++) {
        pcperm[i] = pcpermToSet[i];
    }
}

-(BOOL) solved {
    for (int i=1;i<9; i++){
        if( posit[i   ]!=posit[0 ] ) return(false);
        if( posit[i+9 ]!=posit[9 ] ) return(false);
        if( posit[i+18]!=posit[18] ) return(false);
        if( posit[i+27]!=posit[27] ) return(false);
    }
    return(true);
}

//static int edges[] = {2,11, 1,20, 4,31, 10,19, 13,29, 22,28};

static int movelist[4][12] =
{{0, 18,9,   6, 24,15,  1, 19,11,  2, 20,10},  //U
    {23,3, 30,  26,7, 34,  22,1, 31,  20,4, 28},  //L
    {5, 14,32,  8, 17,35,  4, 11,29,  2, 13,31},  //R
    {12,21,27,  16,25,33,  13,19,28,  10,22,29}};  //B

-(void) domove:(int)m {
    for(int i=0;i<12; i+=3){
        int c=posit[movelist[m][i]];
        posit[movelist[m][i  ]]=posit[movelist[m][i+2]];
        posit[movelist[m][i+2]]=posit[movelist[m][i+1]];
        posit[movelist[m][i+1]]=c;
    }
}

-(void) dosolve {
    int a,b,c,l,t=0,q=0;
    // Get a random permutation and orientation.
    int parity = 0;
    for (int i=0;i<4;i++) {
        int other = i + floor(randomnumber(6-i));
        int temp = pcperm[i];
        pcperm[i] = pcperm[other];
        pcperm[other] = temp;
        if (i != other) parity++;
    }
    if (parity%2 == 1) {
        int temp = pcperm[4];
        pcperm[4] = pcperm[5];
        pcperm[5] = temp;
    }
    parity=0;
    for (int i = 0; i < 10; i++) {
        pcori[i] = 0;
    }
    for (int i=0;i<5;i++) {
        pcori[i] = floor(randomnumber(2));
        parity += pcori[i];
    }
    pcori[5] = parity % 2;
    for (int i=6;i<10;i++) {
        pcori[i] = floor(randomnumber(3));
    }
    
    for(a=0;a<6;a++){
        b=0;
        for(c=0;c<6;c++){
            if(pcperm[c]==a)break;
            if(pcperm[c]>a)b++;
        }
        q=q*(6-a)+b;
    }
    //corner orientation
    for(a=9;a>=6;a--){
        t=t*3+pcori[a];
    }
    //edge orientation
    for(a=4;a>=0;a--){
        t=t*2+pcori[a];
    }
    
    // solve it
    if(q!=0 || t!=0){
        for(l=7;l<12;l++){  //allow solutions from 7 through 11 moves
            if([self searchFromPosition:q and:t inMoves:l withLastMove:-1]) break;
        }
    }
}

-(BOOL) searchFromPosition:(int)q and:(int)t inMoves:(int)l withLastMove:(int)lm {
    //searches for solution, from position q|t, in l moves exactly. last move was lm, current depth=d
    if(l==0){
        if(q==0 && t==0){
            return(true);
        }
    }else{
        if(perm[q]>l || twst[t]>l) return(false);
        int p,s,a,m;
        for(m=0;m<4;m++){
            if(m!=lm){
                p=q; s=t;
                for(a=0;a<2;a++){
                    p=permmv[p][m];
                    s=twstmv[s][m];
                    [sol addObject:@(m+8*a)];
                    if([self searchFromPosition:p and:s inMoves:l-1 withLastMove:m]) return(true);
                    [sol removeLastObject];
                }
            }
        }
    }
    return(false);
}


-(void) calcperm {
    int c,p,q,l,m,n;
    //calculate solving arrays
    //first permutation
    // initialise arrays
    for(p=0;p<720;p++){
        perm[p]=-1;
        for(m=0;m<4;m++){
            permmv[p][m]=[self getprmmv:p move:m];
        }
    }
    //fill it
    perm[0]=0;
    for(l=0;l<=6;l++){
        n=0;
        for(p=0;p<720;p++){
            if(perm[p]==l){
                for(m=0;m<4;m++){
                    q=p;
                    for(c=0;c<2;c++){
                        q=permmv[q][m];
                        if(perm[q]==-1) { perm[q]=l+1; n++; }
                    }
                }
            }
        }
    }
    //then twist
    // initialise arrays
    for(p=0;p<2592;p++){
        twst[p]=-1;
        for(m=0;m<4;m++){
            twstmv[p][m]= [self gettwsmv:p move:m]; 
        }
    }
    //fill it
    twst[0]=0;
    for(l=0;l<=5;l++){
        n=0;
        for(p=0;p<2592;p++){
            if(twst[p]==l){
                for(m=0;m<4;m++){
                    q=p;
                    for(c=0;c<2;c++){
                        q=twstmv[q][m];
                        if(twst[q]==-1) { twst[q]=l+1; n++; }
                    }
                }
            }
        }
    }
}

-(int) getprmmv:(int)p move:(int)m {
    //given position p<720 and move m<4, return new position number
    
    //convert number into array
    int a = 0, b = 0, c = 0;
    int ps[7];
    int q=p;
    for(a=1;a<=6;a++){
        c= floor(q/a);
        b=q-a*c;
        q=c;
        for(c=a-1;c>=b;c--) ps[c+1]=ps[c];
        ps[b]=6-a;
    }
    //perform move on array
    if(m==0){
        //U
        [self cycle3:ps i1:0 i2:3 i3:1];
    }else if(m==1){
        //L
        [self cycle3:ps i1:1 i2:5 i3:2];
    }else if(m==2){
        //R
        [self cycle3:ps i1:0 i2:2 i3:4];
    }else if(m==3){
        //B
        [self cycle3:ps i1:3 i2:4 i3:5];
    }
    //convert array back to number
    q=0;
    for(a=0;a<6;a++){
        b=0;
        for(c=0;c<6;c++){
            if(ps[c]==a)break;
            if(ps[c]>a)b++;
        }
        q=q*(6-a)+b;
    }
    return(q);
}
-(int) gettwsmv:(int)p move:(int)m{
    //given position p<2592 and move m<4, return new position number
    
    //convert number into array;
    int a,b,c,d=0;
    int ps[10];
    int q=p;
    
    //first edge orientation
    for(a=0;a<=4;a++){
        ps[a]=q&1;
        q>>=1;
        d^=ps[a];
    }
    ps[5]=d;
    
    //next corner orientation
    for(a=6;a<=9;a++){
        c=floor(q/3);
        b=q-3*c;
        q=c;
        ps[a]=b;
    }
    
    //perform move on array
    if(m==0){
        //U
        ps[6]++; if(ps[6]==3) ps[6]=0;
        [self cycle3:ps i1:0 i2:3 i3:1];
        ps[1]^=1;ps[3]^=1;
    }else if(m==1){
        //L
        ps[7]++; if(ps[7]==3) ps[7]=0;
        [self cycle3:ps i1:1 i2:5 i3:2];
        ps[2]^=1; ps[5]^=1;
    }else if(m==2){
        //R
        ps[8]++; if(ps[8]==3) ps[8]=0;
        [self cycle3:ps i1:0 i2:2 i3:4];
        ps[0]^=1; ps[2]^=1;
    }else if(m==3){
        //B
        ps[9]++; if(ps[9]==3) ps[9]=0;
        [self cycle3:ps i1:3 i2:4 i3:5];
        ps[3]^=1; ps[4]^=1;
    }
    //convert array back to number
    q=0;
    //corner orientation
    for(a=9;a>=6;a--){
        q=q*3+ps[a];
    }
    //corner orientation
    for(a=4;a>=0;a--){
        q=q*2+ps[a];
    }
    return(q);
}

-(void) picmove:(int)type direction:(int)direction{
    switch(type) {
        case 0: // L
            [self rotate3:14 v2:58 v3:18 clockwise:direction];
            [self rotate3:15 v2:57 v3:31 clockwise:direction];
            [self rotate3:16 v2:70 v3:32 clockwise:direction];
            [self rotate3:30 v2:28 v3:56 clockwise:direction];
            break;
        case 1: // R
            [self rotate3:32 v2:72 v3:22 clockwise:direction];
            [self rotate3:33 v2:59 v3:23 clockwise:direction];
            [self rotate3:20 v2:58 v3:24 clockwise:direction];
            [self rotate3:34 v2:60 v3:36 clockwise:direction];
            
            break;
        case 2: // B
            
            [self rotate3:14 v2:10 v3:72 clockwise:direction];
            [self rotate3:1 v2:11 v3:71 clockwise:direction];
            [self rotate3:2 v2:24 v3:70 clockwise:direction];
            [self rotate3:0 v2:12 v3:84 clockwise:direction];
            
            break;
        case 3: // U
            
            [self rotate3:2 v2:18 v3:22 clockwise:direction];
            [self rotate3:3 v2:19 v3:9 clockwise:direction];
            [self rotate3:16 v2:20 v3:10 clockwise:direction];
            [self rotate3:4 v2:6 v3:8 clockwise:direction];
            
            break;
        case 4: // l
            [self rotate3:30 v2:28 v3:56 clockwise:direction];
            break;
        case 5: // r
            [self rotate3:34 v2:60 v3:36 clockwise:direction];
            break;
        case 6: // b
            [self rotate3:0 v2:12 v3:84 clockwise:direction];
            break;
        case 7: // u
            [self rotate3:4 v2:6 v3:8 clockwise:direction];
            break;
    }
}

-(void) rotate3:(int)v1 v2:(int)v2 v3:(int)v3 clockwise:(int)clockwise
{
    if(clockwise == 2) {
        [self cycle3:colmap i1:v3 i2:v2 i3:v1];
    } else {
        [self cycle3:colmap i1:v1 i2:v2 i3:v3];
    }
}

-(void) cycle3:(int*)arr i1:(int)i1 i2:(int)i2 i3:(int) i3 {
    int c = arr[i1];
    arr[i1] = arr[i2];
    arr[i2] = arr[i3];
    arr[i3] = c;
}



@end
