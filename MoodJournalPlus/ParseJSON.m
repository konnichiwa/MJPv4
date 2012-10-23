

#import "ParseJSON.h"
#import "SBJSON.h"
#import "AppDelegate.h"
#import "Record.h"
#import "RecordDao.h"
#import "AppDelegate.h"

@implementation ParseJSON

- (NSArray*)parseDataFromTextFile:(NSString*)txtFile {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@.txt",txtFile]];
    
    NSString *responseData = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    SBJSON *parser = [SBJSON new];
    NSArray *arrayData = (NSArray*)[parser objectWithString:responseData];
    [responseData release];
    
    [parser release];
    return arrayData;
}

- (NSMutableArray*)parseDataFromTable:(NSString*)tableName withStatus:(NSString*)status {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    RecordDao *recordDao = [[RecordDao alloc] init];
    recordDao.tableName = [[NSString alloc] initWithString:tableName];
    NSMutableArray *arrayDecripted = [[NSMutableArray alloc] init];
    NSArray *arrayEncripted = [recordDao resultSetWithStatus:status];

    SBJSON *parser = [SBJSON new];
    for (int i = 0; i < [arrayEncripted count]; i++) {
                     
        //NSDictionary *data = (NSDictionary*)[parser objectWithString:[appDelegate doCipher:[[arrayEncripted objectAtIndex:i] content] :kCCDecrypt]];
        NSDictionary *data = (NSDictionary*)[parser objectWithString:[[arrayEncripted objectAtIndex:i] content]];
        [arrayDecripted addObject:data];
    }
    [recordDao release];
    [parser release];
    return [arrayDecripted autorelease];
}

- (NSMutableArray*)parseDataFromTable:(NSString*)tableName withoutStatus:(NSString*)status {
    //AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    RecordDao *recordDao = [[RecordDao alloc] init];
    recordDao.tableName = [[NSString alloc] initWithString:tableName];
    NSMutableArray *arrayDecripted = [[NSMutableArray alloc] init];
    NSArray *arrayEncripted = [recordDao resultSetWithoutStatus:status];
    
    SBJSON *parser = [SBJSON new];
    for (int i = 0; i < [arrayEncripted count]; i++) {
        NSDictionary *data = (NSDictionary*)[parser objectWithString:[[arrayEncripted objectAtIndex:i] content]];
        [arrayDecripted addObject:data];
    }
    [recordDao release];
    return [arrayDecripted autorelease];
}
@end
