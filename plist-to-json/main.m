// Douglas Hill, August 2014

@import Foundation;

typedef NS_ENUM(NSUInteger, ReturnCodes) {
	Success = 0,
    TooFewArguments,
    CouldNotRead,
	CouldNotCreateJSON,
    CouldNotWrite,
};

@implementation NSArray (Map)

- (NSArray *)arrayByMappingObjectsUsingMap:(id (^)(id obj))map
{
	NSMutableArray *mappedArray = [NSMutableArray arrayWithCapacity:[self count]];
	
	for (id object in self) {
		[mappedArray addObject:map(object)];
	}
	
	return mappedArray;
}

@end

@implementation NSString (JSONise)

- (NSString *)jsonValidObject
{
	return self;
}

@end

@implementation NSNumber (JSONise)

- (NSNumber *)jsonValidObject
{
	// ought to check for NaN or infinity
	return self;
}

@end

@implementation NSNull (JSONise)

- (NSNull *)jsonValidObject
{
	return self;
}

@end

@implementation NSArray (JSONise)

- (NSArray *)jsonValidObject
{
	return [[self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [obj respondsToSelector:@selector(jsonValidObject)];
	}]] arrayByMappingObjectsUsingMap:^id(id obj) {
		return [obj jsonValidObject];
	}];
}

@end

@implementation NSDictionary (JSONise)

- (NSDictionary *)jsonValidObject
{
	NSMutableDictionary *jsonValidDict = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	
	NSSet *const keysForValidEntries = [self keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
		return [key respondsToSelector:@selector(description)] && [obj respondsToSelector:@selector(jsonValidObject)];
	}];
	
	for (id key in keysForValidEntries) {
		jsonValidDict[[key description]] = [self[key] jsonValidObject];
	}
	
	return jsonValidDict;
}

@end

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		if (argc < 3) {
			NSLog(@"Too few arguments.");
			return TooFewArguments;
		}
		
		NSString *const sourcePropertyListPath = @(argv[1]);
		NSString *const destinationJSONPath = @(argv[2]);
		
		NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile:sourcePropertyListPath];
		if (dict == nil) {
			NSLog(@"Could not read dictionary from %@", sourcePropertyListPath);
			return CouldNotRead;
		}
		
		NSError *jsonError;
		NSData *const jsonData = [NSJSONSerialization dataWithJSONObject:[dict jsonValidObject] options:NSJSONWritingPrettyPrinted error:&jsonError];
		if (jsonData == nil) {
			NSLog(@"%@", jsonError);
			return CouldNotCreateJSON;
		}
		
		if (![jsonData writeToFile:destinationJSONPath atomically:YES]) {
			NSLog(@"Could not write JSON to %@", destinationJSONPath);
			return CouldNotWrite;
		}
	}
	
	return Success;
}
