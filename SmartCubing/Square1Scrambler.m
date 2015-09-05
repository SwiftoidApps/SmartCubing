//
//  Square1Scrambler.m
//  CubeTimer Scramblers
//
//  Adapted from Jaap Scherphuis' Square-1 scrambler with permission, as obtained from http://www.worldcubeassociation.org/regulations/scrambles.zip
//

#import "Square1Scrambler.h"

@implementation Square1Scrambler

static int posit[24];

-(id) init {
    self = [super init];
    if(self) {
        [self scramble];
    }
    return self;
}
static int seqlen = 40;
static int seq[40];    // move sequences
//var posit=[];    // piece array


-(void) scramble {
    const int defaultPosit[] = {0,0,1,2,2,3,4,4,5,6,6,7,8,9,9,10,11,11,12,13,13,14,15,15};
    for (int x = 0; x < 24; x++) {
        posit[x] = defaultPosit[x];
    }
    int i,j,ls,f;
    ls=-1;
    for (int x = 0; x < 40; x++) {
        seq[x] = 0;
    }
    f=0;
    for(i=0; i < seqlen; i++){
        do{
            if(ls==0){
                j= (randomnumber(22)) - 11;
                if(j>=0) j++;
            }else if(ls==1){
                j= (randomnumber(12)) - 11;
            }else if(ls==2){
                j=0;
            }else{
                j= (randomnumber(23)) -11;
            }
            // if past second twist, restrict bottom layer
        }while( (f>1 && j>=-6 && j<0) || [self doMove:j]);
        if(j>0) ls=1;
        else if(j<0) ls=2;
        else { ls=0; f++; }
        seq[i] = j;
    }
}

-(NSString*) generateScrambleString {
    NSMutableString *s = [NSMutableString string];
    int i,k,l=-1;
    for(i=0; i < seqlen; i++){
        k= seq[i];
        if(k==0){
            if(l==-1) [s appendString:@"(0,0) "];
            if(l==1) [s appendString:@"0) "];
            if(l==2) [s appendString:@") "];
            l=0;
        }else if(k>0){
            [s appendFormat:@"(%i,", (k>6 ? k-12 : k)];
            l=1;
        }else if(k<0){
            if(l<=0) [s appendString:@"(0,"];
            [s appendFormat:@"%i",(k<=-6?k+12:k)];
            l=2;
        }
    }
    if(l==1) [s appendString:@"0"];
    if(l!=0) [s appendString:@")"];
    return s;
}


-(bool)doMove:(int)m{
    int i,c,f=m;
    int t[12];
    //do move f
    if( f==0 ){
        for(i=0; i<6; i++){
            c= posit[i+12];
            posit[i+12]=posit[i+6];
            posit[i+6]=c;
        }
    }else if(f>0){
        f=12-f;
        if( posit[f]==posit[f-1] ) return true;
        if( f<6 && posit[f+6]==posit[f+5] ) return true;
        if( f>6 && posit[f-6]==posit[f-7] ) return true;
        if( f==6 && posit[0]==posit[11] ) return true;
        for (int x = 0; x < 12; x++) t[x] = 0;
        for(i=0;i<12;i++) t[i] = posit[i];
        c=f;
        for(i=0;i<12;i++){
            posit[i]= t[c];
            if(c==11)c=0; else c++;
        }
    }else if(f<0){
        f=-f;
        if( posit[f+12]==posit[f+11] ) return true;
        if( f<6 && posit[f+18]==posit[f+17] ) return true;
        if( f>6 && posit[f+6]==posit[f+5] ) return true;
        if( f==6 && posit[12]==posit[23] ) return true;
        for(i=0;i<12;i++) t[i] = 0;
        
        for(i=0;i<12;i++) t[i] = posit[i + 12];
        c=f;
        for(i=0;i<12;i++){
            posit[i+12] = t[c];
            if(c==11)c=0; else c++;
        }
    }
    return false;
}


@end
