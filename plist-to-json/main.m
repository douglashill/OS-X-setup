// Douglas Hill, August 2014

@import Foundation;

typedef NS_ENUM(NSUInteger, ReturnCodes) {
	Success = 0,
    TooFewArguments,
    CouldNotRead,
	CouldNotCreateJSON,
    CouldNotWrite,
};

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
		NSData *const jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&jsonError];
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
