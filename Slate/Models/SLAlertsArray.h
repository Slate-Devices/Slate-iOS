//
//  SLAlertsArray.h
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLAlertsArray : NSMutableArray

@property (weak, nonatomic) NSDate* lastRefresh;

+ (SLAlertsArray*)sharedInstance;

- (void)fetchMessagesInBackgroundWithCompletion:(void(^)(SLAlertsArray* messages, NSError *error))completionBlock;
- (NSDate*)lastRefresh;

@end
