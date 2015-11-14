//
//  ViewController.h
//  Slate
//
//  Created by Sam Sheffres on 14/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>

@interface ViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (nonatomic, weak) IBOutlet UITableView* eventsTableView;

@end

