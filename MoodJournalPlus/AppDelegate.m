

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "NSData-AES.h"
#import "Base64.h"
#import "Cipher.h"
#import "RestConnection.h"
#import "ASIHTTPRequest.h"
#import "YourReminderViewController.h"
#import "DB.h"
#import "Reachability.h"
#import "BackgroundService.h"
#import "SetupAReminderAction.h"
#import "ParseJSON.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize naviController;
@synthesize dictSetting;
@synthesize deviceToken;
@synthesize userID;
@synthesize password;
@synthesize reminderTime;
@synthesize frequency;
@synthesize medicationImageLink;
@synthesize  showDetailFirst;
@synthesize deviceID;
@synthesize pushNotificationToken;
@synthesize theFirstShowYourReminder;
@synthesize isLoadingYourReminder;
@synthesize registerNotification;
@synthesize theFirstShowSetupReminder;
@synthesize theFirstShowHistory;
@synthesize theFirstLoadMedication;
@synthesize arrayYourReminders;
@synthesize appMedicationList;
@synthesize appDict;
@synthesize appKey;
@synthesize isHaveInternetConnection;
@synthesize backgroundService;
@synthesize arrayLocalNotification;
@synthesize arrayMsgidNofify;
@synthesize arraySetupReminders;
@synthesize arrayKeys;
@synthesize dictionaryMedicationList;
@synthesize keysYourReminder;
@synthesize dictYourReminder;
@synthesize arrayUpcomingReminder;
@synthesize isFirstSignUp;
@synthesize isSecondSignUp;
@synthesize isHavePushNotificationOnBackground;
@synthesize isSyncing;
@synthesize needToSync;
@synthesize dictBanner;
@synthesize isDownloadMotivationalMessage;
@synthesize arrayTodayHistory;
@synthesize syned;
@synthesize isAirplaneModeSet;
@synthesize isFirstConnectionTested;


- (void)dealloc
{
    [_window release];
    [hostReach release];
    [internetReach release];
    [arrayLocalNotification release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{        
    arrayMsgidNofify = [[NSMutableArray alloc] init];
    arrayLocalNotification = [[NSMutableArray alloc] init];
    isHaveInternetConnection = YES;
    DB *database = [[DB alloc] init];
    if (![database initDatabase]) {
        //Connect Database failed!
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"There was an issue configuring the application.  Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alerView show];
        [alerView release];
    }
    // Handle launching from a notification
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    // If not nil, the application was based on an incoming notifiation
    if (notification) 
    {
         if ([[notification.userInfo objectForKey:@"Key 2"] isEqualToString:@"snooze"]) {
        NSLog(@"Notification initiated app startup");
        NSString *msgid=[notification.userInfo objectForKey:@"Key 1"];
        RecordDao *recordDao1 = [[RecordDao alloc] init];
        recordDao1.tableName =[[NSString alloc] initWithString:SNOOZE_TABLE];
        [recordDao1 deleteRecordWithMsgID:msgid];
        [recordDao1 release];
             [[UIApplication sharedApplication] cancelLocalNotification:notification];
         }
    }
    theFirstShowSetupReminder = YES;
    theFirstShowYourReminder = YES;
    theFirstShowHistory = YES;
    theFirstLoadMedication = YES;
    registerNotification = NO;//register method to do after get pushnotification.
    isAirplaneModeSet = NO;   
    isHaveInternetConnection=NO;
    isFirstConnectionTested=NO;
    allowShowAlert = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(allowShowAlert) userInfo:nil repeats:NO];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    [self performSelector:@selector(registerRemoteNoti) withObject:nil afterDelay:1.0];
    
    deviceID = [[NSString alloc] initWithString:[[UIDevice currentDevice] uniqueIdentifier]];
    showDetailFirst = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
    NSFileManager *fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:filePath]) {
        [fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"] toPath:filePath error:nil];
    }
    [fm release];
    dictSetting = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSLog(@"%@",dictSetting);
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if (![currentVersion isEqualToString:[dictSetting objectForKey:@"version"]]) {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
        hostReach = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
        [hostReach startNotifier];
        internetReach = [[Reachability reachabilityForInternetConnection] retain];
        [internetReach startNotifier];
        
        [self addObserver:self forKeyPath:@"isHaveInternetConnection" options:NSKeyValueObservingOptionNew context:NULL];
        
        backgroundService = [[BackgroundService alloc] init];
        
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        [self showLoginViewWhenAuthenFailed];
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
        return YES;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    if ([date isEqualToString:[dictSetting objectForKey:@"movitationalDate"]]) {
        isDownloadMotivationalMessage = NO;
    }
    else {
        isDownloadMotivationalMessage = YES;
    }

    //create history path.
    NSString *newDirectory = [NSString stringWithFormat:@"%@/History", [paths objectAtIndex:0]];
    
    // Check if the directory already exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:newDirectory]) {
        // Directory does not exist so create it
        [[NSFileManager defaultManager] createDirectoryAtPath:newDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    if ([dictSetting objectForKey:@"settedMedication"]== nil) {
        [dictSetting setObject:@"0" forKey:@"settedMedication"];
    }
    
    // Override point for customization after application launch.
    if ([[dictSetting objectForKey:@"userID"] isEqualToString:@""]) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
        naviController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [loginViewController release];
    }
    else {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginRememberView" bundle:nil];
        loginViewController.textFieldUserName.text =[self doCipher:[self.dictSetting objectForKey:@"userID"] :kCCDecrypt];
        naviController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [loginViewController release];
    }
    
    [naviController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    naviController.navigationBar.tintColor = [UIColor 
                                              colorWithRed:216.0f/255.0f           
                                              green:216.0f/255.0f 
                                              blue:216.0f/255.0f                
                                              alpha:1.0f];
    self.window.rootViewController = naviController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    UIImage *image = [UIImage imageNamed:@"header.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [naviController.navigationBar.topItem setTitleView:imageView];
    [imageView release];
    
    naviController.navigationBarHidden = YES;
    //[self performSelectorInBackground:@selector(startUp) withObject:nil];
    
    ParseJSON *parseJson = [[ParseJSON alloc] init];
    arrayYourReminders = [[parseJson parseDataFromTable:YOUR_REMINDER_TABLE withStatus:@"normal"] retain];
    [parseJson release];
    //[self performSelectorInBackground:@selector(sortMedicationList) withObject:nil];
    [self performSelectorInBackground:@selector(sortReminderByDeleveryDate) withObject:nil];
    
    [self performSelector:@selector(startUp) withObject:nil afterDelay:0.2];
    
    //[NSTimer scheduledTimerWithTimeInterval:7200 target:self selector:@selector(reCallToServer) userInfo:nil repeats:YES];
    
    return YES;
}

- (void)reCallToServer {
    [backgroundService syncToServer];
}

- (void)startUp {
    ParseJSON *parseJson = [[ParseJSON alloc] init];
    appMedicationList = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTextFile:@"MedicationList"]];
    arrayYourReminders = [[parseJson parseDataFromTable:YOUR_REMINDER_TABLE withStatus:@"normal"] retain];
    [parseJson release];
    [self performSelectorInBackground:@selector(sortMedicationList) withObject:nil];
    [self performSelectorInBackground:@selector(sortReminderByDeleveryDate) withObject:nil];
    [self performSelector:@selector(sortReminderByDeleveryDate) withObject:nil afterDelay:1.0];
    
//    NSDate *now = [NSDate date];
//    NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];
//    NSLog(@"%d",[array count]);
//    for (int i = 0; i < [array count]; i++) {
//        
//        UILocalNotification *notification = [array objectAtIndex:i];
//        NSLog(@"%@",notification.userInfo);    
//            if ([[notification.userInfo objectForKey:@"Key 2"] isEqualToString:@"snooze"]) {
//
//        }
//        else {
//            NSDate *date1 = notification.fireDate;
//            NSDate *date = [notification.fireDate addTimeInterval:-90];
//            NSLog(@"%@",date);
//            
//            NSString *str = @"1";
//            if ([date compare:now] == NSOrderedAscending) {
//                date = [NSDate date];
//                str = @"0";
//                isHavePushNotificationOnBackground = YES;
//                [[UIApplication sharedApplication] cancelLocalNotification:notification];
//                
//                if ([date1 compare:now] == NSOrderedDescending) {
//                    [self performSelector:@selector(showAlert) withObject:nil afterDelay:1.0];
//                }
//            }
//            else {
//                NSInteger key1 = [[notification.userInfo objectForKey:@"Key 1"] intValue];
//                NSDate *date2 = [notification.fireDate addTimeInterval:-90];
//                [[UIApplication sharedApplication] cancelLocalNotification:notification];
//                
//                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//                localNotification.fireDate = date2;
//                localNotification.alertBody = @"You have a Reminder.";
//                localNotification.soundName = UILocalNotificationDefaultSoundName;
//                
//                NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",key1], @"Key 1", str, @"Key 2", nil];
//                localNotification.userInfo = infoDict;
//                
//                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//            }
//        }
//
//        }
//   
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    hostReach = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
	[hostReach startNotifier];
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
    
    [self addObserver:self forKeyPath:@"isHaveInternetConnection" options:NSKeyValueObservingOptionNew context:NULL];
    
    backgroundService = [[BackgroundService alloc] init];
    syned = NO;
    deviceToken = [[NSString alloc] initWithFormat:@"%@",[self doCipher:[dictSetting objectForKey:@"token"] :kCCDecrypt]];
    if (![deviceToken isEqualToString:@""]) {
        RecordDao *recordDao = [[RecordDao alloc] init];
        
        recordDao.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
        NSMutableArray *array1 = [recordDao resultSetWithoutNormalStatus];
        if ([array1 count] > 0) {
            [backgroundService syncToServer];
            needToSync = YES;
        }
    }
}

- (void)showAlert {
    if (!isHaveInternetConnection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Journal Plus" message:@"Local Alarm : A message is available for you to read in your messagebox!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)allowShowAlert {
    allowShowAlert = YES;
}
#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
    if (isHaveInternetConnection) {
        
        
        if ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] >= 5) {
            hadLocalNotificationInBackground = NO;
        }
        else {
            hadLocalNotificationInBackground = YES;
        }
        if (hadLocalNotificationInBackground) {
            allowShowAlert = NO;
            [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(allowShowAlert) userInfo:nil repeats:NO];
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            
            [self performSelector:@selector(registerRemoteNoti) withObject:nil afterDelay:5.0];
        }
        
        if (![deviceToken isEqualToString:@""] && deviceToken != nil && deviceToken != NULL) {
            [backgroundService syncToServer];
        }
        else {
            [backgroundService login];
        }
    }
}

- (void)registerRemoteNoti {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
}
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    if (netStatus == 2 || netStatus == 1) {
        if (!self.isHaveInternetConnection) {
            self.isHaveInternetConnection = YES;
        }
    }
    else {
        if (self.isHaveInternetConnection) {
            self.isHaveInternetConnection = NO;
        }
    }
    
    if(!isFirstConnectionTested)
    {
        isFirstConnectionTested=YES;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"will resign active");
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //NSLog(@"%@",arrayLocalNotification);
//    NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];
//    NSLog(@"%d",[array count]);
//    for (int i = 0; i < [array count]; i++) {
//        UILocalNotification *notification = [array objectAtIndex:i];
//        if ([[notification.userInfo objectForKey:@"Key 2"] isEqualToString:@"snooze"]) {
//            NSLog(@"have snooze notification");
//            NSDate *date = [notification.fireDate addTimeInterval:10];
//            NSLog(@"%@",date);
//            NSInteger key1 = [[notification.userInfo objectForKey:@"Key 1"] intValue];
//            [[UIApplication sharedApplication] cancelLocalNotification:notification];
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.fireDate = date;
//            
//            localNotification.alertBody = @"You have a Reminder.Snooze!";
//            localNotification.soundName = UILocalNotificationDefaultSoundName;
//            
//            NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",key1], @"Key 1", @"snooze", @"Key 2", nil];
//            localNotification.userInfo = infoDict;
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//        }
//        else {
//            NSDate *date = [notification.fireDate addTimeInterval:90];
//            NSLog(@"%@",date);
//            NSInteger key1 = [[notification.userInfo objectForKey:@"Key 1"] intValue];
//            [[UIApplication sharedApplication] cancelLocalNotification:notification];
//            
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.fireDate = date;
//            
//            localNotification.alertBody = @"You have a Reminder.";
//            localNotification.soundName = UILocalNotificationDefaultSoundName;
//            
//            NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",key1], @"Key 1", @"Object 2", @"Key 2", nil];
//            localNotification.userInfo = infoDict;
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//        }
//}
//    
//    NSLog(@"--- %d",[[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
   sleep(3);
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"will enter foreground");
    /*
     
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark - action
- (NSString*) doCipher:(NSString*)plainText:(CCOperation)encryptOrDecrypt {
    if ([[plainText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return @"";//nothing to encrypt or decrypt
    }
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *EncryptData = [NSData dataFromBase64String:plainText];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        plainTextBufferSize = [plainText length];
        vplainText = (const void *) [plainText UTF8String];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t iv[kCCBlockSize3DES];
    
    uint8_t iv[kCCBlockSizeAES128];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    // memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    NSString *key = @"1234567890123456";
    const void *vkey = (const void *) [key UTF8String];
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       vkey, //"123456789012345678901234", //key
                       kCCKeySizeAES128,
                       iv, //"init Vec", //iv,
                       vplainText, //"Your Name", //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    if (ccStatus == kCCSuccess) { }
    else if (ccStatus == kCCParamError) {
        NSLog(@"PARAM ERROR");
        return @"";
    }
    else if (ccStatus == kCCBufferTooSmall) {
        
        NSLog(@"BUFFER TOO SMALL");
        return @"";
    }
    else if (ccStatus == kCCMemoryFailure) {
        NSLog(@"MEMORY FAILURE");
        return @"";
    }
    else if (ccStatus == kCCAlignmentError) {
        return @"";
        NSLog(@"ALIGNMENT");   
        
    }
    else if (ccStatus == kCCDecodeError) {
        NSLog(@"Decode error for string");
        return @"";
    }
    else if (ccStatus == kCCUnimplemented) {
        NSLog(@"DoCipher: UNIMPLEMENTED");
        return @"";
    }
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        result = [[ [NSString alloc] initWithData: [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSASCIIStringEncoding] autorelease];
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [myData base64EncodedString];   
    }    
    return result;
}

- (NSString *)getProperty: (NSString *)key forData: (NSDictionary *)dataList{
    NSArray *properties;
    NSString *value= [[[NSString alloc] initWithString:@" "] autorelease];
    properties = [dataList objectForKey:@"properties"];
    for (int i = 0; i <[properties count]; i++) {
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyName"] isEqualToString:key] &&[[properties objectAtIndex:i] objectForKey:@"propertyValue"]!=nil && ![[[properties objectAtIndex:i] objectForKey:@"propertyValue"] isKindOfClass:[NSNull class]]) {
            value = [NSString stringWithString:[[properties objectAtIndex:i] objectForKey:@"propertyValue"]];
            break;
        }
    }
    return value;
}

- (void)sortMedicationList {
    NSMutableArray *array = appMedicationList;
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
    arrayKeys = [[NSMutableArray alloc] initWithArray:keys];
    dictionaryMedicationList = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [keys release];
    [dict release];
}

- (NSMutableArray*)sortReminderByDeleveryDate {
    
    NSMutableArray *arrayReminders = arrayYourReminders;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    
    if (dict != nil) {
        [dict release];
        dict = nil;
    }
    if (keys != nil) {
        [keys release];
        keys = nil;
    }
    dict = [[NSMutableDictionary alloc] init];
    keys = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrayReminders count]; i++) {
        NSString *deliveryDate = [self convertDateFromFloatString:[NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"deliverydate"]] toDateStype:YES withTimeZone:[NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"timeZone"]]];
        BOOL esxited = NO;
        for (int j = 0; j < [keys count]; j++) {
            if ([[keys objectAtIndex:j] isEqualToString:deliveryDate]) {
                esxited = YES;
                break;
            }
        }
        if (!esxited) {
            [keys addObject:deliveryDate];
        }
    }
    for (int i = 0; i < [keys count]; i++) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int j = 0; j < [arrayReminders count]; j++) {
            NSString *str = [self convertDateFromFloatString:[NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:j] objectForKey:@"deliverydate"]] toDateStype:YES withTimeZone:[NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:j] objectForKey:@"timeZone"]]];
            if ([str isEqualToString:[keys objectAtIndex:i]]) {
                [arr addObject:[arrayReminders objectAtIndex:j]];
            }
        }
        [dict setObject:arr forKey:[keys objectAtIndex:i]];
        [arr release];
    }
    if (keysYourReminder != nil) {
        [keysYourReminder release];
        [dictYourReminder release];
    }
    keysYourReminder = [[NSMutableArray alloc] initWithArray:keys];
    dictYourReminder = [[NSMutableDictionary alloc] initWithDictionary:dict];
    return nil;
}

- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone {
    NSString *dateString;
    NSString *currentDate;
    
    double deliveryDate = [floatString doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (date) {
        [formatter setDateStyle:NSDateFormatterFullStyle];   
    }
    else {
        [formatter setTimeStyle:NSDateFormatterShortStyle];   
    }
    
    
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateString = [[[NSString alloc] initWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)((double)deliveryDate/(double)1000)]]] autorelease];
    
    currentDate = [formatter stringFromDate:[NSDate date]];
    if ([dateString isEqualToString:currentDate]) {
        //today
        [formatter setDateStyle:NSDateFormatterLongStyle];
        NSString *a = [NSString stringWithFormat:@"Today, %@", [formatter stringFromDate:[NSDate date]]];
        [formatter release];   
        return a;
    }
    [formatter release];
    return dateString;
}

#pragma mark pushNotification
- (NSString *)pushNotification {
    return @"Success";
}

//if register success
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken1 { 
    NSString *deviceTokenStr = [[deviceToken1 description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    pushNotificationToken = [[NSString alloc] initWithString:deviceTokenStr];
    NSLog(@"Did register for remote %@",deviceTokenStr);
    NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];

    NSLog(@"%@",array);
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"error %@",[error debugDescription]);
    //pushNotificationToken = [[NSString alloc] initWithString:@""];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"-------------------------------");
    if (!haveLocalNotification) {
        NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];
            for (UILocalNotification *noti in array) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:[NSString stringWithFormat:@"%@",noti.userInfo]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                if (![[noti.userInfo objectForKey:@"Key 2"] isEqualToString:@"snooze"]) {
                    [[UIApplication sharedApplication] cancelLocalNotification:noti];
                    break;
                }
            }
    }
    NSLog(@"user info %@",userInfo);
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if ([alert rangeOfString:@"\"type\":1"].location != NSNotFound) { //upadte Setup Reminder list
        if (deviceToken != nil) {
            if (deviceToken != nil) {
                [backgroundService getSetUpReminder];
            }
        }
    }
    else {
        if ([alert rangeOfString:@"\"type\":2"].location != NSNotFound) { //password changed
            [self showLoginViewWhenAuthenFailed];
        }
        else {
            if ([alert rangeOfString:@"\"type\":3"].location != NSNotFound) { //
                
            }
            else {
                theFirstShowYourReminder = YES;
                theFirstShowSetupReminder = YES;
                theFirstShowHistory = YES;
                /*if ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] < 5) {
                    return;
                }*/
                if (allowShowAlert) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"You have a reminder." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                    havePushNotification = YES;
                    haveLocalNotification = NO;
                }
                
                if (deviceToken != nil) {
                    [backgroundService getYourReminder];
                    [backgroundService getSetUpReminder];
                    [backgroundService syncToServer];
                }
            }
        }
    }
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"++++++++++++++++++++++++++++++++");
    havePushNotification = NO;
    haveLocalNotification = YES;
    NSLog(@"%@",notification.userInfo);
    
    if ([[notification.userInfo objectForKey:@"Key 2"] isEqualToString:@"snooze"]) {
        haveLocalNotification = NO;
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(showLocalPushNotification) userInfo:nil repeats:NO];
        NSString *msgid=[notification.userInfo objectForKey:@"Key 1"];
        RecordDao *recordDao1 = [[RecordDao alloc] init];
        recordDao1.tableName =[[NSString alloc] initWithString:SNOOZE_TABLE];
        [recordDao1 deleteRecordWithMsgID:msgid];
        [recordDao1 release];
        
    }
    else {
        if ([arrayLocalNotification count] > [[notification.userInfo objectForKey:@"Key 1"] intValue]) {
            [arrayLocalNotification removeObjectAtIndex:[[notification.userInfo objectForKey:@"Key 1"] intValue]];
        }
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(showLocalPushNotification) userInfo:nil repeats:NO];
        RecordDao *recordDao = [[RecordDao alloc] init];
        recordDao.tableName = [[NSString alloc] initWithString:UPCOMING_REMINDER_TABLE];
        [recordDao updateStatus:@"reminded" ForMsg:[notification.userInfo objectForKey:@"Key 2"]];
        [recordDao release];
        
        application.applicationIconBadgeNumber = 0;
    }

}

- (void)showLocalPushNotification {
    //haveLocalNotification = NO;
    if (!havePushNotification) {
        //  = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Journal Plus" message:@" Local Alarm : A message is available for you to read in your messagebox!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadYourReminder" object:nil];
        NSNotification *notification = [NSNotification notificationWithName:@"reloadYourReminder" object:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
        if (isHaveInternetConnection) {
            [backgroundService getYourReminder];
        }
    }
}

- (void)showLoginViewWhenWrongPass {
    [dictSetting setObject:@"0" forKey:@"rememberPass"];
    [dictSetting setObject:@"" forKey:@"password"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
    [dictSetting writeToFile:filePath atomically:YES];
    
    [naviController release];
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginRememberView" bundle:nil];
    loginViewController.textFieldUserName.text =[self doCipher:[self.dictSetting objectForKey:@"userID"] :kCCDecrypt];
    naviController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [naviController.navigationBar setBarStyle:UIBarStyleBlack];
    [loginViewController release];
    
    [naviController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    naviController.navigationBar.tintColor = [UIColor 
                                              colorWithRed:216.0f/255.0f           
                                              green:216.0f/255.0f 
                                              blue:216.0f/255.0f                
                                              alpha:1.0f];
    naviController.navigationBarHidden = YES;
    
    self.window.rootViewController = naviController;
}

- (void) showLoginViewWhenAuthenFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Your session has expired.  Please login again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [dictSetting release];
    dictSetting = [[NSMutableDictionary alloc] init];
    [dictSetting setObject:@"0" forKey:@"rememberPass"];
    [dictSetting setObject:@"1" forKey:@"settedMedication"];
    [dictSetting setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version"];
    [dictSetting setObject:@"" forKey:@"userID"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
    [dictSetting writeToFile:filePath atomically:YES];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:@"" forKey:@"PIN"];
    if (naviController != nil) {
        [naviController release];
    }
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
    naviController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [naviController.navigationBar setBarStyle:UIBarStyleBlack];
    [loginViewController release];
    
    [naviController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    naviController.navigationBar.tintColor = [UIColor 
                                              colorWithRed:216.0f/255.0f           
                                              green:216.0f/255.0f 
                                              blue:216.0f/255.0f                
                                              alpha:1.0f];
    naviController.navigationBarHidden = YES;
    
    self.window.rootViewController = naviController;
    
    NSArray *cacheDirectoryFile = [[NSFileManager defaultManager] directoryContentsAtPath:cacheDirectory];
    for (int i = 0; i < [cacheDirectoryFile count]; i++) {
        if ([[cacheDirectoryFile objectAtIndex:i] rangeOfString:@".txt"].location != NSNotFound) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",cacheDirectory,[cacheDirectoryFile objectAtIndex:i]] error:nil];
        }
    }
    
    NSArray *historyDirectoryFile = [[NSFileManager defaultManager] directoryContentsAtPath:[cacheDirectory stringByAppendingString:@"/History"]];
    for (int i = 0; i < [historyDirectoryFile count]; i++) {
        if ([[historyDirectoryFile objectAtIndex:i] rangeOfString:@".txt"].location != NSNotFound) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[cacheDirectory stringByAppendingString:@"/History"],[historyDirectoryFile objectAtIndex:i]] error:nil];
        }
    }
    
    RecordDao *recordDao = [[RecordDao alloc] init];
    recordDao.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
    [recordDao deleteAllData];
    [recordDao.tableName release];
    recordDao.tableName = [[NSString alloc] initWithString:SETUP_REMINDER_TABLE];
    [recordDao deleteAllData];
    [recordDao release];
    
}
- (BOOL) hasErrorMessage: (NSDictionary*)respondData{
    if ([respondData objectForKey:@"Description"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:[respondData objectForKey:@"Description"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return true;
    }
    return false;
}
-(void)delReminderExpire
{
    ParseJSON *parseJson1 = [[ParseJSON alloc] init];
    NSMutableArray *arr1=[[NSMutableArray alloc] init];
    arr1=[[parseJson1 parseDataFromTable:YOUR_REMINDER_TABLE withStatus:@"normal"] retain];
    for (NSMutableDictionary *reminder in arr1) {
        if ([[reminder objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"]) {
            NSDate *now=[NSDate date];
            double expire = (double)[[now dateByAddingTimeInterval:-60*60*24] timeIntervalSince1970]*1000.0;
            double deliverydate = [[reminder objectForKey:@"deliverydate"] doubleValue];
            if (deliverydate <= expire) {
                RecordDao *recordD = [[RecordDao alloc] init];
                recordD.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
                NSString *msgid =[reminder objectForKey:@"msgboxid"];
                [recordD deleteRecordWithMsgID:msgid];
                recordD.tableName=[[NSString alloc] initWithString:SNOOZE_TABLE];
                [recordD deleteRecordWithMsgID:msgid];
                [recordD release];
                NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];
                for (int i = 0; i < [array count]; i++) {
                    UILocalNotification *notification = [array objectAtIndex:i];   
                    if ([[notification.userInfo objectForKey:@"Key 2"] isEqualToString:@"snooze"]&&[[notification.userInfo objectForKey:@"Key 1"] isEqualToString:msgid]) {
                        [[UIApplication sharedApplication] cancelLocalNotification:notification];
                    }
                }
                [array release];
            }
            
        }
        
    }
}
@end
