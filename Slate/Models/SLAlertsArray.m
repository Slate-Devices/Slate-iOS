//
//  SLAlertsArray.m
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "SLAlertsArray.h"
#import "SLAlertsQuery.h"

#import <Parse/Parse.h>

@implementation SLAlertsArray

+ (SLAlertsArray*)sharedInstance
{
    static dispatch_once_t pred;
    static SLAlertsArray *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[SLAlertsArray alloc] init];
        
        sharedInstance.lastRefresh = [NSDate date];
    });
    
    return sharedInstance;
}

- (void)fetchMessagesInBackgroundWithCompletion:(void(^)(SLAlertsArray* messages, NSError *error))completionBlock
{
    SLAlertsQuery *alertsQuery = [SLAlertsQuery unseenAlertsQuery];
    
    [alertsQuery findObjectsInBackgroundWithBlock:^(NSArray* messages, NSError* error) {
        completionBlock((SLAlertsArray*)messages, error);
    }];

}

- (void)resetLastRefreshDate
{
    if (self.count > 0)
        self.lastRefresh  = [NSDate date];
}

@end
