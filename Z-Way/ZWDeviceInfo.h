//
//  ZWDeviceInfo.h
//  Z-Way
//
//  Created by Alex Skalozub on 9/4/12.
//  Copyright (c) 2012 Alex Skalozub.
//
//  Z-Way for iOS is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  Z-Way for iOS is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with Z-Way for iOS. If not, see <http://www.gnu.org/licenses/>
//

#import <Foundation/Foundation.h>
#import "ZWDeviceItem.h"

@interface ZWDeviceInfo : NSObject
{
    NSString *_type;
    NSString *_deviceId;
    NSDictionary *_device;
    NSString *_instanceId;
    NSDictionary *_instance;
    NSString *_ccId;
    NSDictionary *_data;
}

+ (id)deviceWithType:(NSString*)type forDeviceId:(NSString*)deviceId device:(NSDictionary*)device andInstanceId:(NSString*)instanceId instance:(NSDictionary*)instance andCCId:(NSString*)ccId withData:(NSDictionary*)data;

- (id)initWithType:(NSString*)type forDeviceId:(NSString*)deviceId device:(NSDictionary*)device andInstanceId:(NSString*)instanceId instance:(NSDictionary*)instance andCCId:(NSString*)ccId withData:(NSDictionary*)data;

- (ZWDeviceItem*)createUIforTableView:(UITableView*)tableView atPos:(NSIndexPath*)pos;
- (CGFloat)height;

@property (readonly) NSString *deviceId;
@property (readonly) NSString *instanceId;
@property (readonly) NSString *ccId;

@property (readonly) NSDictionary *device;
@property (readonly) NSDictionary *instance;
@property (readonly) NSDictionary *data;

@end
