//
//  ZWRootViewController.m
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

#import "ZWRootViewController.h"
#import <GMGridView/GMGridView.h>
#import <GMGridView/GMGridViewLayoutStrategies.h>
#import <QuartzCore/QuartzCore.h>
#import "ZWAppDelegate.h"
#import "ZWProfilesController.h"
#import "ZWCategoryItem.h"
#import "ZWDevicesViewController.h"
#import "CMProfile.h"
#import "ZWRootViewCell.h"
#import "ZWDeviceInfo.h"
#import "ZWRulesLoader.h"
#import "TFHpple.h"

@implementation ZWRootViewController

@synthesize gridView = _gridView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pages = [NSMutableArray new];
        [_pages addObject:[[ZWRootViewCell alloc] initWithTitle:NSLocalizedString(@"$AllDevices", @"") andImage:@"house.png" andClass:[ZWDevicesViewController class] forIdentifier:@"AllDevices"]];
        [_pages addObject:[[ZWRootViewCell alloc] initWithTitle:NSLocalizedString(@"$Lights", @"") andImage:@"lights.png" andClass:[ZWDevicesViewController class] forIdentifier:@"Lights"]];
        [_pages addObject:[[ZWRootViewCell alloc] initWithTitle:NSLocalizedString(@"$Sensors", @"") andImage:@"sensors.png" andClass:[ZWDevicesViewController class] forIdentifier:@"Sensors"]];
        [_pages addObject:[[ZWRootViewCell alloc] initWithTitle:NSLocalizedString(@"$Meters", @"") andImage:@"meters.png" andClass:[ZWDevicesViewController class] forIdentifier:@"Meters"]];
        [_pages addObject:[[ZWRootViewCell alloc] initWithTitle:NSLocalizedString(@"$Thermostats", @"") andImage:@"thermostats.png" andClass:[ZWDevicesViewController class] forIdentifier:@"Thermostats"]];
        [_pages addObject:[[ZWRootViewCell alloc] initWithTitle:NSLocalizedString(@"$Blinds", @"") andImage:@"blinds.png" andClass:[ZWDevicesViewController class] forIdentifier:@"Blinds"]];
        [_pages addObject:[[ZWRootViewCell alloc] initWithTitle:NSLocalizedString(@"$Batteries", @"") andImage:@"batteries.png" andClass:[ZWDevicesViewController class] forIdentifier:@"Batteries"]];
        
        _mapping = [NSMutableDictionary new];
        [self initFilters];
        
        _lastTimestamp = 0;
        
        _prevSuccessExternalSet = NO;
        _prevSuccessExternal = NO;
        _invalidCredentials = NO;
    }
    return self;
}

- (void)dealloc
{
    _stateIconView = nil;
    
    _pages = nil;
    _mapping = nil;
    
    _data = nil;
    _rulesXml = nil;
}

- (void)initFilters
{
    [_mapping setObject:[^(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) {
        if ([ccId isEqualToString:@"37"])
        {
            // SwitchBinary
            NSObject *genericType = [inst valueForKeyPath:@"data.genericType.value"];
            NSObject *specificType = [inst valueForKeyPath:@"data.specificType.value"];
            if ([genericType isKindOfClass:[NSNumber class]] && [specificType isKindOfClass:[NSNumber class]])
            {
                if ([(NSNumber*)genericType integerValue] != 0x11 || [(NSNumber*)specificType integerValue] < 3 || [(NSNumber*)specificType integerValue] == 4)
                {
                    [result addObject:[ZWDeviceInfo deviceWithType:@"Switch" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:cc]];
                }
            }
        }
        else if ([ccId isEqualToString:@"38"])
        {
            // SwitchMultilevel
            NSObject *genericType = [inst valueForKeyPath:@"data.genericType.value"];
            NSObject *specificType = [inst valueForKeyPath:@"data.specificType.value"];
            if ([genericType isKindOfClass:[NSNumber class]] && [specificType isKindOfClass:[NSNumber class]])
            {
                if ([(NSNumber*)genericType integerValue] != 0x11 || [(NSNumber*)specificType integerValue] < 3 || [(NSNumber*)specificType integerValue] == 4)
                {
                    [result addObject:[ZWDeviceInfo deviceWithType:@"Dimmer" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:cc]];
                }
            }
        }
    } copy] forKey:@"Lights"];
    
    // =========================================================
    
    [_mapping setObject:[^(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) {
        if ([ccId isEqualToString:@"48"])
        {
            // SensorBinary
            [result addObject:[ZWDeviceInfo deviceWithType:@"SensorBinary" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:cc]];
        }
        else if ([ccId isEqualToString:@"49"])
        {
            if ([type isEqualToString:@"AllDevices"] && ([inst valueForKeyPath:@"commandClasses.64"] != nil || [inst valueForKeyPath:@"commandClasses.67"] != nil))
            {
                // this is a thermostat, don't show sensor in AllDevices view
                return;
            }
            
            // SensorMultilevel
            [result addObject:[ZWDeviceInfo deviceWithType:@"SensorMulti" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:cc]];
        }
        else if ([ccId isEqualToString:@"50"])
        {
            // Meter
            for (int i = 0; i < 32; i++)
            {
                NSString *scaleId = [NSString stringWithFormat:@"%d", i];
                
                NSObject *scaleObj = [cc objectForKey:scaleId];
                if ([scaleObj isKindOfClass:[NSDictionary class]])
                {
                    NSObject *sensorType = [scaleObj valueForKeyPath:@"sensorType.value"];
                    if ([sensorType isKindOfClass:[NSNumber class]])
                    {
                        if ((i == 2 || i == 4 || i == 6) && [(NSNumber*)sensorType integerValue] == 1)
                        {
                            [result addObject:[ZWDeviceInfo deviceWithType:@"Meter" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:(NSDictionary*)scaleObj]];
                        }
                    }
                }
            }
        }
    } copy] forKey:@"Sensors"];
    
    // =========================================================
    
    [_mapping setObject:[^(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) {
        if ([ccId isEqualToString:@"50"])
        {
            // Meter
            for (int i = 0; i < 32; i++)
            {
                NSString *scaleId = [NSString stringWithFormat:@"%d", i];
                
                NSObject *scaleObj = [cc objectForKey:scaleId];
                if ([scaleObj isKindOfClass:[NSDictionary class]])
                {
                    NSObject *sensorType = [scaleObj valueForKeyPath:@"sensorType.value"];
                    if ([sensorType isKindOfClass:[NSNumber class]])
                    {
                        if ((i == 2 || i == 4 || i == 6) && [(NSNumber*)sensorType integerValue] == 1) continue;
                        
                        [result addObject:[ZWDeviceInfo deviceWithType:@"Meter" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:(NSDictionary*)scaleObj]];
                    }
                }
            }
        }
    } copy] forKey:@"Meters"];
    
    // =========================================================
    
    [_mapping setObject:[^(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) {
        if ([ccId isEqualToString:@"64"] && [inst valueForKeyPath:@"commandClasses.67"] == nil)
        {
            // ThermostatMode
            [result addObject:[ZWDeviceInfo deviceWithType:@"Thermostat" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:cc]];
        }
        else if ([ccId isEqualToString:@"67"])
        {
            // ThermostatSetPoint
            [result addObject:[ZWDeviceInfo deviceWithType:@"Thermostat" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:cc]];
        }
    } copy] forKey:@"Thermostats"];
    
    // =========================================================
    
    [_mapping setObject:[^(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) {
        if ([ccId isEqualToString:@"38"])
        {
            // SwitchMultilevel
            NSObject *genericType = [inst valueForKeyPath:@"data.genericType.value"];
            NSObject *specificType = [inst valueForKeyPath:@"data.specificType.value"];
            if ([genericType isKindOfClass:[NSNumber class]] && [specificType isKindOfClass:[NSNumber class]])
            {
                if ([(NSNumber*)genericType integerValue] == 0x11 && [(NSNumber*)specificType integerValue] >= 3 && [(NSNumber*)specificType integerValue] != 4)
                {
                    [result addObject:[ZWDeviceInfo deviceWithType:@"Blinds" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:cc]];
                }
            }
        }
    } copy] forKey:@"Blinds"];
    
    // =========================================================
    
    [_mapping setObject:[^(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) {
        if ([ccId isEqualToString:@"128"])
        {
            // Battery
            [result addObject:[ZWDeviceInfo deviceWithType:@"Battery" forDeviceId:devId device:dev andInstanceId:instId instance:inst andCCId:ccId withData:cc]];
        }
    } copy] forKey:@"Batteries"];
    
    // =========================================================
    
    [_mapping setObject:[^(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) {
        for (NSString* key in _mapping)
        {
            if ([key isEqualToString:@"AllDevices"]) continue;
            
            // do not show batteries in all devices
            if ([ccId isEqualToString:@"128"]) continue;
            
            void (^processor)(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) = [_mapping objectForKey:key];
            
            if (processor == nil) continue;
            
            processor(result, devId, dev, instId, inst, ccId, cc, type);
        }
    } copy] forKey:@"AllDevices"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.gridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    self.gridView.style = GMGridViewStylePush;
    self.gridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontalPagedLTR];
    self.gridView.dataSource = self;
    self.gridView.actionDelegate = self;
    self.gridView.transformDelegate = nil;
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.gridView];
    
    [self.navigationItem setTitle:@"Z-Way"];
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Profiles", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings:)];
    
    _stateIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 34)];
    [_stateIconView setContentMode:UIViewContentModeCenter];
    
    [_stateIconView setImage:[UIImage imageNamed:@"disconnected-w.png"]];
    
    UIBarButtonItem *stateIcon = [[UIBarButtonItem alloc] initWithCustomView:_stateIconView];
    
    self.navigationItem.leftBarButtonItem = settingsButton;
    self.navigationItem.rightBarButtonItem = stateIcon;
    
    _data = nil;
    
    CMProfile *profile = ZWAppDelegate.sharedDelegate.profile;
    if (profile != nil)
    {
        _dataTree = [[ZWDataTree alloc] initWithTimestamp:0 andProfile:profile andDelegate:self];
        [_dataTree start];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileHasChanged:) name:@"ZWProfileHasChanged" object:nil];
}

- (void)viewDidUnload
{
    [_dataTree cancel];
    _dataTree = nil;
    
    [_rulesLoader cancel];
    _rulesLoader = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ZWProfileHasChanged" object:nil];
    
    [super viewDidUnload];
}

- (void)profileHasChanged:(NSNotification*)notification
{
    [_dataTree cancel];
    _dataTree = nil;
    _data = nil;
    
    [_rulesLoader cancel];
    _rulesLoader = nil;
    _rulesXml = nil;
    _invalidCredentials = NO;
    
    CMProfile *profile = ZWAppDelegate.sharedDelegate.profile;
    if (profile == nil) return;
    
    _dataTree = [[ZWDataTree alloc] initWithTimestamp:0 andProfile:profile andDelegate:self];
    [_dataTree start];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showSettings:(id)sender
{
    [ZWAppDelegate.sharedDelegate.window.rootViewController presentModalViewController:ZWAppDelegate.sharedDelegate.profilesNavController animated:YES];
}

- (void)resumeFromBackground
{
    if (_dataTree == nil) return;
    
    [_dataTree cancel];
    
    _invalidCredentials = NO;
    
    CMProfile *profile = ZWAppDelegate.sharedDelegate.profile;
    if (profile == _dataTree.profile)
    {
        _dataTree = [[ZWDataTree alloc] initWithTimestamp:_lastTimestamp andProfile:profile andDelegate:self];
        [_dataTree performSelector:@selector(start) withObject:nil afterDelay:1];
    }
}

- (void)authorizationFailure:(ZWDataUpdater *)updater
{
    if (!_invalidCredentials)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"$InvalidCredentialsTitle", @"") message:NSLocalizedString(@"$InvalidCredentialsText", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        
        [alert show];
        
        _invalidCredentials = YES;
    }
}

- (void)updaterFinished:(ZWDataUpdater*)updater withResult:(BOOL)success
{
    if (updater == _dataTree)
    {
        CMProfile *prof = _dataTree.profile;
        
        @synchronized(prof)
        {
            BOOL wasOutdoor = _dataTree.usingExternal;
            
            if (!success)
            {
                // try switching to another server
                prof.useOutdoor = [NSNumber numberWithBool:!wasOutdoor];
            }
            
            if (!success)
            {
                [self updateState:NO];
            }
            else
            {
                [self updateState:YES];
                _invalidCredentials = NO;
            }
            
            if (success)
            {
                NSDictionary *json = (NSDictionary*)[(ZWDataTree*)updater json];
                _lastTimestamp = [[json valueForKey:@"updateTime"] unsignedIntegerValue];
                
                if (_prevSuccessExternalSet && wasOutdoor != _prevSuccessExternal)
                {
                    // switched from external to internal server, or vica versa
                    _data = nil;
                    _rulesXml = nil;
                    
                    _lastTimestamp = 0;
                }
                else
                {
                    // same server, process updates
                    
                    if (_data == nil)
                        _data = [NSMutableDictionary dictionary];
                    
                    for (NSString *p in json.allKeys)
                    {
                        NSObject *value = [json valueForKey:p];
                        [_data setValue:value forKeyPath:p];
                    }
                    
                    if (json.count > 1)
                    {
                        UIViewController *controller = [self.navigationController topViewController];
                        if ([controller isKindOfClass:[ZWDevicesViewController class]])
                        {
                            [((ZWDevicesViewController*)controller) setRules:_rulesXml];
                            [((ZWDevicesViewController*)controller) setDevices:[self getDevices:_data forType:((ZWDevicesViewController*)controller).identifier]];
                        }
                        else if ([controller respondsToSelector:@selector(refresh)])
                        {
                            [(id)controller refresh];
                        }
                    }
                }
                
                _prevSuccessExternal = wasOutdoor;
                _prevSuccessExternalSet = YES;
            }
            
            CMProfile *profile = ZWAppDelegate.sharedDelegate.profile;
            if (profile == prof)
            {
                _dataTree = [[ZWDataTree alloc] initWithTimestamp:_lastTimestamp andProfile:profile andDelegate:self];
                [_dataTree performSelector:@selector(start) withObject:nil afterDelay:1];
                
                if (success && _rulesXml == nil)
                {
                    _rulesLoader = [[ZWRulesLoader alloc] initWithProfile:profile andDelegate:self];
                    [_rulesLoader start];
                }
            }
        }
    }
    else if (updater == _rulesLoader)
    {
        if (success)
        {
            _rulesXml = _rulesLoader.xml;
            
            UIViewController *controller = [self.navigationController topViewController];
            if ([controller isKindOfClass:[ZWDevicesViewController class]])
            {
                [((ZWDevicesViewController*)controller) setRules:_rulesXml];
                [((ZWDevicesViewController*)controller) refresh];
            }
        }
        else
        {
            _rulesXml = nil;
        }
    }
}

- (void)updateState:(BOOL)connected
{
    UIImage *image;
    
    if (connected)
    {
        image = [UIImage imageNamed:@"connected-w.png"];;
    }
    else
    {
        image = [UIImage imageNamed:@"disconnected-w.png"];;
    }
    
    [_stateIconView setImage:image];
    _isConnected = connected;
    
    UIViewController *controller = [self.navigationController topViewController];
    if ([controller isKindOfClass:[ZWDevicesViewController class]])
    {
        [((ZWDevicesViewController*)controller) updateState:image isConnected:connected];
    }
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return _pages.count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return CGSizeMake(200, 200);
    }
    else
    {
        return CGSizeMake(90, 90);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    if (index < 0 || index >= _pages.count) return nil;
    
    ZWCategoryItem *cell = (ZWCategoryItem*)[gridView dequeueReusableCellWithIdentifier:@"Item"];
    if (cell == nil)
    {
        cell = [[ZWCategoryItem alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        cell.reuseIdentifier = @"Item";
    }
    
    ZWRootViewCell* x = [_pages objectAtIndex:index];
    
    cell.titleLabel.text = x.title;
    cell.imageView.image = [UIImage imageNamed:x.image];
    
    return cell;
}

- (void)getDevice:(NSDictionary*)device withId:(NSString*)deviceId instance:(NSDictionary*)instance withId:(NSString*)instanceId toArray:(NSMutableArray*)result forType:(NSString*)type
{
    NSSet *supportedCommandClasses = [NSSet setWithObjects:@"37", @"38", @"48", @"49", @"50", @"64", @"67", nil];
    
    NSDictionary *commandClasses = [instance objectForKey:@"commandClasses"];
    NSArray *ccIds = [commandClasses.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 integerValue] - [obj2 integerValue];
    }];
    
    for (NSString *ccId in ccIds)
    {
        if (![supportedCommandClasses containsObject:ccId]) continue;
        
        NSDictionary *commandClass = [commandClasses objectForKey:ccId];
        
        void (^processor)(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) = [_mapping objectForKey:type];
        if (processor != nil)
        {
            processor(result, deviceId, device, instanceId, instance, ccId, [commandClass valueForKey:@"data"], type);
        }
    }
}

- (void)getDevice:(NSDictionary*)device withId:(NSString*)deviceId zeroInstance:(NSDictionary*)instance toArray:(NSMutableArray*)result forType:(NSString*)type
{
    NSSet *supportedCommandClasses = [NSSet setWithObjects:@"128", nil];
    
    NSDictionary *commandClasses = [instance objectForKey:@"commandClasses"];
    NSArray *ccIds = [commandClasses.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 integerValue] - [obj2 integerValue];
    }];
    
    for (NSString *ccId in ccIds)
    {
        if (![supportedCommandClasses containsObject:ccId]) continue;
        
        NSDictionary *commandClass = [commandClasses objectForKey:ccId];
        
        void (^processor)(NSMutableArray* result, NSString* devId, NSDictionary* dev, NSString* instId, NSDictionary* inst, NSString* ccId, NSDictionary* cc, NSString* type) = [_mapping objectForKey:type];
        if (processor != nil)
        {
            processor(result, deviceId, device, @"0", instance, ccId, [commandClass valueForKey:@"data"], type);
        }
    }
}

- (NSArray*)getDevices:(NSObject*)data forType:(NSString*)type
{
    NSMutableArray *finalObjects = [NSMutableArray new];
    
    NSObject *controllerId = [data valueForKeyPath:@"controller.data.nodeId.value"];
    
    NSDictionary *devices = [data valueForKey:@"devices"];
    NSArray *deviceIds = [devices.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 integerValue] - [obj2 integerValue];
    }];
    
    for (NSString *deviceId in deviceIds)
    {
        if ([controllerId isKindOfClass:[NSNumber class]])
        {
            if ([deviceId integerValue] == [(NSNumber*)controllerId integerValue]) continue;
        }
        
        NSDictionary *device = [devices objectForKey:deviceId];
        
        NSDictionary *instances = [device objectForKey:@"instances"];
        NSArray *instanceIds = [instances.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 integerValue] - [obj2 integerValue];
        }];
        
        // enumerate default-instance-only devices
        [self getDevice:device withId:deviceId zeroInstance:[instances objectForKey:@"0"] toArray:finalObjects forType:type];
        
        // enumerate devices on non-default instances
        NSInteger count = finalObjects.count;
        
        for (NSString *instanceId in instanceIds)
        {
            if ([instanceId isEqualToString:@"0"]) continue;
            
            NSDictionary *instance = [instances objectForKey:instanceId];
            
            [self getDevice:device withId:deviceId instance:instance withId:instanceId toArray:finalObjects forType:type];
        }
        
        // enumerate default instance devices, if there's no non-default instance devices
        if (finalObjects.count == count)
        {
            [self getDevice:device withId:deviceId instance:[instances objectForKey:@"0"] withId:@"0" toArray:finalObjects forType:type];
        }
    }

    return finalObjects;
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    ZWRootViewCell* x = [_pages objectAtIndex:position];
    
    UIViewController *c;
    if ([x.pageClass isSubclassOfClass:[ZWDevicesViewController class]])
    {
        c = [[x.pageClass alloc] initWithNibName:@"ZWDevicesView" bundle:nil];
        
        [c view]; // force view load
        
        ((ZWDevicesViewController*)c).identifier = x.identifier;
        [((ZWDevicesViewController*)c) updateState:_stateIconView.image isConnected:_isConnected];
        [((ZWDevicesViewController*)c) setRules:_rulesXml];
        [((ZWDevicesViewController*)c) setDevices:[self getDevices:_data forType:x.identifier]];
    }
    else if (_data != nil)
    {
        c = [[x.pageClass alloc] init];
        
        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:_data options:NSJSONWritingPrettyPrinted error:&err];
        
        UITextView *text = [[UITextView alloc] initWithFrame:c.view.bounds];
        text.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [c.view addSubview:text];
        
        c.view.backgroundColor = [UIColor whiteColor];
    }
    
    [c.navigationItem setTitle:x.title];
        
    [self.navigationController pushViewController:c animated:YES];
}

@end
