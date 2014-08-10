//
//  patch.m
//
//  Created by Douglas Hill on 15/02/2014.
//  Copyright (c) 2014 Douglas Hill. All rights reserved.
//

#import "common.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc != 3) {
            NSLog(@"Need two arguments: defaults name and patch path");
            return 1;
        }
        
        NSString *name = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        NSString *path = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO] == NO) {
            NSLog(@"No file at %@", path);
            return 2;
        }
        
        applyPatchToDefaults(readDictionary([NSURL fileURLWithPath:path]), name);
        
    }
    return 0;
}
