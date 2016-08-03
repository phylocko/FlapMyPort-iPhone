//
//  FlapTableController.m
//  TabBarTest-2
//
//  Created by Владислав Павкин on 14.07.15.
//  Copyright (c) 2015 Владислав Павкин. All rights reserved.
//

#import "FlapTableViewController.h"
#import "FlapHistoryViewController.h"
#import "FlapManager.h"
#import "FlapCell.h"

@interface FlapTableViewController () <UITableViewDataSource, UITableViewDelegate>
{

	FlapManager		*myConnection;
	NSString		*interval;
	NSMutableArray	*hosts;
    BOOL  connectionError;
    NSError *connError;

}

@end


@implementation FlapTableViewController

-(void) updateInterval
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	interval = [defaults stringForKey:@"flapHistoryInterval"];

	
	if([interval isEqualToString:@""])
	{
		[self writeDefaultInterval];
		[self updateInterval];
	}
	
	[self setIntervalButtonTitle];
}

-(void) writeDefaultInterval
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:@"3600" forKey:@"flapHistoryInterval"];
	
	self.intervalButton.title = @"1 hour";
}

-(void) setIntervalButtonTitle
{

	
	if([interval isEqualToString:@"600"])
	{
		self.intervalButton.title = @"10 min";
	}
	else if([interval isEqualToString:@"3600"])
	{
		self.intervalButton.title = @"1 hour";
	}
	else if([interval isEqualToString:@"10800"])
	{
		self.intervalButton.title = @"3 hours";
	}
	else if([interval isEqualToString:@"21600"])
	{
		self.intervalButton.title = @"6 hours";
	}
	else if([interval isEqualToString:@"86400"])
	{
		self.intervalButton.title = @"Day";
	}
}
- (void) viewDidLoad
{
    
    [self disableControls];
	
	[self updateInterval];
	
	
	NSString *url = [NSString stringWithFormat: @"http://isweethome.ihome.ru/api/?review&interval=%@", interval];
	
	
	myConnection = [FlapManager sharedInstance];
	
	myConnection.delegate = self;
	
	[myConnection getURL:url];
	
	
	/* Анимированное обновление таблички */
    /*
	[UIView transitionWithView:self.tableView
					  duration:0.95f
					   options:UIViewAnimationOptionTransitionCrossDissolve
					animations:^(void)
	 {
		 [self.tableView reloadData];
	 }
					completion: nil];
	*/
}
- (IBAction)refreshButtonTap:(UIBarButtonItem *)sender {
	
    [self disableControls];
    
	[self updateInterval];
	
    connectionError = NO;

	NSString *url = [NSString stringWithFormat: @"http://isweethome.ihome.ru/api/?review&interval=%@", interval];
	
	myConnection = [FlapManager sharedInstance];
	
	myConnection.delegate = self;
	
	self.refreshButton.enabled = NO;
	
	[myConnection getURL:url];
	
}

#pragma mark - Refresh

- (void)refresh: (NSMutableData *) data
{
	
	[self updateInterval];
	
	self.data = data;
	
	if(_data != nil)
	{

		NSError *jsonError;
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
															 options:NSJSONReadingMutableContainers
															   error:&jsonError];
		
		hosts = [json objectForKey:@"hosts"];
		// NSDictionary *params = [json objectForKey:@"params"];
		
		for (id host in hosts)
		{

			if([[host valueForKey:@"name"] isKindOfClass:[NSNull class]])
			{
				[host setValue:[host valueForKey:@"ipaddress"] forKey:@"name"];
			}
		}
	}
	else
	{
		NSLog(@"Null is given.");
	}
	
	[self.tableView reloadData];
	
    [self enableControls];
	
}

- (IBAction)refreshControl:(UIRefreshControl *)sender {
	
	
	self.refreshControl = sender;
	
	[self refreshButtonTap:self.refreshButton];
	
}


#pragma mark - Table Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([hosts count]==0)
    {
        return 1;
    }
    
    return [hosts count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([hosts count]==0)
    {
        return @"";
    }
    NSArray *host = [hosts objectAtIndex:section];
	return [host valueForKey:@"name"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([hosts count]==0)
    {
        NSLog(@"Host count is 0. Returning 1");
        return 1;
    }
    
    if([[[hosts objectAtIndex:section] valueForKey:@"ports"] count]==0)
    {
        NSLog(@"Hosts not found. Returning 1");
        return 1;
    }

    return [[[hosts objectAtIndex:section] valueForKey:@"ports"] count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([hosts count]==0)
    {
        if(connectionError == YES)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"errorCell" forIndexPath:indexPath];
            cell.textLabel.text = [connError localizedDescription];
            return cell;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell" forIndexPath:indexPath];
        return cell;
    }

	NSArray *host = [hosts objectAtIndex:indexPath.section];
	
	NSArray *ports = [host valueForKey:@"ports"];
	NSDictionary *port = [ports objectAtIndex:indexPath.row];

	
	FlapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flapCell" forIndexPath:indexPath];
	
	NSString *startTime = [self shortDate:[port valueForKey:@"firstFlapTime"]];
	NSString *endTime = [self shortDate:[port valueForKey:@"lastFlapTime"]];
	
	cell.dateLabel.text = [NSString stringWithFormat:@" %@ — %@", startTime, endTime];
	
	if ([[port valueForKey:@"ifAlias"] isKindOfClass:[NSNull class]])
	{
		cell.interfaceLabel.text = [NSString stringWithFormat:@"%@", [port valueForKey:@"ifName"]];
	}
	else
	{
		cell.interfaceLabel.text = [NSString stringWithFormat:@"%@ (%@)", [port valueForKey:@"ifName"], [port valueForKey:@"ifAlias"]];
	}
	
	if([[port valueForKey:@"ifOperStatus"] isEqualToString:@"down"])
	{
		cell.flapNumberLabel.textColor = [UIColor redColor];
	}
	cell.flapNumberLabel.text = [port valueForKey:@"flapCount"];

	// Preparing the Array for FlapCell
	NSDictionary *flap = @{@"hostname":  [host valueForKey:@"name"],
						   @"ipaddress": [host valueForKey:@"ipaddress"],
						   @"port": port};

	cell.flap = flap;
	
	// Load Diagram
	NSString *urlString = [NSString stringWithFormat:@"http://isweethome.ihome.ru/api/?ifindex=%@&flapchart&host=%@&interval=%@", [port valueForKey:@"ifIndex"], [host valueForKey:@"ipaddress"], interval];
	NSLog(@"URL: %@", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
				  
	NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (data) {
			UIImage *image = [UIImage imageWithData:data];
			if (image) {
				dispatch_async(dispatch_get_main_queue(), ^{
					cell.diagram.image = image;
				});
			}
		}
	}];
	[task resume];
	
	return cell;
	
	/*
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell" forIndexPath:indexPath];
		return cell;
	 */
}

- (void) enableControls
{
    self.refreshButton.enabled = YES;
    self.tableView.userInteractionEnabled = YES;
    [self.refreshControl endRefreshing];
}

- (void) disableControls
{
    self.refreshButton.enabled = NO;
    self.tableView.userInteractionEnabled = NO;
    [self.refreshControl beginRefreshing];
}

- (NSString *) shortDate: (NSString *) dateString
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
	
	NSDate *date = [formatter dateFromString:dateString];
	
	NSDateFormatter *shortFormatter = [[NSDateFormatter alloc] init];
	[shortFormatter setTimeStyle:NSDateFormatterMediumStyle];
	
	
	return [shortFormatter stringFromDate:date];
	
//	return @"9:04:44";
}

- (void) connectionError: (NSError *) error
{
    connectionError = YES;

    connError = error;
    
    [hosts removeAllObjects];
    
	[self.tableView reloadData];
    [self enableControls];
}


- (IBAction) unwindToFlapList: (UIStoryboardSegue *) segue
{
	myConnection.delegate = self;
	[self refreshButtonTap:self.refreshButton];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(FlapCell *)sender
{
	if ( [segue.identifier isEqualToString:@"showHistory"] )
	{
		FlapHistoryViewController *destination = [segue destinationViewController];
		destination.flap = sender.flap;
	}
	
}


@end
