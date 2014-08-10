// Douglas Hill, August 2014

@import Foundation;

@interface NSURL (DHRebase)

- (NSURL *)dh_URLByRebasingFromBase:(NSURL *)oldBase ontoBase:(NSURL *)newBase;

@end
