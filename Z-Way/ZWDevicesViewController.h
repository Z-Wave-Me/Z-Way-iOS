//
//  ZWDevicesViewController.h
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

#import <UIKit/UIKit.h>

@class TFHpple;

@interface ZWDevicesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_objects;
    UIImageView *_stateIconView;
    TFHpple *_rulesXml;
    UILabel *_noItemsLabel;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *noItemsLabel;
@property (strong, nonatomic) NSString *identifier;
@property (assign) BOOL lockUpdates;

- (void)refresh;
- (void)setDevices:(NSArray*)devices;
- (void)setRules:(TFHpple*)xml;
- (void)updateState:(UIImage*)stateIcon isConnected:(BOOL)connected;

@end
