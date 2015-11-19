//
//  SLUser.h
//  Slate
//
//  Created by Sam Sheffres on 19/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import <Parse/Parse.h>

@interface SLUser : PFUser

+ (SLUser *)sharedInstance;

@end
