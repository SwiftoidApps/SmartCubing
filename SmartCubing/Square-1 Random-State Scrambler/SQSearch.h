//
//  SQSearch.h
//  CubeTimer Scramblers
//
//  Adapted from JFly's public domain sq12phase project, as obtained from https://github.com/cubing/tnoodle/tree/master/sq12phase/src/cs/sq12phase
//

#import <Foundation/Foundation.h>

@class SQFullCube;

@interface SQSearch : NSObject

-(NSString*) solution:(SQFullCube*) cube ;

@end
