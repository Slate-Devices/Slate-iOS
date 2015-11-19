//
//  SLAlert.m
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "SLAlert.h"

@implementation SLAlert

- (BOOL)seen
{
    return [self objectForKey:@"seen"];
}

- (void)setSeen:(BOOL)seen
{
    if (seen == NO) {
        [self setObject:@NO forKey:@"seen"];
    } else if (seen == YES) {
        [self setObject:@YES forKey:@"seen"];
    }
}
- (NSString*)processMessage
{
    NSString *messageText;
    
    if ([[self objectForKey:@"event_type"] isEqualToString:@"Broken Window"]) {
        
        messageText = @"I've detected what could be a broken window in your home, what would you like me to do?";
    
    } else if ([[self objectForKey:@"event_type"] isEqualToString:@"noise"]) {
    
        if ([[self objectForKey:@"amount"] floatValue] > 40.0) {
            
            messageText = @"I've detected some loud noise in your home, what would you like me to do?";
        
        }
    
    } else if ([[self objectForKey:@"event_type"] isEqualToString:@"temp"]) {
    
        if ((int)[self objectForKey:@"amount"] > 30) {
            
            messageText = @"It's way too hot at home, should I turn on the AC?";
        
        } else if ((int)[self objectForKey:@"amount"] < 0) {
        
            messageText = @"It's below freezing in your home, should I turn on the heater?";
        
        }
    }
    
    return messageText;
}


@end
