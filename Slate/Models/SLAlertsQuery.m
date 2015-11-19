//
//  SLAlertsQuery.m
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "SLAlertsQuery.h"
#import "SLUser.h"

@implementation SLAlertsQuery

+ (SLAlertsQuery *)alertsQuery
{
    return (SLAlertsQuery*)[self queryWithClassName:@"Alert"];
}

+ (SLAlertsQuery *)unseenAlertsQuery
{
    SLAlertsQuery *query = (SLAlertsQuery*)[self queryWithClassName:@"Alert"];
    [query whereKey:@"seen" notEqualTo:@YES];
    
    return  query;
}

+ (SLAlertsQuery *)unseenAlertsQueryForUser:(SLUser*)user
{
    SLAlertsQuery *query = (SLAlertsQuery*)[self queryWithClassName:@"Alert"];
    [query whereKey:@"seen" notEqualTo:@YES];
    [query whereKey:@"user_id" equalTo:[user objectId]];
    
    return  query;
}

+ (SLAlertsQuery *)unseenAlertsQueryForCurrentUser
{
    SLAlertsQuery *query = (SLAlertsQuery*)[self queryWithClassName:@"Alert"];
    [query whereKey:@"seen" notEqualTo:@YES];
    [query whereKey:@"user_id" equalTo:[[SLUser currentUser] objectId]];
    
    return  query;
}
@end
