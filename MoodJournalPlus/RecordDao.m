

#import "Record.h"
#import "RecordDao.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

//#define TABLE_NAME @"TbNote"

@implementation RecordDao
@synthesize tableName;

// SELECT
-(NSMutableArray *)resultSet
{
	NSMutableArray *result = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT * FROM %@" inTable:tableName]];
	while ([rs next]) {
		//Record *tr = [[Record alloc] initWithIndex:[rs intForColumn:@"id"]
		//									 Title:[rs stringForColumn:@"title"]
		//									  Body:[rs stringForColumn:@"body"]];
        
        Record *tr = [[Record alloc] initWithIndex:[rs intForColumn:@"id"] content:[rs stringForColumn:@"content"] status:[rs stringForColumn:@"status"] msgid:[rs stringForColumn:@"msgid"]];
		[result addObject:tr];
		[tr release];
	}
	
	[rs close];
	
	return result;
}
-(NSMutableArray*)resultSetWithStatus:(NSString*)status {
    NSMutableArray *result = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT * FROM %@ where status =?" inTable:tableName],status];
	while ([rs next]) {
		//Record *tr = [[Record alloc] initWithIndex:[rs intForColumn:@"id"]
		//									 Title:[rs stringForColumn:@"title"]
		//									  Body:[rs stringForColumn:@"body"]];
        
        Record *tr = [[Record alloc] initWithIndex:[rs intForColumn:@"id"] content:[rs stringForColumn:@"content"] status:[rs stringForColumn:@"status"] msgid:[rs stringForColumn:@"msgid"]];
		[result addObject:tr];
		[tr release];
	}
	
	[rs close];
	
	return result;
}

-(NSMutableArray*)resultSetWithoutStatus:(NSString*)status {
    NSMutableArray *result = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT * FROM %@ where status <> ?" inTable:tableName],status];
	while ([rs next]) {        
        Record *tr = [[Record alloc] initWithIndex:[rs intForColumn:@"id"] content:[rs stringForColumn:@"content"] status:[rs stringForColumn:@"status"] msgid:[rs stringForColumn:@"msgid"]];
		[result addObject:tr];
		[tr release];
	}
	
	[rs close];
	
	return result;
}

-(NSMutableArray*)resultSetWithoutNormalStatus {
    NSMutableArray *result = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT * FROM %@ where status <> ?" inTable:tableName],@"normal"];
	while ([rs next]) {
		//Record *tr = [[Record alloc] initWithIndex:[rs intForColumn:@"id"]
		//									 Title:[rs stringForColumn:@"title"]
		//									  Body:[rs stringForColumn:@"body"]];
        
        Record *tr = [[Record alloc] initWithIndex:[rs intForColumn:@"id"] content:[rs stringForColumn:@"content"] status:[rs stringForColumn:@"status"] msgid:[rs stringForColumn:@"msgid"]];
		[result addObject:tr];
		[tr release];
	}
	
	[rs close];
	
	return result;
}

-(NSInteger)getIndexOfARecordWithMsgid:(NSString*)msgid {
    NSInteger iD;
    NSLog(@"%@  %@",tableName, msgid);
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT id FROM %@ where msgid = ?" inTable:tableName],msgid];
	while ([rs next]) {
		//Record *tr = [[Record alloc] initWithIndex:[rs intForColumn:@"id"]
		//									 Title:[rs stringForColumn:@"title"]
		//									  Body:[rs stringForColumn:@"body"]];
        
        iD = [rs intForColumn:@"id"];
        NSLog(@"%d",iD);
	}
	
	[rs close];
	
	return iD;
}
//Search
-(BOOL)hadMsgIdInSnoozeTable:(NSString*)msgid{
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT * FROM %@ where msgid = ?" inTable:tableName],msgid];
	while ([rs next]) {
        [rs close];
        return YES;
	}
	[rs close];
	
	return NO;
}
-(NSString*)searchIdfromContactWithName:(NSString*)name
{
    NSString *result;
	FMResultSet *rs = [db executeQuery:[self SQL:@"SELECT id FROM %@ where name = ?" inTable:tableName],name ];
	while ([rs next]) {
        result=[rs stringForColumn:@"id"];
	}
	[rs close];
	
	return result;
}
// INSERT
-(void)insertWithContent:(NSString *)content WithStatus:(NSString*)status WithMsgid:(NSString*)msgid {
	[db executeUpdate:[self SQL:@"INSERT INTO %@ (content,status,msgid) VALUES (?,?,?)" inTable:tableName], content,status,msgid];
	if ([db hadError]) {
		//NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
}
-(void)insertContactWithName:(NSString *)name phone:(NSString*)phone andtype:(NSString*)type andId:(NSString*)idContact
{
[db executeUpdate:[self SQL:@"INSERT INTO %@ (name,phone,type,id) VALUES (?,?,?,?)" inTable:tableName],name,phone,type,idContact];
}
-(void)insertWithContent:(NSString *)content {
	[db executeUpdate:[self SQL:@"INSERT INTO %@ (content,status,msgid) VALUES (?)" inTable:tableName], content];
	if ([db hadError]) {
		//NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
}
-(void)insertSnoozeWithMsgId:(NSString *)msgid
{

    if(![self hadMsgIdInSnoozeTable:msgid])
    {  [db executeUpdate:[self SQL:@"INSERT INTO %@ (msgid) VALUES (?)" inTable:tableName], msgid];
        if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
}
// UPDATE
-(BOOL)updateAtIndex:(int)index Content:(NSString *)content {
	BOOL success = YES;
	[db executeUpdate:[self SQL:@"UPDATE %@ SET content=? WHERE id=?" inTable:tableName],
	                                    content, [NSNumber numberWithInt:index]];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	
	return success;
}

-(BOOL)updateAtIndex:(int)index Status:(NSString *)status {
	BOOL success = YES;
	[db executeUpdate:[self SQL:@"UPDATE %@ SET status=? WHERE id=?" inTable:tableName],
     status, [NSNumber numberWithInt:index]];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	
	return success;
}

-(BOOL)updateAtIndex:(int)index Content:(NSString *)content Status:(NSString*)status {
    BOOL success = YES;
	[db executeUpdate:[self SQL:@"UPDATE %@ SET content=?,status=? WHERE id=?" inTable:tableName],content,
     status, [NSNumber numberWithInt:index]];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	
	return success;
}

-(BOOL)updateStatus:(NSString*)status ForMsg:(NSString*)msgid {
    BOOL success = YES;
    NSLog(@"%@  %@",tableName, msgid);
    NSString *sqmt=[NSString stringWithFormat:@"UPDATE %@ SET status='%@' WHERE msgid='%@'",tableName,status,msgid];
	[db executeUpdate:sqmt];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	
	return success;
}
-(BOOL)updateSnoozeAtMgsid:(NSString*)mgs withValue:(NSInteger)value;
{
    BOOL success = YES;
	[db executeUpdate:[self SQL:@"UPDATE %@ SET snooze=? WHERE msgid=?" inTable:tableName],value, mgs];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	return success;
}
// DELETE
- (BOOL)deleteAtIndex:(int)index
{
	BOOL success = YES;
	[db executeUpdate:[self SQL:@"DELETE FROM %@ WHERE id = ?" inTable:tableName], [NSNumber numberWithInt:index]];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	return success;
}

-(BOOL)deleteNormalRecord {
    BOOL success = YES;
	[db executeUpdate:[self SQL:@"DELETE FROM %@ WHERE status = ?" inTable:tableName],@"normal"];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	return success;
}

-(BOOL)deleteAllData {
    BOOL success = YES;
	[db executeUpdate:[self SQL:@"DELETE FROM %@" inTable:tableName]];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	return success;
}

-(BOOL)deleteRecordWithMsgID:(NSString*)msgid {
    BOOL success = YES;
    NSLog(@"%@   %@",tableName,msgid);
        NSString *sqmt=[NSString stringWithFormat:@"DELETE FROM %@ WHERE msgid ='%@'",tableName,msgid];
    NSLog(@"%@",sqmt);
	[db executeUpdate:sqmt];
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		success = NO;
	}
	return success;
}
-(NSMutableArray *)getContactsFromType:(NSString*)type
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
	NSString *sql=[NSString stringWithFormat:@"SELECT * FROM %@ where type ='%@'",tableName,type];
	FMResultSet *rs = [db executeQuery:sql];
	while ([rs next]) {        
        NSMutableDictionary *tr=[[NSMutableDictionary alloc] init];
        [tr setObject:[rs stringForColumn:@"name"] forKey:@"name"];
        [tr setObject:[rs stringForColumn:@"phone"] forKey:@"phone"];
        [tr setObject:(id)[rs stringForColumn:@"id"] forKey:@"id"];
        [result addObject:tr];
        [tr release];
	}
	
	[rs close];
	
	return result;

}
- (void)dealloc
{
    [tableName release];
	[super dealloc];
}

@end