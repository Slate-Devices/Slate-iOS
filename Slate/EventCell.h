//
//  EventCell.h
//  Slate
//
//  Created by Sam Sheffres on 14/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *eventName;
@property (nonatomic, weak) IBOutlet UILabel *eventTime;

@end
