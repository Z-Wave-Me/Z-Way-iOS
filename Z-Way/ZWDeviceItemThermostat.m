//
//  ZWDeviceItemThermostat.m
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

#import "ZWDeviceItemThermostat.h"
#import "ZWAppDelegate.h"
#import "ZWRunCommand.h"
#import "ZWPickerPopup.h"

@implementation ZWDeviceItemThermostat

@synthesize temperatureView = _temperatureView;
@synthesize modeView = _modeView;
@synthesize commandPath = _commandPath;

+ (ZWDeviceItemThermostat*)device
{
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"ZWDeviceItemThermostat" owner:nil options:nil];
    return [a objectAtIndex:0];
}

- (void)dealloc
{
    _modes = nil;
    _modeNames = nil;
    _temperatures = nil;
    _modeTemperatures = nil;
    
    self.temperatureView = nil;
    self.modeView = nil;
    self.commandPath = nil;
}

- (NSString*)refreshingStateKey
{
    return @"commandClasses.49.data.val";
}

- (void)updateWithData:(NSDictionary *)data andDevice:(NSObject *)device andInstance:(NSObject *)instance withId:(NSString *)deviceId andInstanceId:(NSString *)instanceId andCCId:(NSString *)ccId
{
    [super updateWithData:data andDevice:device andInstance:instance withId:deviceId andInstanceId:instanceId andCCId:ccId];
    
    self.commandPath = [NSString stringWithFormat:@"devices[%@].instances[%@].commandClasses", deviceId, instanceId];
    
    _modes = [NSMutableArray array];
    _modeNames = [NSMutableDictionary dictionary];
    _temperatures = [NSMutableArray array];
    _modeTemperatures = [NSMutableDictionary dictionary];
    
    NSDictionary *modes = [instance valueForKeyPath:@"commandClasses.64.data"];
    for (int i = 0; i < 32; i++)
    {
        NSString *modeKey = [NSString stringWithFormat:@"%d", i];
        
        NSObject *mode = [modes valueForKey:modeKey];
        if (![mode isKindOfClass:[NSDictionary class]]) continue;
        
        [(NSMutableArray*)_modes addObject:modeKey];
        
        NSObject *modeName = [mode valueForKeyPath:@"modeName.value"];
        if (![modeName isKindOfClass:[NSString class]])
            modeName = [NSString stringWithFormat:@"Mode # %@", modeKey];
        
        [(NSMutableDictionary*)_modeNames setObject:modeName forKey:modeKey];
    }
        
    for (int i = 6; i < 36; i++)
    {
        [(NSMutableArray*)_temperatures addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    _tempMode = @"0";
    
    NSDictionary *modes2 = [instance valueForKeyPath:@"commandClasses.67.data"];
    for (int i = 0; i < 32; i++)
    {
        NSString *modeKey = [NSString stringWithFormat:@"%d", i];
        
        NSObject *mode = [modes2 valueForKey:modeKey];
        if (![mode isKindOfClass:[NSDictionary class]]) continue;

        _tempMode = modeKey;
        
        NSObject *modeTemperature = [mode valueForKeyPath:@"val.value"];
        if ([modeTemperature isKindOfClass:[NSNumber class]])
            [(NSMutableDictionary*)_modeTemperatures setObject:modeTemperature forKey:modeKey];
    }
    
    NSMutableString *buffer = [[NSMutableString alloc] init];
    
    _selectedMode = 0;
    _selectedTemp = 0;
    
    NSObject *modeIndex = [instance valueForKeyPath:@"commandClasses.64.data.mode.value"];
    if ([modeIndex isKindOfClass:[NSNumber class]])
    {
        _selectedMode = [(NSNumber*)modeIndex integerValue];
        
        NSObject *modeName = [instance valueForKeyPath:[NSString stringWithFormat:@"commandClasses.64.data.%@.modeName.value", modeIndex]];
        if ([modeName isKindOfClass:[NSString class]])
        {
            [buffer appendString:NSLocalizedString((NSString*)modeName, @"")];
        }
        
        NSObject *setPointObj = [instance valueForKeyPath:[NSString stringWithFormat:@"commandClasses.67.data.%@", modeIndex]];
        if (setPointObj != nil)
        {
            NSString *value = [ZWDeviceItem formatScaledValue:setPointObj withValue:@"val.value" andScale:@"scaleString.value"];
            if (value != nil)
            {
                NSObject *setPointValue = [setPointObj valueForKeyPath:@"val.value"];
                if ([setPointValue isKindOfClass:[NSNumber class]])
                    _selectedTemp = [(NSNumber*)setPointValue integerValue];
                
                if (buffer.length > 0)
                    [buffer appendString:@", "];
                
                [buffer appendString:value];
            }
        }
    }
    
    if (buffer.length == 0)
    {
        [self.modeView setTitle:@"—" forState:UIControlStateNormal];
        [self.modeView setEnabled:YES];
    }
    else
    {
        [self.modeView setTitle:buffer forState:UIControlStateNormal];
        [self.modeView setEnabled:YES];
    }
    
    NSObject *value = [instance valueForKeyPath:@"commandClasses.49.data.val.value"];
    if (value == nil || [value isKindOfClass:[NSNull class]])
    {
        [self.temperatureView setEnabled:NO];
    }
    else
    {
        NSString *s = [NSString stringWithFormat:@"%@", value];
        
        NSObject *scaleString = [instance valueForKeyPath:@"commandClasses.49.data.scaleString.value"];
        if (scaleString != nil && [scaleString isKindOfClass:[NSString class]])
            s = [s stringByAppendingFormat:@" %@", scaleString];
        
        [self.temperatureView setTitle:s forState:UIControlStateNormal];
        [self.temperatureView setEnabled:YES];
    }
}

- (void)refresh:(id)sender
{
    if (!self.refreshingImage.isHidden) return;
    
    ZWRunCommand *run = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@[49].Get()", self.commandPath] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
    //self.refreshingImage.hidden = NO;
    [run start];
}

- (void)setMode:(id)sender
{
    // nothing to pick
    if (_modes.count == 0 && _temperatures.count == 0) return;
    
    ZWPickerPopup *pickerPopup = [[ZWPickerPopup alloc] initWithParent:(UIView *)sender];
    UIPickerView *modePicker = pickerPopup.picker;
    
    //UIPickerView *modePicker = [[UIPickerView alloc] init];
    modePicker.showsSelectionIndicator = YES;
    modePicker.dataSource = self;
    modePicker.delegate = self;
    modePicker.tag = 1;

    NSInteger component = 0;
    
    if (_modes.count > 0)
    {
        NSInteger index = [_modes indexOfObject:[NSString stringWithFormat:@"%d", _selectedMode]];
        if (index != NSNotFound)
            [modePicker selectRow:index inComponent:component animated:NO];
        
        _lastSelectedMode = index;
        
        component++;
    }
    
    if (_temperatures.count > 0)
    {
        NSInteger temp;
        
        if (_modes.count > 0)
        {
            NSNumber *t = [_modeTemperatures objectForKey:[NSString stringWithFormat:@"%d", _selectedMode]];
            if (t != nil)
                temp = [t integerValue];
        }
        else
            temp = _selectedTemp;
        
        [modePicker reloadComponent:component];
        
        NSInteger index = [_temperatures indexOfObject:[NSString stringWithFormat:@"%d", temp]];
        if (index != NSNotFound)
        {
            _lastSelectedTemp = index;
            
            [modePicker selectRow:index inComponent:component animated:NO];
        }
        
        component++;
    }
    
    [modePicker setNeedsLayout];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    /*UIButton *modeDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [modeDone setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [modeDone addTarget:self action:@selector(setModeDone:) forControlEvents:UIControlEventTouchUpInside];
    
    UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [actions setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    [actions addSubview:modeDone];
    [actions addSubview:modePicker];
    
    [actions setNeedsLayout];
    [actions showInView:window];
    
    CGRect screen = [UIScreen mainScreen].bounds;
    
    CGFloat height = screen.size.height / 2;
    
    [modeDone setFrame:CGRectMake(240, 10, 70, 30)];
    [modePicker setFrame:CGRectMake(0, 50, screen.size.width, height - 25)];
    [actions setFrame:CGRectMake(0, screen.size.height - height - 25, screen.size.width, height + 25)];*/
    
    [window addSubview:pickerPopup];
    [pickerPopup becomeFirstResponder];
    [pickerPopup addTarget:self action:@selector(setModeDone:) forControlEvents:UIControlEventValueChanged];
}

- (void)setModeDone:(ZWPickerPopup*)sender
{
    UIPickerView *pickerView = sender.picker;
    
    [sender removeTarget:self action:@selector(setModeDone:) forControlEvents:UIControlEventValueChanged];
    [sender removeFromSuperview];
    
    NSInteger component = 0;
    
    if (_modes.count > 0)
    {
        NSString *modeIndex = [_modes objectAtIndex:[pickerView selectedRowInComponent:component]];
    
        ZWRunCommand *command = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@[64].Set(%@)",  self.commandPath, modeIndex] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
        self.refreshingImage.hidden = NO;
        [command start];
        
        component++;
    }
    
    if (_temperatures.count > 0)
    {
        NSString *modeIndex;
        
        if (_modes.count > 0)
        {
            modeIndex = [_modes objectAtIndex:[pickerView selectedRowInComponent:0]];
            if ([modeIndex isEqualToString:@"0"])
                modeIndex = nil;
        }
        else
            modeIndex = _tempMode;
        
        if (modeIndex != nil)
        {
            NSString *temperature = [_temperatures objectAtIndex:[pickerView selectedRowInComponent:component]];
            
            ZWRunCommand *command = [[ZWRunCommand alloc] initWithCommand:[NSString stringWithFormat:@"%@[67].Set(%@,%@)", self.commandPath, modeIndex, temperature] andProfile:ZWAppDelegate.sharedDelegate.profile andDelegate:nil];
            self.refreshingImage.hidden = NO;
            [command start];
        }
        
        component++;
    }
}

- (BOOL)areModesAvailable:(UIPickerView*)pickerView
{
    return _modes.count > 0;
}

- (BOOL)areTemperaturesAvailable:(UIPickerView*)pickerView
{
    BOOL b = [self areModesAvailable:pickerView];
    if (b)
    {
        if ([[_modes objectAtIndex:_lastSelectedMode] isEqualToString:@"0"])
            return FALSE;
    }
    
    return _temperatures.count > 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return ([self areModesAvailable:pickerView] ? 1 : 0) + 1; //([self areTemperaturesAvailable:pickerView] ? 1 : 0);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0 && [self areModesAvailable:pickerView])
    {
        return _modes.count;
    }
    else if ([self areTemperaturesAvailable:pickerView])
    {
        return _temperatures.count;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0 && [self areModesAvailable:pickerView])
    {
        if ([self areTemperaturesAvailable:pickerView])
            return 230;
        else
            return 290;
    }
    else if ([self areTemperaturesAvailable:pickerView])
    {
        if ([self areModesAvailable:pickerView])
            return 60;
        else
            return 290;
    }
    else
    {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0 && [self areModesAvailable:pickerView])
    {
        return NSLocalizedString([_modeNames objectForKey:[_modes objectAtIndex:row]], @"");
    }
    else
    {
        return [_temperatures objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0 && [self areModesAvailable:pickerView])
    {
        _lastSelectedMode = row;
        
        NSString *modeIndex = [_modes objectAtIndex:row];
     
        NSInteger temp;
        NSNumber *t = [_modeTemperatures objectForKey:modeIndex];
        if (t != nil)
        {
            temp = [_temperatures indexOfObject:[NSString stringWithFormat:@"%@", t]];
            if (temp == NSNotFound)
                temp = 0;
        }
        else
            temp = _lastSelectedTemp;
        
        [pickerView reloadComponent:1];
        [pickerView setNeedsLayout];
        [pickerView selectRow:temp inComponent:1 animated:YES];
    }
    else if ([self areTemperaturesAvailable:pickerView])
    {
        _lastSelectedTemp = row;
    }
}

@end
