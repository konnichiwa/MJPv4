

#import "SetupAReminderAction.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@interface SetupAReminderAction ()
- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;
@end

@implementation SetupAReminderAction

-(id)init {
    if(self = [super init]){
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		arrayRestConnection = [[NSMutableArray alloc] init];
        recordDao = [[RecordDao alloc] init];
        recordDao.tableName = [[NSString alloc] initWithString:SETUP_REMINDER_TABLE];
	}
    return self;
}

-(void)dealloc {
    [super dealloc];
    [recordDao release];
    [arrayRestConnection release];
}

-(void)syncToServer {
    NSMutableArray *array = [recordDao resultSetWithoutNormalStatus];
    for (int i = 0; i < [array count]; i++) {
        Record *record = (Record*)[array objectAtIndex:i];
        index = [recordDao getIndexOfARecordWithMsgid:[record msgid]];
        
        SBJSON *parser = [SBJSON new];
        //NSDictionary *data = (NSDictionary*)[parser objectWithString:[appDelegate doCipher:[record content] :kCCDecrypt]];
        NSDictionary *data = (NSDictionary*)[parser objectWithString:[record content]];
        [parser release];
        if ([[record status] isEqualToString:@"Delete"]) {
            [self deleteReminder:data];
        }
        if ([[record status] isEqualToString:@"Inactive"]) {
            [self inactiveReminder:data];
        }
        if ([[record status] isEqualToString:@"Active"]) {
            [self activeReminder:data];
        }
        if ([[record status] isEqualToString:@"Update"]) {
            [self updateReminder:data];
        }
    }
}

-(void)activeReminder:(NSDictionary*)dict {
    SBJSON *json = [SBJSON new];
    NSString *postData;
    NSDictionary *aReminder = dict;
    postData = [json stringWithObject:aReminder];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    RestConnection *restConnection = [[RestConnection alloc] init];
    [arrayRestConnection addObject:restConnection];
    restConnection.isBackgroudService = YES;
    [restConnection putDataWithPathSource:@"/rest/Reminders" andParam:arr withPostData:postData];
    [restConnection.request setDelegate:self];
    restConnection.request.tag = index;
    [json release];
    [arr release];
}

-(void)inactiveReminder:(NSDictionary*)dict {
    SBJSON *json = [SBJSON new];
    NSString *postData;
    NSDictionary *aReminder = dict;
    postData = [json stringWithObject:aReminder];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    RestConnection *restConnection = [[RestConnection alloc] init];
    [arrayRestConnection addObject:restConnection];
    restConnection.isBackgroudService = YES;
    [restConnection putDataWithPathSource:@"/rest/Reminders" andParam:arr withPostData:postData];
    [restConnection.request setDelegate:self];
    restConnection.request.tag = index;
    [json release];
    [arr release];
}
-(void)deleteReminder:(NSDictionary*)dict {
    NSDictionary *dictAReminder = dict;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    RestConnection *restConnection = [[RestConnection alloc] init];
    [arrayRestConnection addObject:restConnection];
    [restConnection deleteDataWithPathSource:[NSString stringWithFormat:@"/rest/Reminders/%@",[dictAReminder objectForKey:@"msgschedulerid"]] andParam:arr withReminderID:[dictAReminder objectForKey:@"msgschedulerid"]];
    [restConnection.request setDelegate:self];
    restConnection.request.tag = index;
    [arr release];
}
-(void)updateReminder:(NSDictionary*)dict {
    
}

#pragma mark - 
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    NSLog(@"%@",[theRequest responseString]);
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    NSLog(@"%@",[theRequest responseString]);
    [recordDao deleteAtIndex:theRequest.tag];
}
@end
