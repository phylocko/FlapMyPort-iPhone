//
//  FlapTableViewController.h
//  TabBarTest-2
//
//  Created by Владислав Павкин on 14.07.15.
//  Copyright (c) 2015 Владислав Павкин. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlapTableViewController : UITableViewController

- (void) refresh: (NSMutableData *) data;
- (void) connectionError: (NSError *) error;
- (void) updateInterval;
- (void) enableControls;
- (void) disableControls;

- (NSString *) shortDate: (NSString *) dateString;


@property (strong, nonatomic) NSMutableData		*data;
@property (strong, nonatomic) NSMutableArray	*json;

@property (strong, nonatomic) NSDate			*startDate;
@property (strong, nonatomic) NSDate			*endDate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *intervalButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, retain) UIRefreshControl  *refreshControl;

@end
