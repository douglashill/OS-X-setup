// Douglas Hill, August 2014

#import "NSURL+DHRebase.h"

@implementation NSURL (DHRebase)

- (NSURL *)dh_URLByRebasingFromBase:(NSURL *)oldBase ontoBase:(NSURL *)newBase
{
	NSMutableArray *newComponents = [NSMutableArray arrayWithArray:[self pathComponents]];
	
	[newComponents replaceObjectsInRange:NSMakeRange(0, [[oldBase pathComponents] count]) withObjectsFromArray:[newBase pathComponents]];
	
	return [NSURL fileURLWithPathComponents:newComponents];
}

@end
