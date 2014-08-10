// Douglas Hill, August 2014

#import "NSURL+DHResourceValues.h"

@implementation NSURL (DHResourceValues)

- (NSDictionary *)dh_resourceValuesForKeys:(NSArray *)allKeys {
	
	NSMutableDictionary *resourceValues = [NSMutableDictionary dictionaryWithSharedKeySet:[NSDictionary sharedKeySetForKeys:allKeys]];
	
	for (NSString *key in allKeys) {
		id value;
		NSError *error;
		if (![self getResourceValue:&value forKey:key error:&error]) {
			NSLog(@"Error getting resource value %@ from %@: %@", key, self, error);
		}
		resourceValues[key] = value;
	}
	
	return resourceValues;
}

@end
