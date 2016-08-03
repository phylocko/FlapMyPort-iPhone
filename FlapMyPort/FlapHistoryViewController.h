//
//  FlapHistoryViewController.h
//  TabBarTest-2
//
//  Created by Владислав Павкин on 14.07.15.
//  Copyright (c) 2015 Владислав Павкин. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlapHistoryViewController : UITableViewController

- (void) refresh: (NSMutableData *) data;
- (void) connectionError: (NSError *) error;
- (void) updateParams;

// @property (strong, nonatomic) NSMutableData *data;
// @property (strong, nonatomic) NSMutableArray *json;

//@property (strong, nonatomic) NSString *selectedHost;
//@property (strong, nonatomic) NSString *selectedPort;
@property (strong, nonatomic)	NSDictionary *flap;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@end
