

#import "DB.h"
#import "BaseDao.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@implementation BaseDao

@synthesize db;

- (id)init{
	if(self = [super init])
	{
		db = [[[DB alloc] getDatabase] retain];
	}
	
	return self;
}

-(NSString *)SQL:(NSString *)sql inTable:(NSString *)table {
	return [NSString stringWithFormat:sql, table];
}

- (void)dealloc {
	[db release];
	[super dealloc];
}

@end