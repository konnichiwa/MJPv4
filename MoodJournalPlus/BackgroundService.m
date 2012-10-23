

#import "BackgroundService.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "ParseJSON.h"


@interface BackgroundService ()
- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;
@end


@implementation BackgroundService
@synthesize isLoadingYourReminder, isLoadingSetupReminder, isLoadingUpcomingReminder;

-(id)init {
    if(self = [super init]){
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		arrayRestConnection = [[NSMutableArray alloc] init];
        recordDao = [[RecordDao alloc] init];
        recordDao.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
	}
    return self;
}

-(void)dealloc {
    [super dealloc];
    [recordDao release];
    [arrayRestConnection release];
    [arrayUpcomingReminder release];
}

-(void)login {
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appname forKey:@"appname"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceID"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:deviceType forKey:@"deviceType"]];
    
    if ([[appDelegate.dictSetting objectForKey:@"userID"] isEqualToString:@""]) {
        return;
    }
    [arr addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate.dictSetting objectForKey:@"password"] forKey:@"password"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate.dictSetting objectForKey:@"userID"] forKey:@"username"]];
    RestConnection *restConnection = [[RestConnection alloc] init];
    restConnection.isBackgroudService = YES;
    [restConnection postDataWithPathSource2:@"/rest/Auth" andParam:arr2 withPostData:arr];
    [restConnection.request setDelegate:self];
    restConnection.request.tag = 0;
    [arr release];
    [arr2 release];
}

-(void)syncToServer {
    if (arrayIndex != nil) {
        [arrayIndex release];
    }
    arrayIndex = [[NSMutableArray alloc] init];
    NSMutableArray *array = [recordDao resultSetWithoutNormalStatus];
    NSLog(@"%@",array);
    count = 0;
    totalCount = [array count];
    NSString *dataToSyn;
    NSMutableArray *arrayToSyn = [[NSMutableArray alloc] init];
    for (int i = 0; i < [array count]; i++) {
        Record *record = (Record*)[array objectAtIndex:i];
        NSLog(@"%@",[record msgid]);
        index = [recordDao getIndexOfARecordWithMsgid:[record msgid]];
        NSLog(@"%d",index);
        [arrayIndex addObject:[NSString stringWithFormat:@"%d",index]];
        
        SBJSON *parser = [SBJSON new];
        
        //NSDictionary *data = (NSDictionary*)[parser objectWithString:[appDelegate doCipher:[record content] :kCCDecrypt]];
        NSDictionary *data = (NSDictionary*)[parser objectWithString:[record content]];
        
        [parser release];
        
        NSDictionary *dataStr;
        if ([[record status] isEqualToString:@"skip"]) {
            dataStr = [self skipReminder:data];
        }
        if ([[record status] isEqualToString:@"dissmis"]) {
            dataStr = [self dissmissReminder:data];
        }
        if ([[record status] isEqualToString:@"just taken"]) {
            dataStr = [self justTakenReminder:data];
        }
        if ([[record status] isEqualToString:@"took as shown"]) {
            dataStr = [self tookAsShownReminder:data];
        }
        if ([[record status] isEqualToString:@"I didn't need it right now"] || [[record status] isEqualToString:@"I didn't have any"] || [[record status] isEqualToString:@"Other"]) {
            dataStr = [self skipReminder:data WithReason:[record status]];
        }
        
        [arrayToSyn addObject:dataStr];
    }
    
    if ([array count] == 0) {
        [self getYourReminder];
        [self getSetUpReminder];
    } 
    else {
        SBJSON *json = [SBJSON new];
        
        dataToSyn = [json stringWithObject:arrayToSyn];
        [json release];
        [arrayToSyn release];
        
        NSLog(@"%@",dataToSyn);
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        
        if (appDelegate.deviceToken != nil) {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        }
        else {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
        }
        
        RestConnection *restConnection = [[RestConnection alloc] init];
        [arrayRestConnection addObject:restConnection];
        
        restConnection.isBackgroudService = YES;
        NSString *path = [NSString stringWithFormat:@"/rest/msgb/sync"];
        [restConnection putDataWithPathSource:path andParam:arr withPostData:dataToSyn];
        [restConnection.request setDelegate:self];
        restConnection.request.tag = 1;
        
        [arr release];
    }
}

-(NSDictionary*)skipReminder:(NSDictionary*)dict {
    NSDictionary *dictReminderDetail = dict;
    [dictReminderDetail setValue:@"SKIPPED" forKey:@"systemstatus"];
    return dictReminderDetail;
    
    /*NSMutableArray *arr = [[NSMutableArray alloc] init];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
     RestConnection *restConnection = [[RestConnection alloc] init];
     [arrayRestConnection addObject:restConnection];
     
     restConnection.isBackgroudService = YES;
     NSString *path = [NSString stringWithFormat:@"/rest/msgb/msgboxid/%@",[dictReminderDetail objectForKey:@"msgboxid"]];
     [restConnection putDataWithPathSource:path andParam:arr withPostData:[json stringWithObject:dictReminderDetail]];
     [restConnection.request setDelegate:self];
     restConnection.request.tag = index;
     [json release];
     [arr release];*/
}
-(NSDictionary*)dissmissReminder:(NSDictionary*)dict {
    NSDictionary *dictReminderDetail = dict;
    
    [dictReminderDetail setValue:@"COMPLETE" forKey:@"systemstatus"];
    return dictReminderDetail;
    
    /*NSMutableArray *arr = [[NSMutableArray alloc] init];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
     RestConnection *restConnection = [[RestConnection alloc] init];
     [arrayRestConnection addObject:restConnection];
     restConnection.isBackgroudService = YES;
     NSString *path = [NSString stringWithFormat:@"/rest/msgb/msgboxid/%@",[dictReminderDetail objectForKey:@"msgboxid"]];
     
     [restConnection putDataWithPathSource:path andParam:arr withPostData:[json stringWithObject:dictReminderDetail]];
     restConnection.request.tag = index;
     [restConnection.request setDelegate:self];
     [json release];
     [arr release];*/
}
-(NSDictionary*)tookAsShownReminder:(NSDictionary*)dict {
    NSDictionary *dictReminderDetail = dict;
    NSArray *properties = [dictReminderDetail objectForKey:@"properties"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    [dictReminderDetail setValue:@"COMPLETE" forKey:@"systemstatus"];
    double deli =(double) [[dictReminderDetail objectForKey:@"deliverydate"] doubleValue] / (double)1000;
    NSString *date1 = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:deli]];
    
    for (int i = 0; i < [properties count]; i++) {
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyName"] isEqualToString:@"Time Taken"]) {
            [[properties objectAtIndex:i] setValue:date1 forKey:@"propertyValue"];
        }
    }
    [dictReminderDetail setValue:properties forKey:@"properties"];
    
    return dictReminderDetail;
    
    /*
     NSMutableArray *arr = [[NSMutableArray alloc] init];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
     RestConnection *restConnection = [[RestConnection alloc] init];
     
     [arrayRestConnection addObject:restConnection];
     
     restConnection.isBackgroudService = YES;
     NSString *path = [NSString stringWithFormat:@"/rest/msgb/msgboxid/%@",[dictReminderDetail objectForKey:@"msgboxid"]];
     [restConnection putDataWithPathSource:path andParam:arr withPostData:[json stringWithObject:dictReminderDetail]];
     restConnection.request.tag = index;
     [restConnection.request setDelegate:self];
     [json release];
     [arr release];
     [formatter release];*/
}
-(NSDictionary*)justTakenReminder:(NSDictionary*)dict {
    NSDictionary *dictReminderDetail = dict;
    NSArray *properties = [dictReminderDetail objectForKey:@"properties"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    [dictReminderDetail setValue:@"COMPLETE" forKey:@"systemstatus"];
    for (int i = 0; i < [properties count]; i++) {
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyName"] isEqualToString:@"Time Taken"]) {
            [[properties objectAtIndex:i] setValue:date forKey:@"propertyValue"];
        }
    }
    [dictReminderDetail setValue:properties forKey:@"properties"];
    return dictReminderDetail;
    
    /*
     NSMutableArray *arr = [[NSMutableArray alloc] init];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
     RestConnection *restConnection = [[RestConnection alloc] init];
     
     [arrayRestConnection addObject:restConnection];
     
     restConnection.isBackgroudService = YES;
     NSString *path = [NSString stringWithFormat:@"/rest/msgb/msgboxid/%@",[dictReminderDetail objectForKey:@"msgboxid"]];
     [restConnection putDataWithPathSource:path andParam:arr withPostData:[json stringWithObject:dictReminderDetail]];
     restConnection.request.tag = index;
     [restConnection.request setDelegate:self];
     [arr release];
     [json release];
     [formatter release];*/
}
-(void)expireReminder:(NSMutableDictionary*)dict {
    NSMutableDictionary *dictReminderDetail = dict;
    NSArray *properties = [dictReminderDetail objectForKey:@"properties"];
    [dictReminderDetail setValue:@"No Response" forKey:@"systemstatus"];
    [dictReminderDetail setValue:properties forKey:@"properties"];

     NSMutableArray *arr = [[NSMutableArray alloc] init];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
     RestConnection *restConnection = [[RestConnection alloc] init];
     
     [arrayRestConnection addObject:restConnection];
      SBJSON *json = [SBJSON new];
    NSLog(@"%@",[json stringWithObject:dictReminderDetail]);
     restConnection.isBackgroudService = YES;
     NSString *path = [NSString stringWithFormat:@"/rest/msgb/msgboxid/%@",[dictReminderDetail objectForKey:@"msgboxid"]];
     [restConnection putDataWithPathSource:path andParam:arr withPostData:[json stringWithObject:dictReminderDetail]];
     restConnection.request.tag = 9000000;
     [restConnection.request setDelegate:self];
     [arr release];
     [json release];
}
-(NSDictionary*)skipReminder:(NSDictionary*)dict WithReason:(NSString*)reason {
    NSDictionary *dictReminderDetail = dict;
    
    [dictReminderDetail setValue:@"SKIPPED" forKey:@"systemstatus"];
    NSArray *properties = [dictReminderDetail objectForKey:@"properties"];
    for (int i = 0; i < [properties count]; i++) {
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyName"] isEqualToString:@"Skipped Reason"]) {
            [[properties objectAtIndex:i] setValue:reason forKey:@"propertyValue"];
        }
    }
    [dictReminderDetail setValue:properties forKey:@"properties"];
    
    return dictReminderDetail;
    
    /*
     NSMutableArray *arr = [[NSMutableArray alloc] init];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
     RestConnection *restConnection = [[RestConnection alloc] init];
     [arrayRestConnection addObject:restConnection];
     restConnection.isBackgroudService = YES;
     NSString *path = [NSString stringWithFormat:@"/rest/msgb/msgboxid/%@",[dictReminderDetail objectForKey:@"msgboxid"]];
     [restConnection putDataWithPathSource:path andParam:arr withPostData:[json stringWithObject:dictReminderDetail]];
     [restConnection.request setDelegate:self];
     restConnection.request.tag = index;
     [arr release];
     [json release];*/
}

-(void)getYourReminder {
    if (!isLoadingYourReminder) {
        isLoadingYourReminder = NO;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        if (appDelegate.deviceToken != nil) {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        }
        else {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
        }
        
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"25" forKey:@"limit"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"desc" forKey:@"sortorder"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"deliverydate" forKey:@"sortfield"]];
        
        RestConnection *restConnection = [[RestConnection alloc] init];
        
        [restConnection getDataWithPathSource:@"/rest/msgb/due" andParam:arr forService:@"getYourRemiders"];
        [restConnection.request setDelegate:self];
        restConnection.request.tag = 3000000;
        [arrayRestConnection addObject:restConnection];
        [arr release];
    }
}

-(void)getSetUpReminder {
    if (!isLoadingSetupReminder) {
        isLoadingSetupReminder = NO;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        if (appDelegate.deviceToken != nil) {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        }
        else {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
        }
        
        RestConnection *restConnection = [[RestConnection alloc] init];
        [restConnection getDataWithPathSource:@"/rest/Reminders" andParam:arr forService:@"setUpReminders"];
        [restConnection.request setDelegate:self];
        restConnection.request.tag = 1000000;
        [arrayRestConnection addObject:restConnection];
        [arr release];
    }
}

-(void)getUpcomingReminder {
    if (!isLoadingUpcomingReminder) {
        isLoadingUpcomingReminder = NO;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        
        if (appDelegate.deviceToken != nil) {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        }
        else {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
        }
        
        RestConnection *restConnection = [[RestConnection alloc] init];
        [restConnection getDataWithPathSource:@"/rest/msgb/query" andParam:arr forService:@"upcomingReminder"];
        [restConnection.request setDelegate:self];
        restConnection.request.tag = 2000000;
        [arrayRestConnection addObject:restConnection];
        [arr release];
    }
}

-(void)getMotivationalMessage {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    if (appDelegate.deviceToken != nil) {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    }
    else {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    
    RestConnection *restConnection = [[RestConnection alloc] init];
    [restConnection getDataWithPathSource:@"/rest/Motivational" andParam:arr forService:@"getMotivationalMessage"];
    [restConnection.request setDelegate:self];
    restConnection.request.tag = 5000000;
    [arrayRestConnection addObject:restConnection];
    [arr release];
}

-(void)getMedicationList {
    double date = [[appDelegate.dictSetting objectForKey:@"date"] doubleValue];
    if ([[NSDate date] timeIntervalSince1970] > date + (double)30.0*24.0*3600.0 || [appDelegate.appMedicationList count] == 0) { //30 days download
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        if (appDelegate.deviceToken != nil) {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        }
        else {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
        }
        
        RestConnection *restConnection = [[RestConnection alloc] init];
        [restConnection getDataWithPathSource:@"/rest/Medication/drugs_list" andParam:arr forService:@"setUpReminders"];
        [restConnection.request setDelegate:self];
        restConnection.request.tag = 6000000;
        [arrayRestConnection addObject:restConnection];
        [arr release];
    }
    else {        
    }
}
-(void)registerPushNotification {
    if (appDelegate.pushNotificationToken != nil) {
        NSLog(@"Sent request push notification");
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:APPPUSH forKey:@"apppush"]];
        if (appDelegate.deviceToken != nil) {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        }
        else {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
        }
        
        RestConnection *restConnection = [[RestConnection alloc] init];
        NSMutableArray *arr2 = [[NSMutableArray alloc] init];
        [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.pushNotificationToken forKey:@"notification_token"]];
        [arr2 addObject:[NSMutableDictionary dictionaryWithObject:@"ACTIVE" forKey:@"status"]];
        NSLog(@"Send connection %@ Notification %@",arr, arr2);
        [restConnection postDataWithPathSource2:@"/rest/Notification" andParam:arr withPostData:arr2];
        [restConnection.request setDelegate:self];
        [arrayRestConnection addObject:restConnection];
        [arr release];
        [arr2 release];
        index = 3;
        
    }
}

-(void)unregisterPushNotification {
    if (appDelegate.pushNotificationToken != nil) {
        NSLog(@"Sent request push notification");
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:APPPUSH forKey:@"apppush"]];
        if (appDelegate.deviceToken != nil) {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        }
        else {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
        }
        
        RestConnection *restConnection = [[RestConnection alloc] init];
        NSMutableArray *arr2 = [[NSMutableArray alloc] init];
        [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.pushNotificationToken forKey:@"notification_token"]];
        [arr2 addObject:[NSMutableDictionary dictionaryWithObject:@"INACTIVE" forKey:@"status"]];
        NSLog(@"Send connection %@ Notification %@",arr, arr2);
        [restConnection postDataWithPathSource2:@"/rest/Notification" andParam:arr withPostData:arr2];
        [restConnection.request setDelegate:self];
        [arrayRestConnection addObject:restConnection];
        [arr release];
        [arr2 release];
        index = 3;
        
    }
}

- (void)verifyAccount {
    NSString *password = [appDelegate.dictSetting objectForKey:@"password"];
    
    appDelegate.deviceToken = [[NSString alloc] initWithFormat:@"%@",[appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"token"] :kCCDecrypt]];
    
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appname forKey:@"appname"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:password forKey:@"password"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:@"25" forKey:@"limit"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:@"1.0" forKey:@"version"]];
    
    
    RestConnection *restConnection = [[RestConnection alloc] init];
    [restConnection postDataWithPathSource2:@"/rest/User/verify" andParam:arr2 withPostData:arr];
    [restConnection.request setDelegate:self];
    restConnection.request.tag = 7000000;
    [arrayRestConnection addObject:restConnection];
    [arr release];
    [arr2 release];
    index = 4;
}



-(void)sortMedicationList {
    NSMutableArray *array = appDelegate.appMedicationList;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (int i = 0; i < [array count]; i++) {
        //NSString *firstChar = [[[[array objectAtIndex:i] objectForKey:@"drug_name"] substringToIndex:1] uppercaseString];
        NSString *firstChar = [[[array objectAtIndex:i]  substringToIndex:1] uppercaseString];
        BOOL esxited = NO;
        for (int j = 0; j < [keys count]; j++) {
            if ([[keys objectAtIndex:j] isEqualToString:firstChar]) {
                esxited = YES;
                break;
            }
        }
        if (!esxited) {
            [keys addObject:firstChar];
        }
    }
    
    //sort keys by anphabet
    NSArray *sortedArray = [keys sortedArrayUsingComparator: ^(id obj1, id obj2) {
        NSString *char1 = (NSString*)obj1;
        NSString *char2 = (NSString*)obj2;
        NSComparisonResult comparison = [char1 localizedCaseInsensitiveCompare:char2];
        return comparison;
    }];
    [keys release];
    keys = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    
    for (int i = 0; i < [keys count]; i++) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int j = 0; j < [array count]; j++) {
            //if ([[[[[array objectAtIndex:j] objectForKey:@"drug_name"] substringToIndex:1] uppercaseString] isEqualToString:[keys objectAtIndex:i]]) 
            if ([[[[array objectAtIndex:j]  substringToIndex:1] uppercaseString] isEqualToString:[keys objectAtIndex:i]]) {
                [arr addObject:[array objectAtIndex:j]];
            }
        }
        [dict setObject:arr forKey:[keys objectAtIndex:i]];
        [arr release];
    }
    appDelegate.arrayKeys = [[NSMutableArray alloc] initWithArray:keys];
    appDelegate.dictionaryMedicationList = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSNotification *notification = [NSNotification notificationWithName:@"reloadMedicationList" object:nil];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}
- (void)addNotificationWithFireDate:(NSDate*)fireDate alertBody:(NSString *)alertBody withID:(NSString*)msgid {
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
	localNotification.fireDate = [fireDate dateByAddingTimeInterval:10];
	localNotification.alertBody = alertBody;
	localNotification.soundName = UILocalNotificationDefaultSoundName;
	
	NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[appDelegate.arrayLocalNotification count]], @"Key 1", msgid, @"Key 2", nil];
    localNotification.userInfo = infoDict;
	
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [appDelegate.arrayLocalNotification addObject:localNotification];
	//[localNotification release];
}

-(void)scheduleUpcomingReminder {
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];    
    for (int i = 0; i < [array count]; i++) {
        UILocalNotification *notification = [array objectAtIndex:i];
        NSLog(@"%@",notification.userInfo);
        NSLog(@"%d",[array count]);
        if (![[notification.userInfo objectForKey:@"Key 2"] isEqualToString:@"snooze"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    NSArray *array3 =  [[UIApplication sharedApplication] scheduledLocalNotifications];  
        NSLog(@"%d",[array3 count]);
    [appDelegate.arrayLocalNotification removeAllObjects];
    [appDelegate.arrayMsgidNofify removeAllObjects];
    ParseJSON *parseJson = [[ParseJSON alloc] init];
    NSMutableArray *arrayReminders = [parseJson parseDataFromTable:UPCOMING_REMINDER_TABLE withStatus:@"normal"];
    for (int i = 0; i < [arrayReminders count]; i++) {
        NSString *deliveryDate = [[arrayReminders objectAtIndex:i] objectForKey:@"deliverydate"];
        if ([[self convertDate:deliveryDate] compare:[NSDate date]] == NSOrderedDescending) {
            NSString *msgid = [NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"deliverydate"]];
            NSLog(@"%@",[self convertDate:deliveryDate]);
            [appDelegate.arrayMsgidNofify addObject:msgid];
            [self addNotificationWithFireDate:[self convertDate:deliveryDate] alertBody:@"You have a Reminder." withID:msgid];
        }
    }
    NSArray *array1 =  [[UIApplication sharedApplication] scheduledLocalNotifications];  
    NSLog(@"%d",[array1 count]);

    [parseJson release];
}

- (NSDate*)convertDate:(NSString*)floatString {
    double deliveryDate = [floatString doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];   
    
    NSString *dateString = [[NSString alloc] initWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)((double)deliveryDate/(double)1000.0)]]];
    NSDate *date = [formatter dateFromString:dateString];
    NSLog(@"%@",date);
    [formatter release];
    return date;
}


#pragma mark - 
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    //NSLog(@"%@",[theRequest.error description]);
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    /*SBJSON *parser = [SBJSON new];
    id dataDict = [parser objectWithString:responseData];
    [parser release];*/
    if ([responseData isEqualToString:@"{\"ID\" : \"2002\" , \"Description\" : \"Authentication failed \" }"]) {
        [appDelegate showLoginViewWhenAuthenFailed];
        return;
    } 
    
    appDelegate.isSyncing = NO;
    switch (theRequest.tag) {
        case 2000000:
        {
            isLoadingUpcomingReminder = NO;
            //[self scheduleUpcomingReminder];
        }
            break;
        case 1000000:
        {
            isLoadingSetupReminder = NO;
            //[self getUpcomingReminder];
        }
            break;  
        case 3000000:
        {
            isLoadingYourReminder = NO;
        }
            break;
        case 5000000:
        {
            
        }
            break;
        case 6000000:
        {
            ParseJSON *parseJson = [[ParseJSON alloc] init];
            appDelegate.appMedicationList = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTextFile:@"MedicationList"]];
            [parseJson release];
            [self sortMedicationList];
        }
            break;
        default:
            break;
    }
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    SBJSON *parser = [SBJSON new];
    NSDictionary *dataDict = (NSDictionary*)[parser objectWithString:responseData];
//    NSLog(@"%@",responseData);
    
    //session expired
    if ([responseData isEqualToString:@"{\"ID\" : \"2002\" , \"Description\" : \"Authentication failed \" }"]) {
        [appDelegate showLoginViewWhenAuthenFailed];
        return;
    } 
    switch (theRequest.tag) {
        case 0: //login
        {
            if ([dataDict objectForKey:@"deviceToken"] != nil) {
                appDelegate.deviceToken = [NSString stringWithString:[dataDict objectForKey:@"deviceToken"]];
                //[self syncToServer];
            }
            [responseData release];
        }
            break;
        case 1000000: //get setup reminder
        {
            isLoadingSetupReminder = NO;
            if ([[dataDict class] isSubclassOfClass:[NSArray class]]) {
                if (appDelegate.arraySetupReminders != nil) {
                    [appDelegate.arraySetupReminders release];
                }
                appDelegate.arraySetupReminders = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
                [self performSelectorInBackground:@selector(insertDataToSetUpReminder) withObject:nil];
            }
            [responseData release];
        }
            break;
        case 2000000: //get upcoming reminder
        {
            isLoadingUpcomingReminder = NO;
            if ([[dataDict class] isSubclassOfClass:[NSArray class]]) {
                
                if (appDelegate.arrayUpcomingReminder != nil) {
                    [appDelegate.arrayUpcomingReminder release];
                }
                appDelegate.arrayUpcomingReminder = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
                NSLog(@"%d",[appDelegate.arrayUpcomingReminder count]);
                [self performSelectorInBackground:@selector(insertDataToUpcomingReminder) withObject:nil];
            }
            [responseData release];
        }
            break;
        case 3000000: //your reminder
        {
            isLoadingYourReminder = NO;
            if ([[dataDict class] isSubclassOfClass:[NSArray class]]) {
                if (appDelegate.arrayYourReminders != nil) {
                    //[appDelegate.arrayYourReminders release];
                }
                appDelegate.arrayYourReminders = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
                NSLog(@"YourReminder:%@",dataDict);
                [self performSelectorInBackground:@selector(insertDataToYourReminder) withObject:nil];
            }
            [responseData release];
        }
            break;
            case 5000000: //get movitational Message
        {
            NSLog(@"%@",responseData);
            appDelegate.dictBanner = [[NSDictionary alloc] initWithDictionary:dataDict];
            NSNotification *notification = [NSNotification notificationWithName:@"reloadBanner" object:nil];
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                                 NSUserDomainMask, YES); 
            [appDelegate.dictSetting setObject:responseData forKey:@"movitationalMessage"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [appDelegate.dictSetting setObject:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]] forKey:@"movitationalDate"];
            [dateFormatter release];
            NSString *cacheDirectory = [paths objectAtIndex:0];  
            NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
            [appDelegate.dictSetting writeToFile:filePath atomically:YES];
            [responseData release];
        }
            break;
            case 6000000:
        {
            appDelegate.appMedicationList = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
            [self sortMedicationList];
            [appDelegate.dictSetting setObject:[NSString stringWithFormat:@"%f",(double)[[NSDate date] timeIntervalSince1970]] forKey:@"date"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                                 NSUserDomainMask, YES); 
            
            NSString *cacheDirectory = [paths objectAtIndex:0];  
            NSString *filePath1 = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
            [appDelegate.dictSetting writeToFile:filePath1 atomically:YES];
            
            //write data to text file
            NSString *filePath = [cacheDirectory stringByAppendingString:@"/MedicationList.txt"];
            SBJSON *json = [SBJSON new];
            NSString *str = [json stringWithObject:appDelegate.appMedicationList error:nil];
            //[[appDelegate doCipher:str :kCCEncrypt] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [responseData release];
        }
            break;
            case 7000000: //verify account
            if ([responseData rangeOfString:@"\"ID\" : \"500\""].location == NSNotFound) {                
                if ([[dataDict class] isSubclassOfClass:[NSArray class]]) {
                    if (appDelegate.arrayYourReminders != nil) {
                        //[appDelegate.arrayYourReminders release];
                    }
                    appDelegate.arrayYourReminders = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
                    [self performSelectorInBackground:@selector(insertDataToYourReminder) withObject:nil];
                }
                
                [self getMedicationList];
                
                [appDelegate.dictSetting setObject:
                 [appDelegate doCipher:appDelegate.deviceToken  :kCCEncrypt]
                                            forKey:@"token"]; 
                [self getUpcomingReminder];
                if (appDelegate.isDownloadMotivationalMessage) {
                    [self getMotivationalMessage];
                }
                else {
                    SBJSON *json = [SBJSON new];
                    NSString *str = [NSString stringWithFormat:@"%@",[appDelegate.dictSetting objectForKey:@"movitationalMessage"]];
                    appDelegate.dictBanner = [[NSMutableDictionary alloc] initWithDictionary:[json objectWithString:str]];
                    [json release];
                }
            }
            else {
                [appDelegate showLoginViewWhenWrongPass];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Journal" message:@"Wrong userID or password. Please login try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            break;
        case 9000000:
                NSLog(@"%@",responseData);
        default: //sync
        {
            NSLog(@"%@",dataDict);
            //[recordDao deleteAtIndex:theRequest.tag];
            for (int i = 0; i < [arrayIndex count]; i++) {
                [recordDao deleteAtIndex:[[arrayIndex objectAtIndex:i] intValue]];
            }
            appDelegate.syned = YES;
            [self getYourReminder];
            [self getSetUpReminder];
            /*count++;
             if (count == totalCount) {
             [self getYourReminder];
             [self getSetUpReminder];
             }*/
        }
            break;
    }

    [parser release];
}

- (void)insertDataToYourReminder {
    NSArray *arrayReminders = [NSArray arrayWithArray:appDelegate.arrayYourReminders];
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
    [recordDao deleteNormalRecord];
    for (int i = 0; i < [arrayReminders count]; i++) {
        SBJSON *json = [SBJSON new];
        NSString *str = [json stringWithObject:[arrayReminders objectAtIndex:i] error:nil];
        NSString *msgid = [NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"msgboxid"]];
        NSLog(@"setup reminder:%@",str);        
        //[recordDao insertWithContent:[appDelegate doCipher:str :kCCEncrypt] WithStatus:@"normal" WithMsgid:msgid];
        [recordDao insertWithContent:str WithStatus:@"normal" WithMsgid:msgid];
    }
    [recordDao1 release];
    NSNotification *notification = [NSNotification notificationWithName:@"reloadYourReminder" object:nil];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}
- (void)insertDataToSetUpReminder {
    NSMutableArray *arrayReminders = [[NSMutableArray alloc] initWithArray:appDelegate.arraySetupReminders];
    
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName = [[NSString alloc] initWithString:SETUP_REMINDER_TABLE];
    [recordDao1 deleteNormalRecord];
    for (int i = 0; i < [arrayReminders count]; i++) {
        SBJSON *json = [SBJSON new];
        NSString *str = [json stringWithObject:[arrayReminders objectAtIndex:i] error:nil];
        NSString *msgid = [NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"msgschedulerid"]];
        //[recordDao1 insertWithContent:[appDelegate doCipher:str :kCCEncrypt] WithStatus:@"normal" WithMsgid:msgid];

        [recordDao1 insertWithContent:str WithStatus:@"normal" WithMsgid:msgid];
    }
    [recordDao1 release];
    NSNotification *notification = [NSNotification notificationWithName:@"reloadSetUpReminder" object:nil];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
    [self getUpcomingReminder];
}
-(void)insertDataToUpcomingReminder {
    NSArray *arrayReminders = [NSArray arrayWithArray:appDelegate.arrayUpcomingReminder];
    if ([arrayReminders count] > 0) {
        RecordDao *recordDao1 = [[RecordDao alloc] init];
        recordDao1.tableName = [[NSString alloc] initWithString:UPCOMING_REMINDER_TABLE];
        [recordDao1 deleteAllData];
        SBJSON *json = [SBJSON new];
        
        for (int i = 0; i < [arrayReminders count]; i++) {
            NSString *str = [json stringWithObject:[arrayReminders objectAtIndex:i] error:nil];
            NSString *msgid = [NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"deliverydate"]];
            [recordDao1 insertWithContent:str WithStatus:@"normal" WithMsgid:msgid];
        }
        [self scheduleUpcomingReminder];
        [json release];
        [recordDao1 release];
    }
    else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    appDelegate.isSyncing = NO;
}
@end
