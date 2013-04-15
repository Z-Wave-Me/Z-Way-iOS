//
//  ZWDeviceItemDimmer.h
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

#import <UIKit/UIKit.h>
#import "ZWDataUpdaterEvents.h"
#include "ZWDeviceItem.h"

@class ZWRunCommand;

@interface ZWDeviceItemDimmer : ZWDeviceItem<ZWDataUpdaterEvents>
{
    ZWRunCommand *_lastRun;
    id _lastSender;
}

@property (strong, nonatomic) IBOutlet UISwitch *switchView;
@property (strong, nonatomic) IBOutlet UISlider *sliderView;
@property (strong, nonatomic) NSString *commandPath;

- (IBAction)switch:(id)sender;
- (IBAction)setValue:(id)sender;

+ (ZWDeviceItemDimmer*)device;

@end
