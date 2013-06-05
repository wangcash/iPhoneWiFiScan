//
//  WFViewController.h
//  iPhoneWiFiScan
//
//  Created by 汪 威 on 12-7-27.
//  Copyright (c) 2012年 wiseflag.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
  UITableView * _wifiTable;
}

@property (nonatomic, retain) IBOutlet UITableView * wifiTable;

- (IBAction)button:(id)sender;
- (IBAction)save:(id)sender;

- (void)refresh;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
