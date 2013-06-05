//
//  WFViewController.m
//  iPhoneWiFiScan
//
//  Created by 汪 威 on 12-7-27.
//  Copyright (c) 2012年 wiseflag.com. All rights reserved.
//

#import "WFViewController.h"
#import "WFWiFiScan.h"

#define CRACK 1

//iphone4
#define WiseFlagMapCode @"17B9717E-1A92-4C12-9CF1-FC80275E484A"

//ipod
//#define WiseFlagMapCode @"D5FE146F-5217-414B-9224-BF5E8B2044B0"



@implementation WFViewController
{
  WFWiFiScan * networksManager;
  NSTimer * timer;
}

@synthesize wifiTable = _wifiTable;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _wifiTable.delegate = self;
  _wifiTable.dataSource = self;
  
	networksManager = [[WFWiFiScan alloc] init];
  
//	[networksManager scanNetworks];
//	NSLog(@"----- wifi description ----------\n%@", [networksManager description]);
//	NSLog(@"---- wifi size ------\n%d",[networksManager numberOfNetworks]);

}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (NSString *)outputDirectory
{
  NSString *path = NSTemporaryDirectory();
  return path;
}

- (NSString *)outputPath
{
  NSString *outputDir = [self outputDirectory];
  BOOL isDir = YES;
  //如果logs文件夹存不存在，则创建
  if([[NSFileManager defaultManager] fileExistsAtPath:outputDir isDirectory:&isDir] == NO)
  {
    [[NSFileManager defaultManager] createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:nil];
  }

  NSDate* now = [NSDate date];
  NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents* components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
  
  NSString *fileName =[NSString stringWithFormat:@"%d%d%d.plist", [components hour], [components minute], [components second]];
  NSString *path = [outputDir stringByAppendingPathComponent:fileName];
  
  return path;
}

- (void)refresh
{
  NSLog(@"==Start==");
  [networksManager scanNetworks];

  [_wifiTable reloadData];
  NSLog(@"==End==");
}

- (void)startUpdatingLocation
{
  timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                            target:self
                                          selector:@selector(refresh)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)stopUpdatingLocation
{
  [timer invalidate];
  timer = nil;
}

- (IBAction)button:(id)sender
{
  UIBarButtonItem *button = sender;
  if (timer.isValid) {
    [self stopUpdatingLocation];
    button.title = @"启动";
  }
  else {
    [self startUpdatingLocation];
    button.title = @"终止";
  }
}

- (IBAction)save:(id)sender
{
  NSString* path = [self outputPath];
  
  NSLog(@"%@", path);
  
  [[networksManager networks] writeToFile:path atomically:YES];
  
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil 
                                                  message:path
                                                 delegate:nil 
                                        cancelButtonTitle:@"确定" 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [networksManager numberOfNetworks];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *reuseIdetify = @"WiFiTableViewCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdetify] autorelease];
  }
  
  NSArray *networks = [networksManager networks];
  NSDictionary *wifiDict = [networks objectAtIndex:indexPath.row];
  
  NSString *mac  = [wifiDict objectForKey:WIFI_MAC];
  NSString *ssid = [wifiDict objectForKey:WIFI_SSID];
  NSString *rssi = [wifiDict objectForKey:WIFI_RSSI];
  
  cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", mac, rssi];
  cell.detailTextLabel.text = ssid;
  
  return cell;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}

@end
