//
//  TwoPhaseScrambler.m
//  CubeTimer Scramblers
//

#import "TwoPhaseScrambler.h"
#import "SolveFormatConverter.h"
#import "Search.h"
#import "Util.h"
#import "CoordCube.h"
#import "CubieCube.h"

@interface TwoPhaseScrambler () {
    BOOL blockIsExecuting;
}

+(NSString*)generateScramble;
-(void) cacheScramblesIfIdle;

@end

@implementation TwoPhaseScrambler

@synthesize cachedScrambles;

NSString *const filePath = @"Cached3x3Scrambles";

-(void) cacheScramblesIfIdle {
    @autoreleasepool {
    __block NSMutableArray *cachedScramblesLocal = self.cachedScrambles;
    if (!blockIsExecuting) {
        long priority = DISPATCH_QUEUE_PRIORITY_LOW;
        dispatch_async(dispatch_get_global_queue(priority,
                                                 (unsigned long)NULL), ^(void) {
            blockIsExecuting = YES;
            while (cachedScramblesLocal.count < 15) {
                blockIsExecuting = YES;
                [cachedScramblesLocal addObject:[TwoPhaseScrambler generateScramble]];
            }
            NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *path = [directory stringByAppendingPathComponent:filePath];
            [self.cachedScrambles writeToFile:path atomically:NO];
            blockIsExecuting = NO;
        });
    }
    }
    
}

-(id) init {
    if (self = [super init]) {
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [directory stringByAppendingPathComponent:filePath];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            self.cachedScrambles = [NSMutableArray arrayWithContentsOfFile:path];
        else self.cachedScrambles = [NSMutableArray array];
        blockIsExecuting = NO;
    }
    return self;
}

-(void) dealloc {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [directory stringByAppendingPathComponent:filePath];
    [self.cachedScrambles writeToFile:path atomically:NO];
}

-(NSString*)scramble {
    if (cachedScrambles.count > 0) {
        NSString *retVal = [cachedScrambles objectAtIndex:0];
        [cachedScrambles removeObjectAtIndex:0];
        [self cacheScramblesIfIdle];
        return retVal;
    } else {
        NSString *scramble = blockIsExecuting ? @"No scramble available" : [TwoPhaseScrambler generateScrambleWithTimeMin:0];
        [self cacheScramblesIfIdle];
        return scramble;
    }
}

+(NSString*)randomCubeByFlippingEdgeOnCube:(NSString*)initialCube {
    NSMutableArray *components = [[initialCube componentsSeparatedByString:@" "] mutableCopy];
    int edgeToFlip = randomnumber(12);
    NSString *subString = [components objectAtIndex:edgeToFlip];
    NSString *newEdge = [NSString stringWithFormat:@"%c%c", [subString characterAtIndex:1], [subString characterAtIndex:0]];
    [components replaceObjectAtIndex:edgeToFlip withObject:newEdge];
    return [components componentsJoinedByString:@" "];
    
}

+(NSString*)randomCubeByResolvingParityOnCube:(NSString*)initialCube {
    NSMutableArray *components = [[initialCube componentsSeparatedByString:@" "] mutableCopy];
    BOOL corners = randomnumber(2);
    if (corners) {
        int index1, index2;
        do {
            index1 = randomnumber(8) + 12;
            index2 = randomnumber(8) + 12;
        } while (index1 == index2);
        NSString *corner1 = [components objectAtIndex:index1];
        NSString *corner2 = [components objectAtIndex:index2];
        [components replaceObjectAtIndex:index1 withObject:corner2];
        [components replaceObjectAtIndex:index2 withObject:corner1];
    } else {
        int index1, index2;
        do {
            index1 = randomnumber(12);
            index2 = randomnumber(12);
        } while (index1 == index2);
        NSString *edge1 = [components objectAtIndex:index1];
        NSString *edge2 = [components objectAtIndex:index2];
        [components replaceObjectAtIndex:index1 withObject:edge2];
        [components replaceObjectAtIndex:index2 withObject:edge1];
    }
    
    return [components componentsJoinedByString:@" "];
    
}

+(NSString*) randomCubeByTwistingCornerOnCube:(NSString*)initialCube {
    NSMutableArray *components = [[initialCube componentsSeparatedByString:@" "] mutableCopy];
    int cornerToTwist = 12 + randomnumber(8); //Only 4.3+
    NSString *subString = [components objectAtIndex:cornerToTwist];
    char *corner = (char*)[subString UTF8String];
    int numToMove = randomnumber(2) + 1;
    for (int x = 0; x < numToMove; x++) {
        char charForEnd = corner[0];
        corner[0] = corner[1];
        corner[1] = corner[2];
        corner[2] = charForEnd;
    }
    [components replaceObjectAtIndex:cornerToTwist withObject:@(corner)];
    return [components componentsJoinedByString:@" "];
}

+(NSString*)reverseSolve:(NSString*)solve {
    NSArray *components = [[solve substringToIndex:solve.length - 1]componentsSeparatedByString:@" "];
    NSArray *reversedComponents = [[components reverseObjectEnumerator] allObjects];
    NSMutableString *reversedString = [NSMutableString string];
    for (NSString *component in reversedComponents) {
        if ([component rangeOfString:@"-"].location != NSNotFound) {
            [reversedString appendFormat:@"%c ", [component characterAtIndex:0]]; //If it's a prime move, make it non-prime
        } else if ([component rangeOfString:@"2"].location != NSNotFound) {
            [reversedString appendFormat:@"%@ ", component]; //Leave double turns as they are
        } else [reversedString appendFormat:@"%c' ", [component characterAtIndex:0]]; //Make non-prime moves prime
    }
    return reversedString;
}

+(NSString*) generateRandomCube {
    const NSMutableArray *edges = [NSMutableArray arrayWithObjects:@"UF", @"UR", @"RD", @"RB", @"LU", @"LF", @"DB", @"DL", @"FR", @"UB", @"DF", @"BL", nil];
    const NSMutableArray *corners = [NSMutableArray arrayWithObjects:@"UFR", @"RFD", @"RDB", @"RBU", @"LFU", @"LUB", @"DLB", @"LDF", nil];
    NSMutableString *cubeString = [NSMutableString string];
    while (edges.count > 0) {
        u_int32_t index = randomnumber((unsigned int)edges.count);
        char *edge = (char*)[[edges objectAtIndex:index] UTF8String];
        int numToMove = randomnumber(2); 
        for (int x = 0; x < numToMove; x++) {
            char charForEnd = edge[0];
            edge[0] = edge[1];
            edge[1] = charForEnd;
        }
        [cubeString appendFormat:@"%s ", edge];
        [edges removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
        
    }
    while (corners.count > 0) {
        u_int32_t index = randomnumber((unsigned int)corners.count);
        char *corner = (char*)[[corners objectAtIndex:index] UTF8String];
        int numToMove = randomnumber(3);
        for (int x = 0; x < numToMove; x++) {
            char charForEnd = corner[0];
            corner[0] = corner[1];
            corner[1] = corner[2];
            corner[2] = charForEnd;
        }
        [cubeString appendFormat:@"%s ", corner];
        [corners removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
    }
    return cubeString;
}

+(NSString*) generateScramble {
    return [self generateScrambleWithTimeMin:1500];
}

+(NSString*)generateScrambleWithTimeMin:(int)timeMin {
    static BOOL firstRun = YES;
    if (firstRun) {
        setupUtil();
        [CubieCube initMove];
        [CubieCube initSym];
        [CubieCube initFlipSym2Raw];
        [CubieCube initTwistSym2Raw];
        [CubieCube initPermSym2Raw];
        initFlipMove();
        initTwistMove();
        initUDSliceMoveConj();
        initCPermMove();
        initEPermMove();
        initMPermMoveConj();
        initSliceTwistPrun();
        initSliceFlipPrun();
        initMEPermPrun();
        initMCPermPrun();
        firstRun = NO;
    }
    BOOL validCube = NO;
    NSString* randomCube = [TwoPhaseScrambler generateRandomCube];
    NSString *solvedCube = nil;
    while (!validCube) {
        int mask = 0;
		mask |= YES ? 0x2 : 0; //Inverse
        if (isnan(timeMin) || isinf(timeMin)) {
            timeMin = 0;
        }
        NSString *cubeString = edgesAndCornersToSequential((char*)[randomCube UTF8String]);
        solvedCube = solutionForFacelets(cubeString, 22, 3000, timeMin, mask);
        if ([solvedCube rangeOfString:@"Error"].location == NSNotFound) {
            validCube = YES;
        } else {
            if ([solvedCube rangeOfString:@"3"].location != NSNotFound) {
                randomCube = [self randomCubeByFlippingEdgeOnCube:randomCube];
            } else if ([solvedCube rangeOfString:@"5"].location != NSNotFound) {
                randomCube = [self randomCubeByTwistingCornerOnCube:randomCube];
            } else if ([solvedCube rangeOfString:@"6"].location != NSNotFound) {
                randomCube = [self randomCubeByResolvingParityOnCube:randomCube];
            } else randomCube = [self generateRandomCube];
        }  
    }
    
    if (solvedCube == nil) {
        return @"No scramble available";
    }
    if ([solvedCube characterAtIndex:solvedCube.length - 1] == ' ') {
        solvedCube = [solvedCube substringToIndex:solvedCube.length - 1];
    }
    return solvedCube;
    
    
}

@end
