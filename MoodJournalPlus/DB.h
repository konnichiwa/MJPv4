
#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DB : NSObject {
	FMDatabase *db;
}

- (BOOL)initDatabase;
- (void)closeDatabase;
- (FMDatabase *)getDatabase;

@end
