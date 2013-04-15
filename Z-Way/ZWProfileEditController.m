//
//  ZWProfileEditViewController.m
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

#import "ZWProfileEditController.h"
#import "ZWDataStore.h"
#import "CMProfile.h"
#import "ZWAppDelegate.h"

@implementation ZWProfileEditController

- (id)initWithProfile:(CMProfile *)profile
{
    NSParameterAssert(profile != nil);
    
    self = [super initWithNibName:@"ZWProfileEditController_iPhone" bundle:nil];
    if (self)
    {
        _profile = profile;
        
        _fields = [NSMutableDictionary dictionary];
        [_fields setObject:[[[NSBundle mainBundle] loadNibNamed:@"ZWTextEditCell" owner:self options:nil] objectAtIndex:0] forKey:@"name"];
        [_fields setObject:[[[NSBundle mainBundle] loadNibNamed:@"ZWUrlEditCell" owner:self options:nil] objectAtIndex:0] forKey:@"indoorUrl"];
        [_fields setObject:[[[NSBundle mainBundle] loadNibNamed:@"ZWUrlEditCell" owner:self options:nil] objectAtIndex:0] forKey:@"outdoorUrl"];
        [_fields setObject:[[[NSBundle mainBundle] loadNibNamed:@"ZWTextEditCell" owner:self options:nil] objectAtIndex:0] forKey:@"userLogin"];
        [_fields setObject:[[[NSBundle mainBundle] loadNibNamed:@"ZWPasswordCell" owner:self options:nil] objectAtIndex:0] forKey:@"userPassword"];
        
        _fieldsOrder = [NSMutableArray arrayWithObjects:@"name", @"indoorUrl", @"outdoorUrl", @"userLogin", @"userPassword", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = _profile.name;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    _profile = nil;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
        NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
        NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
        CGRect keyboardBounds;
        [keyboardBoundsValue getValue:&keyboardBounds];
        UIEdgeInsets e = UIEdgeInsetsMake(0, 0, keyboardBounds.size.height, 0);
        [[self tableView] setScrollIndicatorInsets:e];
        [[self tableView] setContentInset:e];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    }
#endif
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets e = UIEdgeInsetsZero;
    [[self tableView] setScrollIndicatorInsets:e];
    [[self tableView] setContentInset:e];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (ZWAppDelegate.sharedDelegate.settingsLocked) return;
    
    for (NSString* key in _fields.allKeys)
    {
        UITableViewCell *cell = [_fields objectForKey:key];
        
        UITextField *editor = (UITextField*)[cell viewWithTag:2];
        
        [_profile setValue:editor.text forKey:key];
    }
    
    [ZWDataStore.store.managedObjectContext processPendingChanges];
    [ZWDataStore.store saveContext];
    
    if (_profile == ZWAppDelegate.sharedDelegate.profile)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZWProfileHasChanged" object:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return nil;
        case 1:
            return NSLocalizedString(@"Servers", @"");
        case 2:
            return NSLocalizedString(@"Credentials", @"");
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
        case 1:
        case 2:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = nil;
    NSString *displayName = nil;
    
    switch (indexPath.section)
    {
        case 0:
            name = @"name";
            displayName = NSLocalizedString(@"Name", @"");
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                    name = @"indoorUrl";
                    displayName = NSLocalizedString(@"Indoor", @"");
                    break;
                case 1:
                    name = @"outdoorUrl";
                    displayName = NSLocalizedString(@"Outdoor", @"");
                    break;
            }
            break;
        }

        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                    name = @"userLogin";
                    displayName = NSLocalizedString(@"Login", @"");
                    break;
                case 1:
                    name = @"userPassword";
                    displayName = NSLocalizedString(@"Password", @"");
                    break;
            }
            break;
        }
    }
    
    UITableViewCell* cell = [_fields objectForKey:name];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    UITextField *editor = (UITextField*)[cell viewWithTag:2];
    
    label.text = displayName;
    editor.text = [_profile valueForKey:name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = nil;
    
    switch (indexPath.section)
    {
        case 0:
            name = @"name";
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                    name = @"indoorUrl";
                    break;
                case 1:
                    name = @"outdoorUrl";
                    break;
            }
            break;
        }
            
        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                    name = @"userLogin";
                    break;
                case 1:
                    name = @"userPassword";
                    break;
            }
            break;
        }
    }
    
    UITableViewCell* cell = [_fields objectForKey:name];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    UITextField *editor = (UITextField*)[cell viewWithTag:2];
    [editor becomeFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return !ZWAppDelegate.sharedDelegate.settingsLocked;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIView *thisCell = textField;
    
    while (thisCell != nil)
    {
        thisCell = thisCell.superview;
        if ([thisCell isKindOfClass:[UITableViewCell class]]) break;
    }
    
    NSString *thisKey = nil;
    NSString *nextKey = nil;
    UITableViewCell *nextCell = nil;
    UIView *nextField = nil;
    
    for (NSString *key in _fields)
    {
        if ([_fields objectForKey:key] == thisCell)
        {
            thisKey = key;
            break;
        }
    }
    
    if (thisKey != nil)
    {
        NSInteger order = [_fieldsOrder indexOfObject:thisKey];
        if (order < _fieldsOrder.count - 1)
        {
            nextKey = [_fieldsOrder objectAtIndex:(order+1)];
        }
    }
    
    if (nextKey != nil)
    {
        nextCell = [_fields objectForKey:nextKey];
        nextField = [nextCell viewWithTag:2];
        
        NSIndexPath *path = [self.tableView indexPathForCell:nextCell];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        [nextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
