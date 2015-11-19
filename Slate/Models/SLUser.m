//
//  SLUser.m
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "SLUser.h"

@implementation SLUser

+ (SLUser *)sharedInstance
{
    static dispatch_once_t pred;
    static SLUser *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[SLUser alloc] init];
    });
    
    return sharedInstance;
}

@end
