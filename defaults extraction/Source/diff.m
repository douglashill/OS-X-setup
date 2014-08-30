//
//  diff.m
//
//  Created by Douglas Hill on 15/02/2014.
//  Copyright (c) 2014 Douglas Hill. All rights reserved.
//

#import "common.h"

@implementation NSDictionary (DHFileReading)

+ (NSDictionary *)dh_dictionaryWithContentsOfFile:(NSString *)path
{
	NSDictionary *dictionaryFromPropertyList = [self dictionaryWithContentsOfFile:path];
	
	if (dictionaryFromPropertyList) return dictionaryFromPropertyList;
	
	return [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:NULL];
}

@end

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc != 4) {
            NSLog(@"Need three arguments: the two files to diff and where to write the result");
            return 1;
        }
        
        NSString *path1 = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        NSString *path2 = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        NSString *destination = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path1 isDirectory:NO] == NO) {
            NSLog(@"No file at %@", path1);
            return 2;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:path2 isDirectory:NO] == NO) {
            NSLog(@"No file at %@", path2);
            return 2;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:destination isDirectory:NO]) {
            NSLog(@"File already exists at %@", destination);
            NSLog(@"Aborting");
            return 3;
        }
        
        NSDictionary *diff = diffDictionaries([NSDictionary dh_dictionaryWithContentsOfFile:path1], [NSDictionary dh_dictionaryWithContentsOfFile:path2]);
        writeDictionary(diff, [NSURL fileURLWithPath:destination], 0);
    }
    return 0;
}
