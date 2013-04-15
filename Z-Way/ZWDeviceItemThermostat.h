//
//  ZWDeviceItemThermostat.h
//  Z-Way
//
//  Created by Alex Skalozub on 8/27/12.
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
#import "ZWDeviceItem.h"

@interface ZWDeviceItemThermostat : ZWDeviceItem<UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>
{
    NSInteger _selectedMode;
    NSInteger _selectedTemp;
    NSString *_tempMode;
    
    NSInteger _lastSelectedMode;
    NSInteger _lastSelectedTemp;
    
    NSArray *_modes;
    NSDictionary *_modeNames;
    NSArray *_temperatures;
    NSDictionary *_modeTemperatures;
}

@property (strong, nonatomic) IBOutlet UIButton *temperatureView;
@property (strong, nonatomic) IBOutlet UIButton *modeView;
@property (strong, nonatomic) NSString *commandPath;

- (IBAction)refresh:(id)sender;
- (IBAction)setMode:(id)sender;

+ (ZWDeviceItemThermostat*)device;

@end
