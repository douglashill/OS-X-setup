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
    NSURL *defaultsURL = [NSURL fileURLWithPath:pathToDefaults(defaultsName)];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfURL:defaultsURL];
    [dictionary setValuesForKeysWithDictionary:patchPictionary];
    [dictionary writeToURL:defaultsURL atomically:YES];
}

NSDictionary *readDictionary(NSURL *source)
{
    return [NSDictionary dictionaryWithContentsOfURL:source];
}

void writeDictionary(NSDictionary *dictionary, NSURL *destination, DictionaryOutputFormat outputFormat)
{
    // output format not implemented
    
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    if (data == nil) {
        ObLog(error);
        return;
    }
    
    [data writeToURL:destination atomically:YES];
}
