// setup
// Douglas Hill, August 2014

@import Foundation;

#import "NSURL+DHRebase.h"
#import "NSURL+DHResourceValues.h"

static NSSet *linkSources(NSURL *source) {
	
	NSArray *const keys = @[NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLParentDirectoryURLKey];
	NSDirectoryEnumerator *const enumerator = [[NSFileManager defaultManager] enumeratorAtURL:source includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsPackageDescendants errorHandler:nil];
	NSMutableSet *sources = [NSMutableSet set];
	
	for (NSURL *url in enumerator) {
		NSDictionary *resourceValues = [url dh_resourceValuesForKeys:keys];
		
		if ([resourceValues[NSURLIsDirectoryKey] boolValue] && [resourceValues[NSURLIsPackageKey] boolValue] == NO) {
			[sources addObject:url];
			[sources removeObject:resourceValues[NSURLParentDirectoryURLKey]];
		}
	}
	
	return sources;
}

static void linkUp(NSURL *sourceRoot, NSURL *destinationRoot) {
	
	// Walk source, finding all the leaf directories
	NSSet *sources = linkSources(sourceRoot);
	
	// For each leaf directory, look for the equivalent in destination
	for (NSURL *sourceURL in sources) {
		NSURL *const destURL = [sourceURL dh_URLByRebasingFromBase:sourceRoot ontoBase:destinationRoot];
		
		// Stop if dest is a symlink to source
		if ([[[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:[destURL path] error:NULL] isEqualToString:[sourceURL path]]) {
			NSLog(@"Skipping %@", sourceURL);
			continue;
		}
		
		// If there is anything in dest, copy it to source
		NSError *contentsOfDirError;
		NSArray *const contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:destURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&contentsOfDirError];
		for (NSURL *url in contents) {
			NSError *copyError;
			if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:[url dh_URLByRebasingFromBase:destURL ontoBase:sourceURL] error:&copyError]) {
				NSLog(@"%@", [copyError localizedDescription]);
			}
		}
		
		// Move dest to Trash
		NSError *trashError;
		if (![[NSFileManager defaultManager] trashItemAtURL:destURL resultingItemURL:NULL error:&trashError]) {
//			NSLog(@"%@", trashError);
		}
		
		NSError *intermediateDirCreateError;
		if (![[NSFileManager defaultManager] createDirectoryAtURL:[destURL URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&intermediateDirCreateError]) {
			NSLog(@"%@", intermediateDirCreateError);
		}
		
		// Create symlink at dest pointing to source
		NSError *symlinkCreateError;
		// We are naming variables to match `ln`, which differs from the NSFileManager nomenclature.
		if (![[NSFileManager defaultManager] createSymbolicLinkAtURL:destURL withDestinationURL:sourceURL error:&symlinkCreateError]) {
			NSLog(@"%@", symlinkCreateError);
			continue;
		}
		
		NSLog(@"Linked %@ to %@", destURL, sourceURL);
	}
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		if (argc < 2) {
			NSLog(@"Too few arguments. Usage: %s source_directory [destination_directory]", argv[0]);
			return 1;
		}
		
		NSURL *const sourceDir = [NSURL fileURLWithPath:@(argv[1])];
		NSURL *const destinationDir = [NSURL fileURLWithPath:(argc < 3) ? NSHomeDirectory() : @(argv[2])];
		
		linkUp(sourceDir, destinationDir);
	}
	
	return 0;
}
