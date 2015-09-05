//
//  RandomNumber.m
//  CubeTimer Scramblers

#import "RandomNumber.h"
#import <sys/time.h>

BOOL isiOS5OrLater() {
    static int value = -1;
    if (value == -1) {
      //  value = (([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending)) ? 1 : 0;
    }
    return YES; //(BOOL) value;

}

int randomnumber(int upperBound) {
    return (isiOS5OrLater() ? arc4random_uniform(upperBound) : arc4random() % (upperBound));
}

 unsigned long getMStime(void) { struct timeval time; gettimeofday(&time, NULL); return (time.tv_sec * 1000) + (time.tv_usec / 1000); }