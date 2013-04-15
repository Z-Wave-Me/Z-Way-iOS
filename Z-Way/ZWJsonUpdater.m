//
//  ZWJsonUpdater.m
//  Z-Way
//
//  Created by Alex Skalozub on 8/18/12.
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

#import "ZWJsonUpdater.h"

@implementation ZWJsonUpdater

- (void)processJson:(NSObject *)json
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)processResults:(NSData *)data
{
    NSError *err = nil;
    NSObject *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    if (err != nil)
    {
        @throw [NSException exceptionWithName:@"Parse error" reason:err.localizedFailureReason userInfo:nil];
    }
    else
    {
        [self processJson:result];
    }
}

@end
