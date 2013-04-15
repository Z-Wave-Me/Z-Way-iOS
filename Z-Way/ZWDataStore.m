//
//  ZWDataStore.m
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

#import "ZWDataStore.h"
#import "ZWAppDelegate.h"

@implementation ZWDataStore

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext != nil)
        return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel != nil)
        return _managedObjectModel;
    
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
        return _persistentStoreCoordinator;
    
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"cache.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError* error;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        // delete cache
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        
        // and retry
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (ZWDataStore*)store
{
    return ZWAppDelegate.sharedDelegate.dataStore;
}

- (NSUInteger)getProfilesCount
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Profile"];
    [request setIncludesPendingChanges:NO];
    
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return results.count;
}

- (CMProfile *)getProfile:(NSString *)name
{
    NSParameterAssert(name != nil && name.length > 0);
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Profile"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    [request setIncludesPendingChanges:YES];
    
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (results == nil || results.count == 0)
        return nil;
    
    return [results objectAtIndex:0];
}

@end
