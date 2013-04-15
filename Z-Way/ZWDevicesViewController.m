//
//  ZWDevicesViewController.m
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

#import "ZWDevicesViewController.h"
#import "ZWDeviceInfo.h"
#import "ZWDeviceItem.h"
#import "ZWDeviceItemSwitch.h"
#import "ZWDeviceItemDimmer.h"
#import "ZWDeviceItemSensorBinary.h"
#import "ZWDeviceItemSensorMulti.h"
#import "ZWDeviceItemMeter.h"
#import "ZWDeviceItemThermostat.h"
#import "TFHpple.h"

@implementation ZWDevicesViewController

@synthesize identifier = _identifier;
@synthesize lockUpdates = _lockUpdates;
@synthesize tableView = _tableView;
@synthesize noItemsLabel = _noItemsLabel;

- (void)dealloc
{
    _rulesXml = nil;
    _objects = nil;
    _stateIconView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //_tableView.backgroundView = nil;
    //_tableView.backgroundView = [[UIView alloc] initWithFrame:_tableView.bounds];
    //_tableView.backgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    //_tableView.opaque = NO;
    
    _noItemsLabel.text = NSLocalizedString(@"No devices", @"");
    _noItemsLabel.hidden = YES;
    
    _stateIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 34)];
    [_stateIconView setContentMode:UIViewContentModeCenter];
    
    UIBarButtonItem *stateIcon = [[UIBarButtonItem alloc] initWithCustomView:_stateIconView];
    
    self.navigationItem.rightBarButtonItem = stateIcon;
    
    [self refresh];
}

- (void)viewDidUnload
{
    [_noItemsLabel removeFromSuperview];
    
    [super viewDidUnload];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_noItemsLabel sizeToFit];
    _noItemsLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateState:(UIImage *)stateIcon isConnected:(BOOL)connected
{
    [_stateIconView setImage:stateIcon];
    
    if (connected)
        _noItemsLabel.text = NSLocalizedString(@"No devices", @"");
    else
        _noItemsLabel.text = NSLocalizedString(@"No connection", @"");
    [self.view setNeedsLayout];
}

- (void)setRules:(TFHpple *)xml
{
    //if (xml == nil) return;
    
    _rulesXml = xml;
}

- (void)setDevices:(NSArray *)devices
{
    _objects = devices;
    
    [self refresh];
}

-(void)refresh
{
    if (!self.tableView.scrollEnabled) return;
    
    [self.tableView reloadData];
    
    if (_objects.count == 0)
    {
        _noItemsLabel.hidden = NO;
        _tableView.hidden = YES;
    }
    else
    {
        _noItemsLabel.hidden = YES;
        _tableView.hidden = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWDeviceInfo *device = [_objects objectAtIndex:indexPath.row];
    
    ZWDeviceItem *cell = [device createUIforTableView:tableView atPos:indexPath];
    
    TFHppleElement *deviceNode = [_rulesXml peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"/config/devices/device[@device = %@]", device.deviceId]];
    if (deviceNode != nil)
    {
        NSString *deviceName = [deviceNode.attributes objectForKey:@"description"];
        if (deviceName != nil && ![deviceName isEqualToString:@""])
        {
            if (![device.instanceId isEqualToString:@"0"])
                deviceName = [NSString stringWithFormat:@"%@ #%@", deviceName, device.instanceId];
            
            cell.nameView.text = deviceName;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWDeviceInfo *device = [_objects objectAtIndex:indexPath.row];
    
    if (device.data == nil) return;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) return;
    
    UIViewController *c = [[UIViewController alloc] init];
    c.view.backgroundColor = [UIColor whiteColor];
    [c.navigationItem setTitle:[NSString stringWithFormat:@"%@:%@:%@", device.deviceId, device.instanceId, device.ccId]];
    
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:device.data options:NSJSONWritingPrettyPrinted error:&err];
    
    UITextView *text = [[UITextView alloc] initWithFrame:c.view.bounds];
    text.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [c.view addSubview:text];
    
    [self.navigationController pushViewController:c animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWDeviceInfo *device = [_objects objectAtIndex:indexPath.row];

    return device.height;
}

@end
