//
//  TwoByTwoRandomState.m
//  CubeTimer Scramblers
//
//  Adapted from Conrad Rider and Jaap Scherphuis' Random Position 2x2x2 Scrambler, as obtained from http://www.worldcubeassociation.org/regulations/scrambles/scramble_cube_222.html
//

#import "TwoByTwoRandomState.h"

@implementation TwoByTwoRandomState

// Default settings
static const int size=2;
static const int seqlen=0;
static const int numcub=0;
static const bool mult=false;
static const bool cubeorient=false;

static int sol[10];
static UInt8 solcount = 0;

-(id) init {
    if (self = [super init]) {
        calcperm();
    }
    return self;
}

-(NSString*) scramble {
    mix2();
    return solve();
}

//The initialisation of the array is initbrd()
static int posit[] = {1,1,1,1,
    2,2,2,2,
    5,5,5,5,
    4,4,4,4,
    3,3,3,3,
    0,0,0,0};


//var seq = new Array();
BOOL solved(int c) {
    for (int i=0;i<24; i+=4){
        c=posit[i];
        for(int j=1;j<4;j++)
            if(posit[i+j]!=c) return false;
    }
    return true;
}

void mix2(){
	// Fixed cubie
	int fixed = 6;
	// Generate random permutation
	int perm_src[] = {0 , 1, 2, 3, 4, 5, 6, 7};
	int perm_sel[8];
	for(int i = 0; i < 7; i++){
        int randomRange = 7-i;
		int ch = randomnumber(randomRange);
		ch = perm_src[ch] == fixed ? (ch + 1) % (8 - i) : ch;
		perm_sel[i >= fixed ? i + 1 : i] = perm_src[ch];
		perm_src[ch] = perm_src[7 - i];
	}
	perm_sel[fixed] = fixed;
	// Generate random orientation
	int total = 0;
	int ori_sel[8];
	int i = (fixed == 0) ? 1 : 0;
	for(; i < 7; i = i == fixed - 1 ? i + 2 : i + 1){
		ori_sel[i] = randomnumber(3);
		total += ori_sel[i];
	}
	if(i <= 7) ori_sel[i] = (3 - (total % 3)) % 3;
	ori_sel[fixed] = 0;
    
	// Convert to face format
	// Mapping from permutation/orientation to facelet
	int D = 1, L = 2, B = 5, U = 4, R = 3, F = 0;
	// D 0 1 2 3  L 4 5 6 7  B 8 9 10 11  U 12 13 14 15  R 16 17 18 19  F 20 21 22 23
	// Map from permutation/orientation to face
	int fmap[8][3] = {{ U,  R,  F},{ U,  B,  R},{ U,  L,  B},{ U,  F,  L},{ D,  F,  R},{D,  R,  B},{ D,  B,  L},{ D,  L,  F}};
	// Map from permutation/orientation to facelet identifier
	int pos[8][3] = {{15, 16, 21},{13,  9, 17},{12,  5,  8},{14, 20,  4},{ 3, 23, 18},{1, 19, 11},{ 0, 10,  7},{ 2,  6, 22}};
	// Convert cubie representation into facelet representaion
	for(int i = 0; i < 8; i++){
		for(int j = 0; j < 3; j++)
			posit[pos[i][(ori_sel[i] + j) % 3]] = fmap[perm_sel[i]][j];
	}
}
// ----- [End of alternative mixing function]--------------

int piece[] = {15,16,16,21,21,15,  13,9,9,17,17,13,  14,20,20,4,4,14,  12,5,5,8,8,12,
    3,23,23,18,18,3,   1,19,19,11,11,1,  2,6,6,22,22,2,    0,10,10,7,7,0};
int adj[6][6];
int tot[] = {0,0,0,0,0,0,0};
void calcadj(){
    //count all adjacent pairs (clockwise around corners)
    int a,b;
    for(a=0;a<6;a++)for(b=0;b<6;b++) adj[a][b]=0;
    for(a=0;a<48;a+=2){
        if(posit[piece[a]]<=5 && posit[piece[a+1]]<=5 )
            adj[posit[piece[a]]][posit[piece[a+1]]]++;
    }
}
void calctot(){
    //count how many of each colour
    for(int e=0;e<24;e++) tot[posit[e]]++;
}

int mov2fc[6][12] =
{{0, 2, 3, 1, 23,19,10,6 ,22,18,11,7}, //D
    {4, 6, 7, 5, 12,20,2, 10,14,22,0, 8}, //L
    {8, 10,11,9, 12,7, 1, 17,13,5, 0, 19}, //B
    {12,13,15,14,8, 17,21,4, 9, 16,20,5 }, //U
    {16,17,19,18,15,9, 1, 23,13,11,3, 21}, //R
    {20,21,23,22,14,16,3, 6, 15,18,2, 4 }}; //F

void domove(int y){
    int q=1+(y>>4);
    int f=y&15;
    while(q){
        for(int i=0;i< 12 /*mov2fc[f].length*/;i+=4){
            int c=posit[mov2fc[f][i]];
            posit[mov2fc[f][i]]=posit[mov2fc[f][i+3]];
            posit[mov2fc[f][i+3]]=posit[mov2fc[f][i+2]];
            posit[mov2fc[f][i+2]]=posit[mov2fc[f][i+1]];
            posit[mov2fc[f][i+1]]=c;
        }
        q--;
    }
}
BOOL search(int d, int q,int t,int l,int lm);
static NSString* solve(){
    calcadj();
    int opp[6];
    for(int a=0;a<6;a++){
        for(int b=0;b<6;b++){
            if(a!=b && adj[a][b]+adj[b][a]==0) { opp[a]=b; opp[b]=a; }
        }
    }
    //Each piece is determined by which of each pair of opposite colours it uses.
    int ps[7];
    int tws[7];
    int a=0;
    for(int d=0; d<7; d++){
        int p=0;
        for(int b=a;b<a+6;b+=2){
            if(posit[piece[b]]==posit[piece[42]]) p+=4;
            if(posit[piece[b]]==posit[piece[44]]) p+=1;
            if(posit[piece[b]]==posit[piece[46]]) p+=2;
        }
        ps[d]=p;
        if(posit[piece[a]]==posit[piece[42]] || posit[piece[a]]==opp[posit[piece[42]]]) tws[d]=0;
        else if(posit[piece[a+2]]==posit[piece[42]] || posit[piece[a+2]]==opp[posit[piece[42]]]) tws[d]=1;
        else tws[d]=2;
        a+=6;
    }
    //convert position to numbers
    int q=0;
    for(int a=0;a<7;a++){
        int b=0;
        for(int c=0;c<7;c++){
            if(ps[c]==a)break;
            if(ps[c]>a)b++;
        }
        q=q*(7-a)+b;
    }
    int t=0;
    for(int a=5;a>=0;a--){
        t=t*3+tws[a]-3*floor(tws[a]/3);
    }
    
    if(q!=0 || t!=0){
        solcount = 0;
        for (int x = 0; x < 10; x++) {
            sol[x] = 0;
        }
        for(int l=seqlen;l<100;l++){
            if(search(0,q,t,l,-1)) break;
        }
        NSMutableString *solveString = [NSMutableString string];
        for(q=0;q<solcount;q++){
            char one = [@"URF" characterAtIndex:(sol[q]/10)];
            char two = [@"\'2 " characterAtIndex:(sol[q] % 10)];
            if (two == ' ') {
                [solveString insertString:[NSString stringWithFormat:@"%c%c", one, two] atIndex:0];
            } else [solveString insertString:[NSString stringWithFormat:@"%c%c ", one, two] atIndex:0];
        }
        if ([solveString characterAtIndex:solveString.length - 1] == ' ') {
            [solveString replaceCharactersInRange:NSMakeRange(solveString.length - 1, 1) withString:@""];
        }
        return solveString;
    } return nil;
}
int perm[5040];
int twst[729];
int permmv[5040][3];
int twstmv[729][3];
BOOL search(int d, int q,int t,int l,int lm){
    //searches for solution, from position q|t, in l moves exactly. last move was lm, current depth=d
    if(l==0){
        if(q==0 && t==0){
            return(true);
        }
    }else{
        if(perm[q]>l || twst[t]>l) return(false);
        int p,s,a,m;
        for(m=0;m<3;m++){
            if(m!=lm){
                p=q; s=t;
                for(a=0;a<3;a++){
                    p=permmv[p][m];
                    s=twstmv[s][m];
                    
                    if (d >= solcount) {
                        sol[solcount] = 10*m+a;
                        solcount++;
                    } else {
                        sol[d] = 10*m+a;
                     //   [sol removeObjectAtIndex:d];
                       // [sol insertObject:@(10*m+a) atIndex:d];
                    }
                  //  sol[d]=10*m+a;
                    if(search(d+1,p,s,l-1,m)) return(true);
                }
            }
        }
    }
    return(false);
}

int gettwsmv(int p, int m);
int getprmmv(int p, int m);

void calcperm(){
    //calculate solving arrays
    //first permutation
    
    for(int p=0;p<5040;p++){
        perm[p]=-1;
        for(int m=0;m<3;m++){
            permmv[p][m]=getprmmv(p,m);
        }
    }
    
    perm[0]=0;
    for(int l=0;l<=6;l++){
        int n=0;
        for(int p=0;p<5040;p++){
            if(perm[p]==l){
                for(int m=0;m<3;m++){
                    int q=p;
                    for(int c=0;c<3;c++){
                        q=permmv[q][m];
                        if(perm[q]==-1) { perm[q]=l+1; n++; }
                    }
                }
            }
        }
    }
    
    //then twist
    for(int p=0;p<729;p++){
        twst[p]=-1;
        for(int m=0;m<3;m++){
            twstmv[p][m]=gettwsmv(p,m);
        }
    }
    
    twst[0]=0;
    for(int l=0;l<=5;l++){
        int n=0;
        for(int p=0;p<729;p++){
            if(twst[p]==l){
                for(int m=0;m<3;m++){
                    int q=p;
                    for(int c=0;c<3;c++){
                        q=twstmv[q][m];
                        if(twst[q]==-1) { twst[q]=l+1; n++; }
                    }
                }
            }
        }
    }
    //remove wait sign
}
int getprmmv(int p, int m){
    
    //given position p<5040 and move m<3, return new position number
    int a,b,c,q;
    //convert number into array;
    int ps[8] = {0, 0, 0, 0, 0, 0, 0, 0} ; //Maybe?
    q=p;
    for(a=1;a<=7;a++){
        b=q%a;
        q=(q-b)/a;
        for(c=a-1;c>=b;c--) ps[c+1]=ps[c];
        ps[b]=7-a;
    }
    //perform move on array
    if(m==0){
        //U
        c=ps[0];ps[0]=ps[1];ps[1]=ps[3];ps[3]=ps[2];ps[2]=c;
    }else if(m==1){
        //R
        c=ps[0];ps[0]=ps[4];ps[4]=ps[5];ps[5]=ps[1];ps[1]=c;
    }else if(m==2){
        //F
        c=ps[0];ps[0]=ps[2];ps[2]=ps[6];ps[6]=ps[4];ps[4]=c;
    }
    //convert array back to number
    q=0;
    for(a=0;a<7;a++){
        b=0;
        for(c=0;c<7;c++){
            if(ps[c]==a)break;
            if(ps[c]>a)b++;
        }
        q=q*(7-a)+b;
    }
    return q;
}
int gettwsmv(int p, int m){
    //given orientation p<729 and move m<3, return new orientation number
    int a,b,c,d,q;
    //convert number into array;
    int ps[7];
    q=p;
    d=0;
    for(a=0;a<=5;a++){
        c =floor(q/3);
        b=q-3*c;
        q=c;
        ps[a]=b;
        d-=b;if(d<0)d+=3;
    }
    ps[6]=d;
    //perform move on array
    if(m==0){
        //U
        c=ps[0];ps[0]=ps[1];ps[1]=ps[3];ps[3]=ps[2];ps[2]=c;
    }else if(m==1){
        //R
        c=ps[0];ps[0]=ps[4];ps[4]=ps[5];ps[5]=ps[1];ps[1]=c;
        ps[0]+=2; ps[1]++; ps[5]+=2; ps[4]++;
    }else if(m==2){
        //F
        c=ps[0];ps[0]=ps[2];ps[2]=ps[6];ps[6]=ps[4];ps[4]=c;
        ps[2]+=2; ps[0]++; ps[4]+=2; ps[6]++;
    }
    //convert array back to number
    q=0;
    for(a=5;a>=0;a--){
        q=q*3+(ps[a]%3);
    }
    return(q);
}



@end
