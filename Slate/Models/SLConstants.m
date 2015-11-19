//
//  SLConstants.m
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "SLConstants.h"

@implementation SLConstants


+ (SLConstants *)sharedInstance
{
    static dispatch_once_t pred;
    static SLConstants *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[SLConstants alloc] init];
    });
    
    return sharedInstance;
}

// The Purple Color used all over the UI
- (UIColor*)purpleColor
{
    return [UIColor colorWithRed:0.51 green:0.49 blue:0.81 alpha:1.0];
}

@end
