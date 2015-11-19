//
//  SLMessage.m
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "SLMessage.h"

@implementation SLMessage

+ (JSQMessage*)deviceDisconnectedMessage
{
    return [[JSQMessage alloc] initWithSenderId:@"device-1"
                               senderDisplayName:@"Device"
                                            date:[NSDate date]
                                           text:@"I'm having trouble connecting to your device, has it been turned off?"];
}

+ (JSQMessage*)noAlertsMessage
{
    return [[JSQMessage alloc] initWithSenderId:@"device-1"
                              senderDisplayName:@"Device"
                                           date:[NSDate date]
                                           text:@"Everything seems normal in your home right now."];
}
@end
