//
//  ZWDeviceItem.m
//  Z-Way
//
//  Created by Alex Skalozub on 8/28/12.
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

#import "ZWDeviceItem.h"

@implementation ZWDeviceItem

@synthesize refreshingImage = _refreshingImage;
@synthesize nameView = _nameView;

- (void)dealloc
{
    self.refreshingImage = nil;
    self.nameView = nil;
}

+ (NSString*)formatScaledValue:(NSObject*)object withValue:(NSString*)valueKey andScale:(NSString*)scaleKey
{
    if (object == nil || valueKey == nil) return nil;
    
    NSObject *value = [object valueForKeyPath:valueKey];
    if (value == nil || [value isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    else
    {
        NSString *s = [NSString stringWithFormat:@"%@", value];
        
        if (scaleKey != nil)
        {
            NSObject *scaleString = [object valueForKeyPath:scaleKey];
            if (scaleString != nil && [scaleString isKindOfClass:[NSString class]])
                s = [s stringByAppendingFormat:@" %@", NSLocalizedString((NSString*)scaleString, @"")];
        }
        
        return s;
    }
}

- (NSString*)refreshingStateKey
{
    return nil;
}

- (void)updateWithData:(NSDictionary *)data andDevice:(NSObject *)device andInstance:(NSObject *)instance withId:(NSString *)deviceId andInstanceId:(NSString *)instanceId andCCId:(NSString *)ccId
{
    // set display name
    
    NSObject *name = [device valueForKeyPath:@"instances.0.commandClasses.119.data.nodename.value"];
    
    if (name == nil || [name isKindOfClass:[NSNull class]] || [name isEqual:@""])
    {
        name = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Device", @""), deviceId];
    }
    
    if (instanceId != nil && ![instanceId isEqualToString:@"0"])
    {
        name = [NSString stringWithFormat:@"%@ #%@", name, instanceId];
    }
    
    self.nameView.text = (NSString*)name;
    
    // set refreshing state
    
    BOOL isValid = YES;
    if (self.refreshingStateKey != nil)
    {
        NSObject *sourceObj;
        if (self.refreshingStateKey.length > 15 && [[self.refreshingStateKey substringToIndex:15] isEqualToString:@"commandClasses."])
        {
            sourceObj = instance;
        }
        else
        {
            sourceObj = data;
        }

        NSObject *refreshingState;
        
        if ([self.refreshingStateKey isEqualToString:@""])
        {
            refreshingState = sourceObj;
        }
        else
        {
            refreshingState = [sourceObj valueForKeyPath:self.refreshingStateKey];
        }
        
        if (refreshingState != nil)
        {
            NSObject *invalidateTime = [refreshingState valueForKey:@"invalidateTime"];
            NSObject *updateTime = [refreshingState valueForKey:@"updateTime"];
            
            if (invalidateTime != nil && [invalidateTime isKindOfClass:[NSNumber class]])
            {
                if (updateTime == nil || [updateTime isKindOfClass:[NSNull class]] ||
                    ([updateTime isKindOfClass:[NSNumber class]] && [(NSNumber*)updateTime unsignedIntegerValue] < [(NSNumber*)invalidateTime unsignedIntegerValue]))
                {
                    isValid = NO;
                }
            }
        }
    }
    
    self.refreshingImage.hidden = isValid;
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)refresh
{
    UITableView *table = (UITableView*)self.superview;
    if (![table isKindOfClass:[UITableView class]]) return;
    
    NSIndexPath *path = [table indexPathForCell:self];
    if (path == nil) return;
    
    [table reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)lockUpdates
{
    UITableView *table = (UITableView*)self.superview;
    if (![table isKindOfClass:[UITableView class]]) return;
    
    [table setScrollEnabled:NO];
}

- (void)unlockUpdates
{
    UITableView *table = (UITableView*)self.superview;
    if (![table isKindOfClass:[UITableView class]]) return;
    
    [table setScrollEnabled:YES];
    [table reloadData];
}

- (NSComparisonResult)compare:(UITableViewCell *)other
{
    if (other == self) return 0;
    
    return 1;
}

@end
