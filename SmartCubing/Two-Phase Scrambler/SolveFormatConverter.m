//
//  SolveFormatConverter.m
//  CubeTimer Scramblers
//

#import "SolveFormatConverter.h"

NSString* edgesAndCornersToSequential(char* edgesAndCorners) {
    char sequential[] = {
        edgesAndCorners[44],
        edgesAndCorners[6],
        edgesAndCorners[40],
        edgesAndCorners[9],
        'U',
        edgesAndCorners[3],
        edgesAndCorners[48],
        edgesAndCorners[0],
        edgesAndCorners[36],
        edgesAndCorners[38],
        edgesAndCorners[4],
        edgesAndCorners[41],
        edgesAndCorners[25],
        'R',
        edgesAndCorners[31],
        edgesAndCorners[53],
        edgesAndCorners[16],
        edgesAndCorners[66],
        edgesAndCorners[50],
        edgesAndCorners[1],
        edgesAndCorners[37],
        edgesAndCorners[27],
        'F',
        edgesAndCorners[24],
        edgesAndCorners[57],
        edgesAndCorners[13],
        edgesAndCorners[54],
        edgesAndCorners[56],
        edgesAndCorners[12],
        edgesAndCorners[52],
        edgesAndCorners[21],
        'D',
        edgesAndCorners[15],
        edgesAndCorners[60],
        edgesAndCorners[18],
        edgesAndCorners[64],
        edgesAndCorners[46],
        edgesAndCorners[10],
        edgesAndCorners[49],
        edgesAndCorners[34],
        'L',
        edgesAndCorners[28],
        edgesAndCorners[61],
        edgesAndCorners[22],
        edgesAndCorners[58],
        edgesAndCorners[42], //45?
        edgesAndCorners[7],
        edgesAndCorners[45], //42?
        edgesAndCorners[30],
        'B',
        edgesAndCorners[33],
        edgesAndCorners[65],
        edgesAndCorners[19],
        edgesAndCorners[62],
        '\0' };
    NSString *stringToReturn = [[NSString alloc] initWithCString:sequential encoding:NSASCIIStringEncoding];
    return stringToReturn; 
}

NSString* sequentialToEdgesAndCorners(char* sequential) {
    char edgesAndCorners[] = { sequential[7], sequential[19], ' ', sequential[5], sequential[10], ' ', sequential[1], sequential[46], ' ', sequential[3], sequential[37], ' ', sequential[28], sequential[25], ' ', sequential[32], sequential[16], ' ', sequential[34], sequential[52], ' ', sequential[30], sequential[43], ' ', sequential[23], sequential[12], ' ', sequential[21], sequential[41], ' ', sequential[48], sequential[14], ' ', sequential[50], sequential[39], ' ', sequential[8], sequential[20], sequential[9], ' ', sequential[2], sequential[11], sequential[45], ' ', sequential[0], sequential[47], sequential[36], ' ', sequential[6], sequential[38], sequential[18], ' ', sequential[29], sequential[15], sequential[26], ' ', sequential[27], sequential[24], sequential[44], ' ', sequential[33], sequential[42], sequential[53], ' ', sequential[35], sequential[51], sequential[17], '\0' };
    NSString *stringToReturn = [[NSString alloc] initWithCString:edgesAndCorners encoding:NSASCIIStringEncoding];
    return stringToReturn;
                                                                                                                                                                       
}
