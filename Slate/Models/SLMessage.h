//
//  SLMessage.h
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessage.h>

@interface SLMessage : JSQMessage

+ (JSQMessage*)deviceDisconnectedMessage;
+ (JSQMessage*)noAlertsMessage;

@end
