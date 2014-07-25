//
//  common.m
//
//  Created by Douglas Hill on 15/02/2014.
//  Copyright (c) 2014 Douglas Hill. All rights reserved.
//

#import "common.h"

void ObLog(id<NSObject> object)
{
    NSLog(@"%@", object);
}

NSString *pathToDefaults(NSString *name)
{
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *sandboxPath = [NSString pathWithComponents:@[libraryPath, @"Containers", name, @"Data", @"Library", @"Preferences", [name stringByAppendingPathExtension:@"plist"]]];
    NSString *nonSandboxPath = [NSString pathWithComponents:@[libraryPath, @"Preferences", [name stringByAppendingPathExtension:@"plist"]]];
    
    for (NSString *path in @[sandboxPath, nonSandboxPath]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO]) {
            return path;
        }
    }
    
    return nil;
}

NSDictionary *readDefaults(NSString *name)
{
    return [NSDictionary dictionaryWithContentsOfFile:pathToDefaults(name)];
}

void copyDefaults(NSString *name, NSURL *destination)
{
    NSString *path = pathToDefaults(name);
    if (path == nil) {
        NSLog(@"No defaults found for %@", name);
        return;
    }
    
    NSError *error;
    BOOL copySuccess = [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:path] toURL:destination error:&error];
    if (copySuccess == NO) {
        ObLog(error);
    }
}

NSDictionary *diffDictionaries(NSDictionary *oldDictionary, NSDictionary *newDictionary)
{
    NSMutableDictionary *changedAndAdded = [NSMutableDictionary dictionary];
    NSMutableSet *oldKeys = [NSMutableSet setWithArray:[oldDictionary allKeys]];
    
    for (NSString *key in newDictionary) {
        [oldKeys removeObject:key];
        
        if ([oldDictionary[key] isEqual:newDictionary[key]]) continue;
        
        changedAndAdded[key] = newDictionary[key];
    }
    
    if ([oldKeys count]) {
        NSLog(@"Deleted keys: %@", oldKeys);
    }
    
    return changedAndAdded;
}

void applyPatchToDefaults(NSDictionary *patchPictionary, NSString *defaultsName)
{
	NSUserDefaults * const defaults = [[NSUserDefaults alloc] initWithSuiteName:defaultsName];
	
	[defaults setValuesForKeysWithDictionary:patchPictionary];
	
	if (![defaults synchronize]) {
		NSLog(@"Could not write defaults to disk.");
	}
}
