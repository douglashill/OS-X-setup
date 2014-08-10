//
//  common.h
//
//  Created by Douglas Hill on 15/02/2014.
//  Copyright (c) 2014 Douglas Hill. All rights reserved.
//

@import Foundation;

typedef enum : int {
    DictionaryOutputFormatXMLPropertyList,
    DictionaryOutputFormatBinaryPropertyList,
    DictionaryOutputFormatJSON,
} DictionaryOutputFormat;

void ObLog(id<NSObject> object);

NSString *pathToDefaults(NSString *name);

NSDictionary *readDefaults(NSString *name);

void copyDefaults(NSString *name, NSURL *destination);

NSDictionary *diffDictionaries(NSDictionary *oldDictionary, NSDictionary *newDictionary);

void applyPatchToDefaults(NSDictionary *patchPictionary, NSString *defaultsName);

NSDictionary *readDictionary(NSURL *source);

void writeDictionary(NSDictionary *dictionary, NSURL *destination, DictionaryOutputFormat outputFormat);
