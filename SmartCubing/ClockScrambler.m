//
//  ClockScrambler.m
//  CubeTimer Scramblers
//
//  Adapted from Jaap Scherphuis' Clock scrambler with permission, as obtained from http://www.worldcubeassociation.org/regulations/scrambles.zip
//

#import "ClockScrambler.h"

@implementation ClockScrambler

+(void) prt:(int)p withString:(NSMutableString*)scrambleString {
    if(p<10) [scrambleString appendString:@" "];
    [scrambleString appendFormat:@"\%i ", p]; 
    //  document.write(p+" ");
}
+(void) prtrndpin:(NSMutableString*) scrambleString {
    [ClockScrambler prtpin:(randomnumber(2)) withString:scrambleString];
}
+(void) prtpin:(int)p withString:(NSMutableString*)scrambleString {
    NSString *charInUse = (p==0 ? @"U" : @"d");
    [scrambleString appendFormat:@"%@", charInUse];
}

+(NSString*) generateScrambleString {
    int posit[] = {0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0};
    NSMutableArray *seq = [NSMutableArray array];
    int i,j;
    NSMutableString *scrambleString = [NSMutableString string];
    
    int moves[][18] = {{1,1,1,1,1,1,0,0,0,  -1,0,-1,0,0,0,0,0,0},{0,1,1,0,1,1,0,1,1,  -1,0,0,0,0,0,-1,0,0},{0,0,0,1,1,1,1,1,1,  0,0,0,0,0,0,-1,0,-1},{1,1,0,1,1,0,1,1,0,  0,0,-1,0,0,0,0,0,-1},{0,0,0,0,0,0,1,0,1,  0,0,0,-1,-1,-1,-1,-1,-1},{1,0,0,0,0,0,1,0,0,  0,-1,-1,0,-1,-1,0,-1,-1},{1,0,1,0,0,0,0,0,0,  -1,-1,-1,-1,-1,-1,0,0,0},{0,0,1,0,0,0,0,0,1,  -1,-1,0,-1,-1,0,-1,-1,0},{0,1,1,1,1,1,1,1,1,  -1,0,0,0,0,0,-1,0,-1},{1,1,0,1,1,1,1,1,1,  0,0,-1,0,0,0,-1,0,-1},{1,1,1,1,1,1,1,1,0,  -1,0,-1,0,0,0,0,0,-1},{1,1,1,1,1,1,0,1,1,  -1,0,-1,0,0,0,-1,0,0},{1,1,1,1,1,1,1,1,1,  -1,0,-1,0,0,0,-1,0,-1},{1,0,1,0,0,0,1,0,1,  -1,-1,-1,-1,-1,-1,-1,-1,-1}};
    
    for( i=0; i<14; i++){
        [seq insertObject:@((int)((randomnumber(12))-5)) atIndex:i];
    }
         
    for( i=0; i<14; i++){
        for( j=0; j<18; j++){
            posit[j]+=[[seq objectAtIndex:i] intValue]*moves[i][j];
        }
    }
    for( j=0; j<18; j++){
        posit[j]%=12;
        while( posit[j]<=0 ) posit[j]+=12;
    }
         [scrambleString appendFormat:@"UU u=%i \ndd d=%i \n \ndU u=%i \ndU d=%i \n \ndd u=%i \nUU d=%i \n \nUd u=%i \nUd d=%i \n \ndU u=%i \nUU \n \nUd u = %i \nUU \n\nUU u=%i \nUd \n \nUU u=%i \ndU \n \nUU u=%i \nUU \n \ndd d=%i \ndd \n \n", [[seq objectAtIndex:0] intValue], [[seq objectAtIndex:4] intValue], [[seq objectAtIndex:1] intValue], [[seq objectAtIndex:5] intValue], [[seq objectAtIndex:2] intValue], [[seq objectAtIndex:6] intValue], [[seq objectAtIndex:3] intValue], [[seq objectAtIndex:7] intValue], [[seq objectAtIndex:8] intValue], [[seq objectAtIndex:9] intValue], [[seq objectAtIndex:10] intValue], [[seq objectAtIndex:11] intValue], [[seq objectAtIndex:12] intValue], [[seq objectAtIndex:13] intValue]];
    [self prtrndpin:scrambleString];
    [self prtrndpin:scrambleString];
    [scrambleString appendString:@"\n"];
    [self prtrndpin:scrambleString];
    [self prtrndpin:scrambleString];
    [scrambleString appendString:@"\n \nResult \nFront: \n"];
    for( i=0; i<9; i++){
        [self prt:posit[i] withString:scrambleString];
        if( (i%3)==2 ) [scrambleString appendString:@"\n"];
    }
    [scrambleString appendString:@"\nBack: \n"];
    for( i=0; i<9; i++){
        [self prt:(posit[i+9]) withString:scrambleString];
        if( (i%3)==2 ) [scrambleString appendString:@"\n"];
    }
    return scrambleString;
}

@end
