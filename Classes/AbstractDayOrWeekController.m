//
//  AbstractDayOrWeekController.m
//  AppSalesMobile
//
//  Created by Evan Schoenberg on 1/29/09.
//  Copyright 2009 Adium X / Saltatory Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AbstractDayOrWeekController.h"
#import "Day.h"
#import "DayCell.h"
#import "CountriesController.h"
#import "RootViewController.h"
#import "CurrencyManager.h"
#import "ReportManager.h"

@implementation AbstractDayOrWeekController

@synthesize daysByMonth, maxRevenue, sectionTitleFormatter, sectionTitleViews;

- (id)init
{
	[super init];
	self.daysByMonth = [NSMutableArray array];
	self.maxRevenue = 0;
	self.sectionTitleFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[sectionTitleFormatter setDateFormat:@"MMMM yyyy"];
	self.sectionTitleViews = [NSMutableDictionary dictionary];
	
	return self;
}

- (void)viewDidLoad
{
	self.tableView.rowHeight = 45.0;
}

- (void)reload
{
	[self.tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *titleView = [sectionTitleViews objectForKey:[NSNumber numberWithInt:section]];
	if (titleView == nil) {
		titleView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 320, 22)] autorelease];
		[sectionTitleViews setObject:titleView forKey:[NSNumber numberWithInt:section]];
		 CAGradientLayer *gradient = [CAGradientLayer layer];
		 gradient.frame = titleView.bounds;
		CGColorRef fromGradient = [[UIColor colorWithRed:144.0/255.0 green:159.0/255.0 blue:170.0/255.0 alpha:0.90] CGColor];
		CGColorRef toGradient = [[UIColor colorWithRed:184.0/255.0 green:193.0/255.0 blue:200.0/255.0 alpha:0.90] CGColor];
		 gradient.colors = [NSArray arrayWithObjects:(id)fromGradient, (id)toGradient, nil];
		 [titleView.layer insertSublayer:gradient atIndex:0];

		UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, 22)] autorelease];
		titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
		titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.44 alpha:1.0];
		titleLabel.shadowOffset = CGSizeMake(0, 1);
		[titleView addSubview:titleLabel];

		NSString *total = nil;
		NSString *average = nil;
		if ([self.daysByMonth count] > 0) {
			float sum = 0;
			for (Day *d in [self.daysByMonth objectAtIndex:section]) {
				sum += [d totalRevenueInBaseCurrency];
			}
			total = [[CurrencyManager sharedManager] baseCurrencyDescriptionForAmount:[NSNumber numberWithFloat:sum] withFraction:YES];
			average = [[CurrencyManager sharedManager] baseCurrencyDescriptionForAmount:[NSNumber numberWithFloat:sum/[[self.daysByMonth objectAtIndex:section] count]] withFraction:YES];
		}
		if (total > 0) {
			UILabel *detailLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, 22)] autorelease];
			detailLabel.text = [NSString stringWithFormat:@"∑ %@   ∅ %@  ", total, average];
			detailLabel.font = [UIFont boldSystemFontOfSize:13.0];
			detailLabel.textAlignment = UITextAlignmentRight;
			detailLabel.backgroundColor = [UIColor clearColor];
			detailLabel.textColor = [UIColor whiteColor];
			detailLabel.shadowColor = [UIColor darkGrayColor];
			detailLabel.shadowOffset = CGSizeMake(0, 1);
			[titleView addSubview:detailLabel];
		}
	}

	return titleView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.daysByMonth.count == 0)
		return @"";
	
	NSArray *sectionArray = [daysByMonth objectAtIndex:section];
	if (sectionArray.count == 0)
		return @"";
	Day *firstDayInSection = [sectionArray objectAtIndex:0];
	return [self.sectionTitleFormatter stringFromDate:firstDayInSection.date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	NSInteger count = self.daysByMonth.count;
	return (count > 1 ? count : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (self.daysByMonth.count > 0) {
		return [[self.daysByMonth objectAtIndex:section] count];
	}
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return YES;
}

- (void)dealloc 
{
	self.sectionTitleFormatter = nil;
	self.sectionTitleViews = nil;
	self.daysByMonth = nil;
    [super dealloc];
}

@end
