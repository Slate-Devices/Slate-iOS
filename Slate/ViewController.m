//
//  ViewController.m
//  Slate
//
//  Created by Sam Sheffres on 14/11/15.
//  Copyright © 2015 Sam Sheffres. All rights reserved.
//

#import "ViewController.h"
#import "EventCell.h"

#import <JSQMessagesViewController/JSQMessages.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray *_events;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _events = [NSArray array];
    
//    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated{
//    [self getEventsFromAPI:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getEventsFromAPI:(id)sender {
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://192.168.8.100:9393/events?device_id=1"]];
    [self fetchedData:data];
    [self.eventsTableView reloadData];
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    _events = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    [self.eventsTableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger) _events.count;
}

- (EventCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    
    cell.eventName.text = (NSString*)[(NSDictionary*)[_events objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}


@end
