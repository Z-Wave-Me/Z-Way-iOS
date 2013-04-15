//
//  ZWDeviceInfo.m
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

#import "ZWDeviceInfo.h"
#import "ZWDeviceItemDimmer.h"
#import "ZWDeviceItemSwitch.h"
#import "ZWDeviceItemMeter.h"
#import "ZWDeviceItemSensorBinary.h"
#import "ZWDeviceItemSensorMulti.h"
#import "ZWDeviceItemThermostat.h"
#import "ZWDeviceItemBlinds.h"
#import "ZWDeviceItemBattery.h"

@implementation ZWDeviceInfo

@synthesize deviceId = _deviceId;
@synthesize instanceId = _instanceId;
@synthesize ccId = _ccId;
@synthesize device = _device;
@synthesize instance = _instance;
@synthesize data = _data;

+ (id)deviceWithType:(NSString *)type forDeviceId:(NSString *)deviceId device:(NSDictionary *)device andInstanceId:(NSString *)instanceId instance:(NSDictionary *)instance andCCId:(NSString*)ccId withData:(NSDictionary *)data
{
    return [[ZWDeviceInfo alloc] initWithType:type forDeviceId:deviceId device:device andInstanceId:instanceId instance:instance andCCId:ccId withData:data];
}

- (id)initWithType:(NSString *)type forDeviceId:(NSString *)deviceId device:(NSDictionary *)device andInstanceId:(NSString *)instanceId instance:(NSDictionary *)instance andCCId:(NSString*)ccId withData:(NSDictionary *)data
{
    self = [super init];
    if (self)
    {
        _type = type;
        _deviceId = deviceId;
        _device = device;
        _instanceId = instanceId;
        _instance = instance;
        _ccId = ccId;
        _data = data;
    }
    return self;
}

- (void)dealloc
{
    _type = nil;
    _deviceId = nil;
    _device = nil;
    _instanceId = nil;
    _instance = nil;
    _ccId = nil;
    _data = nil;
}

- (ZWDeviceItem*)createUIforTableView:(UITableView *)tableView atPos:(NSIndexPath *)pos
{
    ZWDeviceItem *item = (ZWDeviceItem*)[tableView dequeueReusableCellWithIdentifier:_type];
    if (item == nil)
    {
        if ([_type isEqualToString:@"Dimmer"])
            item = [ZWDeviceItemDimmer device];
        else if ([_type isEqualToString:@"Switch"])
            item = [ZWDeviceItemSwitch device];
        else if ([_type isEqualToString:@"SensorBinary"])
            item = [ZWDeviceItemSensorBinary device];
        else if ([_type isEqualToString:@"SensorMulti"])
            item = [ZWDeviceItemSensorMulti device];
        else if ([_type isEqualToString:@"Meter"])
            item = [ZWDeviceItemMeter device];
        else if ([_type isEqualToString:@"Thermostat"])
            item = [ZWDeviceItemThermostat device];
        else if ([_type isEqualToString:@"Blinds"])
            item = [ZWDeviceItemBlinds device];
        else if ([_type isEqualToString:@"Battery"])
            item = [ZWDeviceItemBattery device];
        else
            item = [[ZWDeviceItem alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_type];
    }
    
    [item updateWithData:_data andDevice:_device andInstance:_instance withId:_deviceId andInstanceId:_instanceId andCCId:_ccId];
    
    return item;
}

- (CGFloat)height
{
    if ([_type isEqualToString:@"Dimmer"])
    {
        return 90;
    }
    else if ([_type isEqualToString:@"Switch"])
    {
        return 60;
    }
    else if ([_type isEqualToString:@"Thermostat"])
    {
        return 90;
    }
    else if ([_type isEqualToString:@"SensorBinary"] ||
             [_type isEqualToString:@"SensorMulti"] ||
             [_type isEqualToString:@"Meter"])
    {
        return 60;
    }
    else if ([_type isEqualToString:@"Blinds"])
    {
        return 100;
    }
    else if ([_type isEqualToString:@"Battery"])
    {
        return 60;
    }
    
    return 44;
}

@end
