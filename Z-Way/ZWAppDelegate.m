//
//  ZWAppDelegate.m
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

#import "ZWAppDelegate.h"
#import "ZWProfilesController.h"
#import "ZWRootViewController.h"
#import "ZWDataStore.h"
#import "CMProfile.h"

@implementation ZWAppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;
@synthesize profilesNavController = _profilesNavController;
@synthesize dataStore = _dataStore;
@synthesize profile = _profile;
@synthesize settingsLocked = _settingsLocked;

+ (ZWAppDelegate*)sharedDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.dataStore = [[ZWDataStore alloc] init];
    self.profile = nil;
    
    NSURL *plistPath = [[self.dataStore applicationDocumentsDirectory] URLByAppendingPathComponent:@"settings.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath.path])
    {
        NSArray* array = [[NSArray alloc] initWithContentsOfURL:plistPath];
        NSString* profileName = [[array objectAtIndex:0] valueForKey:@"profile"];
        if (profileName != nil && profileName.length > 0)
        {
            self.profile = [self.dataStore getProfile:profileName];
        }
        
        NSNumber* locked = [[array objectAtIndex:0] valueForKey:@"settingsLocked"];
        _settingsLocked = (locked != nil && [locked boolValue]);
    }
    
    self.rootViewController = [[ZWRootViewController alloc] initWithNibName:@"ZWRootViewController_iPhone" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];

    ZWProfilesController *profilesViewController = [[ZWProfilesController alloc] init];
    
    self.profilesNavController = [[UINavigationController alloc] initWithRootViewController:profilesViewController];

    navController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.profilesNavController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    if (self.profile == nil)
    {
        [self.rootViewController performSelector:@selector(showSettings:) withObject:nil afterDelay:0.1];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // try local address on activate
    if (self.profile != nil)
    {
        @synchronized(self.profile)
        {
            NSLog(@"Changed outdoor to indoor");
            self.profile.useOutdoor = [NSNumber numberWithBool:NO];
            [self.rootViewController resumeFromBackground];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
