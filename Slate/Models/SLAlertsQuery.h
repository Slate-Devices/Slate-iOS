//
//  SLAlertsQuery.h
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import <Parse/Parse.h>
#import "SLUser.h"

@interface SLAlertsQuery : PFQuery

+ (SLAlertsQuery *)alertsQuery;
+ (SLAlertsQuery *)unseenAlertsQuery;
+ (SLAlertsQuery *)unseenAlertsQueryForUser:(SLUser*)user;
+ (SLAlertsQuery *)unseenAlertsQueryForCurrentUser;

@end
