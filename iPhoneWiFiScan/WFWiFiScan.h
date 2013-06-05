//
//  WFWiFiScan.h
//  iPhoneWiFiScan
//
//  Created by 汪 威 on 12-8-6.
//  Copyright (c) 2012年 wiseflag.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <dlfcn.h>

#define WIFI_MAC   @"MAC"
#define WIFI_BSSID @"BSSID"
#define WIFI_SSID  @"SSID_STR"
#define WIFI_RSSI  @"RSSI"
#define WIFI_CHAN  @"CHANNEL"

@interface WFWiFiScan : NSObject


- (void)scanNetworks;

/**
 * returns all 802.11 number
 */
- (NSUInteger)numberOfNetworks;

/**
 * returns all 802.11 scanned network(s)
 */
- (NSArray *)networks;

/**
 * return specific 802.11 network by MAC Address
 */
- (NSDictionary *)network:(NSString *)mac;


@end
