//
//  ViewController.m
//  Slate
//
//  Created by Sam Sheffres on 14/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "ViewController.h"

#import "SLAlertsArray.h"

#import <JSQMessagesViewController/JSQMessages.h>
#import <Parse/Parse.h>

@interface ViewController () <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout, JSQMessageData> {
    NSMutableArray* _chatMessages;
}

@end

@implementation ViewController

#pragma mark View Controller Delegate

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chatMessages = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.senderId = @"user-1";
    self.senderDisplayName = @"Me";
    
    self.inputToolbar.contentView.textView.tintColor = [UIColor colorWithRed:0.51 green:0.49 blue:0.81 alpha:1.0];
    [self.inputToolbar.contentView.rightBarButtonItem setTitleColor:[UIColor colorWithRed:0.51 green:0.49 blue:0.81 alpha:1.0] forState:UIControlStateNormal];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError * error) {
        if (!error) {
            [self getEventsFromAPI:NULL];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark API Methods

- (IBAction)getEventsFromAPI:(id)sender {
    [[SLAlertsArray sharedInstance] fetchMessagesInBackgroundWithCompletion:^(SLAlertsArray *messages, NSError *error) {
        [self fetchedData:messages];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

- (void)fetchedData:(SLAlertsArray *)messages {
    BOOL hasAlert = NO;
    
    NSDateFormatter* apiTime = [[NSDateFormatter alloc] init];
    [apiTime setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    
    if ([[NSDate date] timeIntervalSinceDate:[apiTime dateFromString:[messages.lastObject objectForKey:@"created_at"]]] > 120 || (messages.count == 0 && [[NSDate date] timeIntervalSinceDate:[messages lastRefresh]] > 120)) {
        [_chatMessages addObject:[[JSQMessage alloc] initWithSenderId:@"device-1"
                                                senderDisplayName:@"Device"
                                                             date:[NSDate date]
                                                             text:@"I'm having trouble connecting to your device, has it been turned off?"]];
        
        [self finishReceivingMessageAnimated:YES];
        
        hasAlert = NO;
    } else {
        
        for (PFObject* alert in messages) {
            // Check for Criteria and Compose Messages
            
            NSString* messageText;
            
            if ([[alert objectForKey:@"event_type"] isEqualToString:@"Broken Window"]) {
                messageText = @"I've detected what could be a broken window in your home, what would you like me to do?";
            } else if ([[alert objectForKey:@"event_type"] isEqualToString:@"noise"]) {
                if ([[alert objectForKey:@"amount"] floatValue] > 40.0) {
                    messageText = @"I've detected some loud noise in your home, what would you like me to do?";
                }
            } else if ([[alert objectForKey:@"event_type"] isEqualToString:@"temp"]) {
                if ((int)[alert objectForKey:@"amount"] > 30) {
                    messageText = @"It's way too hot at home, should I turn on the AC?";
                } else if ((int)[alert objectForKey:@"amount"] < 0) {
                    messageText = @"It's below freezing in your home, should I turn on the heater?";
                }
            }
            
            if (messageText && !hasAlert) {
                [_chatMessages addObject:[[JSQMessage alloc] initWithSenderId:@"device-1"
                                                         senderDisplayName:@"Device"
                                                                      date:[NSDate date]
                                                                      text:messageText]];
                
                [self finishReceivingMessageAnimated:YES];
                
                hasAlert = YES;
            }
            
            [alert setValue:@YES forKey:@"seen"];
            [alert setValue:[[PFUser currentUser] objectId] forKey:@"user_id"];
            [alert saveInBackground];
        }
    }
    
    if (!hasAlert) {
        [_chatMessages addObject:[[JSQMessage alloc] initWithSenderId:@"device-1"
                                                senderDisplayName:@"Device"
                                                             date:[NSDate date]
                                                             text:@"Everything seems normal in your home right now."]];
        
        [self finishReceivingMessageAnimated:YES];
    }
}

#pragma mark JSQMessagesView Methods

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:date
                                                          text:text];
    
    [_chatMessages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
    
    [self.collectionView reloadData];

}

- (void)showDeviceReply {
    JSQMessage *message_reply = [[JSQMessage alloc] initWithSenderId:@"device-1"
                                                   senderDisplayName:@"Device"
                                                                date:[NSDate date]
                                                                text:@"Ok"];
    
    [_chatMessages addObject:message_reply];
    
    [self finishSendingMessageAnimated:YES];
    
    [self.collectionView reloadData];
    
    self.showTypingIndicator = !self.showTypingIndicator;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_chatMessages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [_chatMessages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];

    
    JSQMessage *message = [_chatMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }
    
    return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.51 green:0.49 blue:0.81 alpha:1.0]];

}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [_chatMessages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [_chatMessages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [_chatMessages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_chatMessages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [_chatMessages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

#pragma mark UICollectionView Delegate

#pragma mark Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark JSQMessages collection view flow layout delegate

#pragma mark Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [_chatMessages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [_chatMessages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [_chatMessages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}



@end
