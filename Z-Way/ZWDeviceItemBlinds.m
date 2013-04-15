//
//  ZWDeviceItemBlinds.m
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

#import "ZWDeviceItemBlinds.h"
#import "ZWRunCommand.h"
#import "ZWAppDelegate.h"
#import "CMProfile.h"
#import "ZWBlindsControl.h"

@implementation ZWDeviceItemBlinds

@synthesize buttonsView = _buttonsView;
@synthesize sliderView = _sliderView;
@synthesize commandPath = _commandPath;

+ (ZWDeviceItemBlinds*)device
{
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"ZWDeviceItemBlinds" owner:nil options:nil];
    return [a objectAtIndex:0];
}

- (void)dealloc
{
    self.buttonsView = nil;
    self.sliderView = nil;
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
        [self.sliderView setValue:0];
        [self.sliderView setEnabled:NO];
    }
    else
    {
        int v = [(NSNumber*)value intValue];
        
        [self.sliderView setValue:MIN(MAX(0, v), 99)];
        [self.sliderView setEnabled:YES];
    }
}

- (void)setValue:(id)sender
{
    int value = (int)roundf(self.sliderView.value);
    
    [_lastRun cancel];
    
    _lastRun = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@.Set(%d)", self.commandPath, value] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
    
    [_lastRun start];
}

- (void)pressButton:(id)sender
{
    _isHeld = NO;

    [self lockUpdates];
    
    ZWBlindsControl *ctl = (ZWBlindsControl*)sender;
    
    [_lastRun cancel];
    
    switch (ctl.pressedSegmentIndex)
    {
        case 0: // up
            _lastRun = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@.StartLevelChange(0)", self.commandPath] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
            break;
            
        case 1: // down
            _lastRun = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@.StartLevelChange(1)", self.commandPath] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
            break;
            
        default:
            return;
    }

    [_lastRun start];
}

- (void)pressAndHold:(id)sender
{
    _isHeld = YES;
 
    [self lockUpdates];
    
    /*ZWBlindsControl *ctl = (ZWBlindsControl*)sender;
    
    [_lastRun cancel];
    
    switch (ctl.pressedSegmentIndex)
    {
        case 0: // up
            _lastRun = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@.StartLevelChange(0)", self.commandPath] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
            break;
            
        case 1: // down
            _lastRun = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@.StartLevelChange(1)", self.commandPath] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
            break;
            
        default:
            return;
    }
    
    [_lastRun start];*/
}

- (void)releaseButton:(id)sender
{
    if (_isHeld)
    {
        [_lastRun cancel];
        
        _lastRun = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@.StopLevelChange()", self.commandPath] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
                
        [_lastRun start];
    }
 
    [self unlockUpdates];
    
    _isHeld = NO;
}

- (void)updaterFinished:(ZWDataUpdater*)updater withResult:(BOOL)success
{
    
}

@end
