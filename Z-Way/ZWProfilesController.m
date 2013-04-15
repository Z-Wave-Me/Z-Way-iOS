//
//  ZWProfilesViewController.m
//  Z-Way
//
//  Created by Alex Skalozub on 8/21/12.
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

#import "ZWProfilesController.h"
#import "ZWAppDelegate.h"
#import "ZWDataStore.h"
#import "CMProfile.h"
#import "ZWProfileEditController.h"

@implementation ZWProfilesController

@synthesize fetchController = _fetchController;

- (id)init
{
    self = [super initWithNibName:@"ZWProfilesController_iPhone" bundle:nil];
    if (self)
    {
        ZWDataStore *store = [ZWAppDelegate sharedDelegate].dataStore;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Profile"];
        [request setIncludesPendingChanges:YES];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:store.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProfile:)];
    addButton.enabled = !ZWAppDelegate.sharedDelegate.settingsLocked;
    self.navigationItem.leftBarButtonItem = addButton;
    
    self.navigationItem.title = NSLocalizedString(@"Profiles", @"");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadView];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)reloadView
{
    NSError *err = nil;
    if ([self.fetchController performFetch:&err])
    {
        [self.tableView reloadData];
        
        NSIndexPath *path = [self.fetchController indexPathForObject:ZWAppDelegate.sharedDelegate.profile];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }    
}

- (void)addProfile:(id)sender
{
    if (ZWAppDelegate.sharedDelegate.settingsLocked) return;
    
    ZWDataStore *store = ZWDataStore.store;
    
    NSEntityDescription *profileEntity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:store.managedObjectContext];
    
    CMProfile *profile = [[CMProfile alloc] initWithEntity:profileEntity insertIntoManagedObjectContext:store.managedObjectContext];
    
    profile.name = NSLocalizedString(@"New Profile", @"");
    
    ZWProfileEditController* edit = [[ZWProfileEditController alloc] initWithProfile:profile];
    [self.navigationController pushViewController:edit animated:YES];
    
    [store saveContext];
    [self reloadView];
}

- (void)done:(id)sender
{
    ZWDataStore *store = ZWDataStore.store;
    
    if (!ZWAppDelegate.sharedDelegate.settingsLocked)
    {
        [store saveContext];
    }
    
    if (store.getProfilesCount == 0)
    {
        // do not dismiss profiles screen if there's no profile
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profiles", @"") message:NSLocalizedString(@"You should create at least one profile", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    CMProfile *selectedProfile = ZWAppDelegate.sharedDelegate.profile;
    if (selectedProfile == nil || selectedProfile.isDeleted)
    {
        // do not dismiss profiles screen if no profile is selected
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profiles", @"") message:NSLocalizedString(@"You should select a profile", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    NSURL *plistPath = [[store applicationDocumentsDirectory] URLByAppendingPathComponent:@"settings.plist"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:selectedProfile.name forKey:@"profile"];
    [dict setValue:[NSNumber numberWithBool:ZWAppDelegate.sharedDelegate.settingsLocked] forKey:@"settingsLocked"];
    
    [[NSArray arrayWithObject:dict] writeToURL:plistPath atomically:YES];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fetchController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectInfo = [_fetchController.sections objectAtIndex:section];
    return sectInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMProfile *profile = [_fetchController objectAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = profile.name;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !ZWAppDelegate.sharedDelegate.settingsLocked;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CMProfile *selectedProfile = ZWAppDelegate.sharedDelegate.profile;
        CMProfile *profile = [_fetchController objectAtIndexPath:indexPath];
        
        ZWDataStore *store = ZWDataStore.store;
        
        [store.managedObjectContext deleteObject:profile];
        [store.managedObjectContext processPendingChanges];
        
        if (selectedProfile == profile)
        {
            // deleted selected profile
            ZWAppDelegate.sharedDelegate.profile = nil;
        }
        
        NSError *err = nil;
        if ([self.fetchController performFetch:&err])
        {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ZWDataStore *store = ZWDataStore.store;
    CMProfile *profile = [_fetchController objectAtIndexPath:indexPath];
    
    ZWProfileEditController* edit = [[ZWProfileEditController alloc] initWithProfile:profile];
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMProfile *profile = [_fetchController objectAtIndexPath:indexPath];
    
    CMProfile *oldProfile = ZWAppDelegate.sharedDelegate.profile;
    //if (oldProfile != profile)
    {
        ZWAppDelegate.sharedDelegate.profile = profile;
        profile.useOutdoor = [NSNumber numberWithBool:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZWProfileHasChanged" object:nil];
    }
    /*else
    {
        profile.useOutdoor = [NSNumber numberWithBool:NO];
    }*/
    
    [self done:nil];
}

@end
