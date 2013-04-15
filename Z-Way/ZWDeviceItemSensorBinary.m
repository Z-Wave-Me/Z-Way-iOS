//
//  ZWDeviceItemSensorBinary.m
//  Z-Way
//
//  Created by Alex Skalozub on 8/22/12.
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

#import "ZWDeviceItemSensorBinary.h"
#import "ZWRunCommand.h"
#import "ZWAppDelegate.h"

@implementation ZWDeviceItemSensorBinary

@synthesize valueView = _valueView;
@synthesize commandPath = _commandPath;

+ (ZWDeviceItemSensorBinary*)device
{
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"ZWDeviceItemSensorBinary" owner:nil options:nil];
    return [a objectAtIndex:0];
}

- (void)dealloc
{
    self.valueView = nil;
    self.commandPath = nil;
}

- (NSString*)refreshingStateKey
{
    return @"level";
}

- (void)updateWithData:(NSDictionary *)data andDevice:(NSObject *)device andInstance:(NSObject *)instance withId:(NSString *)deviceId andInstanceId:(NSString *)instanceId andCCId:(NSString *)ccId
{
    [super updateWithData:data andDevice:device andInstance:instance withId:deviceId andInstanceId:instanceId andCCId:ccId];
    
    self.commandPath = [NSString stringWithFormat:@"devices[%@].instances[%@].commandClasses[%@]", deviceId, instanceId, ccId];
    
    NSObject *value = [data valueForKeyPath:@"level.value"];
    if (value == nil || [value isKindOfClass:[NSNull class]])
    {
        [self.valueView setEnabled:NO];
    }
    else
    {
        BOOL v = [(NSNumber*)value boolValue];
        
        [self.valueView setTitle:NSLocalizedString(v ? @"On" : @"Off", @"") forState:UIControlStateNormal];
        [self.valueView setEnabled:YES];
    }
}

- (void)refresh:(id)sender
{
    if (!self.refreshingImage.isHidden) return;
    
    ZWRunCommand *run = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@.Get()", self.commandPath] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:self];
    self.refreshingImage.hidden = NO;
    [run start];
}

- (void)updaterFinished:(ZWDataUpdater *)updater withResult:(BOOL)success
{
    [self refresh];
}

@end
