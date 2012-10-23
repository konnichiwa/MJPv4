

#import "DB.h"

#define DB_NAME @"MJP.db"


@implementation DB


- (BOOL)initDatabase
{
	BOOL success;
	NSError *error;
	NSFileManager *fm = [NSFileManager defaultManager];
    NSString *writableDBPath = [NSString stringWithFormat:@"%@/%@",DOCUMENT_FOLDER,DB_NAME];
	
	success = [fm fileExistsAtPath:writableDBPath];
	
	if(!success){
		NSString *defaultDBPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:DB_NAME];
		NSLog(@"%@",defaultDBPath);
		success = [fm copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if(!success){
			NSLog(@"error: %@", [error localizedDescription]);
		}
		success = YES;
	}
	
	if(success){
		db = [[FMDatabase databaseWithPath:writableDBPath] retain];
		if ([db open]) {
			[db setShouldCacheStatements:YES];
		}else{
			NSLog(@"Failed to open database.");
			success = NO;
		}
	}
	
	return success;
}


- (void)closeDatabase
{
	[db close];
}


- (FMDatabase *)getDatabase
{
	if ([self initDatabase]){
		return db;
	}
	
	return NULL;
}


- (void)dealloc
{
	[self closeDatabase];
	
	[db release];
	[super dealloc];
}

@end
