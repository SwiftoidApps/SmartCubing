//
//  SolveFormatConverter.h
//  CubeTimer Scramblers
//

#include <stdio.h>
#import <string.h>
#import <Foundation/Foundation.h>
#import "RandomNumber.h"

#ifndef TwoPhase_VerifyCube_h
#define TwoPhase_VerifyCube_h

NSString* edgesAndCornersToSequential(char* edgesAndCorners);
NSString* sequentialToEdgesAndCorners(char* sequential);

#endif
