//
//  WFWiFiScan.m
//  iPhoneWiFiScan
//
//  Created by 汪 威 on 12-8-6.
//  Copyright (c) 2012年 wiseflag.com. All rights reserved.
//

#import "WFWiFiScan.h"

#define WISEFLAG_PREFIX @"365PATH"

@implementation WFWiFiScan
{
	NSMutableArray *networks;
	
	void *libHandle;
	void *airportHandle;    
	int (*apple80211Open)(void *);
	int (*apple80211Bind)(void *, NSString *);
	int (*apple80211Close)(void *);
	int (*associate)(void *, NSDictionary*, NSString*);
	int (*apple80211Scan)(void *, NSArray **, void *);
}

- (id)init
{
	self = [super init];
  
  networks = [[NSMutableArray alloc] init];
	
  float version = [[[UIDevice currentDevice] systemVersion] floatValue]; 
  if (version >= 5.0) {
    //iOS5版本中扫描wifi
    libHandle = dlopen("/System/Library/SystemConfiguration/IPConfiguration.bundle/IPConfiguration", RTLD_LAZY);
  }
  else {
    //iOS4版本中扫描wifi
    libHandle = dlopen("/System/Library/SystemConfiguration/WiFiManager.bundle/WiFiManager", RTLD_LAZY);
  }
	char *error;
	if (libHandle == NULL && (error = dlerror()) != NULL) {
		NSLog(@"%s", error);
	}
	apple80211Open  = dlsym(libHandle, "Apple80211Open");
	apple80211Bind  = dlsym(libHandle, "Apple80211BindToInterface");
	apple80211Close = dlsym(libHandle, "Apple80211Close");
	apple80211Scan  = dlsym(libHandle, "Apple80211Scan");
	apple80211Open(&airportHandle);
	apple80211Bind(airportHandle, @"en0");
  
	return self;
}

- (void)dealloc
{
  apple80211Close(airportHandle);
  [networks release];
  [super dealloc];
}

- (void)scanNetworks
{
//	NSLog(@"Scanning WiFi Channels...");
	
	NSDictionary *parameters = [[NSDictionary alloc] init];
	NSArray *scan_networks; //is a CFArrayRef of CFDictionaryRef(s) containing key/value data on each discovered network
	apple80211Scan(airportHandle, &scan_networks, parameters);
//	NSLog(@"===--======\n%@", scan_networks);
  
  [networks removeAllObjects];

	for (int i = 0; i < [scan_networks count]; i++) {
    
    NSDictionary *wifi = [scan_networks objectAtIndex: i];
//    NSString *ssid = [wifi objectForKey:WIFI_SSID];
    
//    if ([[ssid uppercaseString] hasPrefix:WISEFLAG_PREFIX]) {
      NSString *bssid = [wifi objectForKey:WIFI_BSSID];
      NSArray *array = [[bssid uppercaseString] componentsSeparatedByString:@":"];
      NSMutableString *mac = [[NSMutableString alloc] initWithCapacity:17];
      
      for (NSUInteger i = 0; i < array.count ; i++) {
        NSString *s = [array objectAtIndex:i];
        if (s.length == 1) [mac appendString:@"0"];
        [mac appendString:s];
        if (i < 5) [mac appendString:@":"];
      }
      
      if ([[wifi objectForKey:WIFI_RSSI] integerValue] < -90) { //过滤掉信号小于-90的路牌
        continue;
      }
      
      [wifi setValue:mac forKey:WIFI_MAC];
      [networks addObject:wifi];
      [mac release];
//    }
    
	}
  [parameters release];
  
//	NSLog(@"Scanning WiFi Channels Finished.");     
}

- (NSUInteger)numberOfNetworks
{
	return [networks count];
}

NSInteger WiFiSignalCompare(id WiFi_A, id WiFi_B, void *context)
{
  NSInteger signalA = abs([[((NSDictionary *)WiFi_A) objectForKey:WIFI_RSSI] integerValue]);
  NSInteger signalB = abs([[((NSDictionary *)WiFi_B) objectForKey:WIFI_RSSI] integerValue]);
  
  if (signalA < signalB) {
    return NSOrderedAscending;
  }
  else if (signalA > signalB) {
    return NSOrderedDescending;
  }
  else {
    return NSOrderedSame;
  }
}

- (NSArray *)networks
{
	return [networks sortedArrayUsingFunction:WiFiSignalCompare context:nil];
}

- (NSDictionary *)network:(NSString *)mac
{
  NSDictionary *wifi = nil;
  for (NSDictionary *network in networks) {
    if ([[network objectForKey:WIFI_MAC] isEqualToString:mac]) {
      wifi = network;
    }
  }
	return wifi;
}


- (NSString *)description
{
	NSMutableString *result = [[NSMutableString alloc] initWithString:@"Networks State: \n"];
	for (NSDictionary *network in networks) {
    NSString *wifiInfo = [NSString stringWithFormat:@"%@ (MAC: %@), RSSI: %@, Channel: %@ \n", [network objectForKey:WIFI_SSID], [network objectForKey:WIFI_MAC], [network objectForKey:WIFI_RSSI], [network objectForKey:WIFI_CHAN]];
		[result appendString:wifiInfo];
	}
	return [NSString stringWithString:[result autorelease]];
}

@end