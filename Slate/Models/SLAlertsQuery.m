//
//  SLAlertsQuery.m
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "SLAlertsQuery.h"

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

@end
