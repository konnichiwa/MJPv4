

#import "YourReminderViewController.h"
#import "ParseJSON.h"
#import "YourReminderCell.h"
#import "HistoryViewController.h"
#import "ReminderDetailViewController.h"
#import "DownloadImage.h"
#import "ASIHTTPRequest.h"
#import "TermOfUseViewController.h"
#import "MoreOptionsViewController.h"
#import "RestConnection.h"
#import "SBJSON.h"
#import "Record.h"
#import "RecordDao.h"
#import "BackgroundService.h"
#import "BannerViewController.h"
#import "AlertMedication.h"

// Private stuff
@interface YourReminderViewController ()
/*
 - (void)imageFetchComplete:(ASIHTTPRequest *)request;
 - (void)imageFetchFailed:(ASIHTTPRequest *)request;*/
- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;
@end

@implementation YourReminderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Reminders";
        //get reminders from server.
        indicator.hidden = YES;
        [indicator startAnimating];
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated{

    
}
-(void)viewWillAppear:(BOOL)animated
{
    [appDelegate delReminderExpire];
}
- (void)dealloc {
    [super dealloc];
    [tableView release];
    [labelMotivation release];
    [arrayReminders release];
    [arrayReminderByDeleveryDate release];
    [dict release];
    [keys release];
    [labelNoRecord release];
    [recordDao release];
    [labelBanner release];
    [buttonBanner release];
    //[downLoadImage release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSLog(@"%d",[array count]);
    [indicator startAnimating];
    buttonBanner.userInteractionEnabled = NO;
    ParseJSON *parseJson = [[ParseJSON alloc] init];
    arrayUpcomming = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTable:UPCOMING_REMINDER_TABLE withoutStatus:@"aaa"]];
    [parseJson release];
    
    recordDao = [[RecordDao alloc] init];
    recordDao.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
    gotoDetail = NO;
    self.navigationController.navigationBarHidden = YES;
    [self reloadData];    
    [tableView addSubview:labelNoRecord];
    
    if (appDelegate.registerNotification == NO) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDataOS:) name:@"hasNotification" object:nil];
        appDelegate.registerNotification = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData2) name:@"reloadYourReminder" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBanner) name:@"reloadBanner" object:nil];
    [self reloadBanner];
}
-(void)requestDataOS:(NSNotification*)notification{
    [self requestData];
}

- (void)reloadData1:(NSNotification*)notification {
    arrayReminders = [[NSMutableArray alloc] initWithArray:appDelegate.arrayYourReminders];
    [self performSelectorInBackground:@selector(reloadData) withObject:nil];
    //[self performSelector:@selector(reloadData) withObject:nil afterDelay:2.0];
}
- (id)getFirstReminder{ 
    gotoDetail = YES;
    if ([arrayReminders count]>0) {
        return [arrayReminders objectAtIndex:0];
    }
    else{
        return nil;
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark action

- (NSMutableArray*)sortReminderByDeleveryDate {
    
    /*if (dict != nil) {
        [dict release];
        dict = nil;
    }
    if (keys != nil) {
        [keys release];
        keys = nil;
    }*/
    dict = [[NSMutableDictionary alloc] init];
    keys = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrayReminders count]; i++) {
        NSString *deliveryDate = [self convertDateFromFloatString:[NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"deliverydate"]] toDateStype:YES withTimeZone:[NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"timeZone"]]];
        //NSString *deliveryDate = [[NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"deliverydate"]] retain];
        BOOL esxited = NO;
     //   NSLog(@"%@",keys);
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
            
             //NSString *str = [[NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"deliverydate"]] retain];
            
            if ([str isEqualToString:[keys objectAtIndex:i]]) {
                [arr addObject:[arrayReminders objectAtIndex:j]];
            }
        }
        [dict setObject:arr forKey:[keys objectAtIndex:i]];
        [arr release];
    }
    /*if (appDelegate.keysYourReminder != nil) {
        [appDelegate.keysYourReminder release];
        [appDelegate.dictYourReminder release];
    }*/
    appDelegate.keysYourReminder = [[NSMutableArray alloc] initWithArray:keys];
    appDelegate.dictYourReminder = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [tableView reloadData];
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

- (NSString*)convertDateFromFloatString2:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone {
    NSString *dateString;
    double deliveryDate = [floatString doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (date) {
        [formatter setDateStyle:NSDateFormatterLongStyle];   
    }
    else {
        [formatter setTimeStyle:NSDateFormatterShortStyle];   
    }
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateString = [[NSString alloc] initWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)((double)deliveryDate/(double)1000)]]];
    [formatter release];
    return [dateString autorelease];
}
- (IBAction)pressTermOfUse:(id)sender{
    if(!appDelegate.isAirplaneModeSet)
    {
        TermOfUseViewController *reminderDetailViewController = [[TermOfUseViewController alloc] init];
        [self.navigationController pushViewController:reminderDetailViewController animated:YES];
        [reminderDetailViewController release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:NOT_AVAIL_OFFLINE_MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)pressMoreOptions:(id)sender{
    /*if (finishLoading == NO&&appDelegate.showDetailFirst == YES) {
     return;
     }*///1405
   if(!appDelegate.isAirplaneModeSet)
    {
        MoreOptionsViewController *m = [[MoreOptionsViewController alloc] init];
        [self.navigationController pushViewController:m animated:YES];
        [m release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:NOT_AVAIL_OFFLINE_MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)pressHistory:(id)sender{
    
    /*if (finishLoading == NO&&appDelegate.showDetailFirst == YES) {
     return;
     }*///1405
    appDelegate.showDetailFirst = NO;
    HistoryViewController *m = [[HistoryViewController alloc] init];
    [self.navigationController pushViewController:m animated:YES];
    [m release];
}

- (IBAction)syncButtonPressed:(id)sender {
    if(!appDelegate.isHaveInternetConnection)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:NOT_AVAIL_OFFLINE_MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else
    {
        if (!appDelegate.isSyncing) {
            appDelegate.isSyncing = YES;
            [appDelegate.backgroundService syncToServer];
        }
    }
}
- (void)saveYourReminderToDatabase {
    [recordDao deleteNormalRecord];
    
    for (int i = 0; i < [arrayReminders count]; i++) {
        SBJSON *json = [SBJSON new];
        NSString *str = [json stringWithObject:[arrayReminders objectAtIndex:i] error:nil];
        NSString *msgid = [NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"msgboxid"]];
        if ([msgid isEqualToString:@"0"]) {
            msgid = [NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"msgschedulerid"]];
        }
        //[recordDao insertWithContent:[appDelegate doCipher:str :kCCEncrypt] WithStatus:@"normal" WithMsgid:msgid];
        [recordDao insertWithContent:str WithStatus:@"normal" WithMsgid:msgid];
    }
    
   }

- (void)showDetailReminder {
    NSIndexPath *ns = [NSIndexPath indexPathForRow:0 inSection:0];
    ReminderDetailViewController *reminderDetailViewController = [[ReminderDetailViewController alloc] initWithNibName:@"ReminderDetailView" bundle:nil];
    reminderDetailViewController.dictReminderDetail = [NSMutableDictionary dictionaryWithDictionary:[arrayReminders objectAtIndex:0]];
    reminderDetailViewController.selectIndexPath = ns;
    
    NSString *msgid = [NSString stringWithFormat:@"%@",[reminderDetailViewController.dictReminderDetail objectForKey:@"msgboxid"]];
    if ([msgid isEqualToString:@"0"]) {
        msgid = [NSString stringWithFormat:@"%@",[reminderDetailViewController.dictReminderDetail objectForKey:@"msgschedulerid"]];
    }
    reminderDetailViewController.iD = [recordDao getIndexOfARecordWithMsgid:msgid];
    [self.navigationController pushViewController:reminderDetailViewController animated:YES];
    [reminderDetailViewController release];
}
#pragma mark -
#pragma mark show alert action reminder
- (void)showAlertActionReminder {
    AlertMedication *alert=[[AlertMedication alloc] initWithNibName:@"AlertMedication" bundle:nil];
    alert.dictReminderDetail = [NSMutableDictionary dictionaryWithDictionary:[arrayReminders objectAtIndex:0]];
    alert.delegate=self;
    NSString *msgid = [NSString stringWithFormat:@"%@",[alert.dictReminderDetail objectForKey:@"msgboxid"]];
    if ([msgid isEqualToString:@"0"]) {
        msgid = [NSString stringWithFormat:@"%@",[alert.dictReminderDetail objectForKey:@"msgschedulerid"]];
    }
    alert.iD = [recordDao getIndexOfARecordWithMsgid:msgid];
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName =[[NSString alloc] initWithString:SNOOZE_TABLE];

    if ( ![recordDao1 hadMsgIdInSnoozeTable:msgid]) {
        [self.navigationController pushViewController:alert animated:YES];
    }
    
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([keys count] == 0) {
        labelNoRecord.hidden = NO;
    }
    else {
        labelNoRecord.hidden = YES;
    }
    return [keys count];
}
-(void)showView
{
    [self showDetailReminder];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    NSString *key = [keys objectAtIndex:section];
    
    labelTitle.text = [NSString stringWithFormat:@" %@",key];
    labelTitle.font = [UIFont boldSystemFontOfSize:14];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    return [labelTitle autorelease];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [dict objectForKey:key];
    return [nameSection count];
}

- (UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *indentifier = @"YourReminderCell";
    YourReminderCell *cell = (YourReminderCell *)[tableView dequeueReusableCellWithIdentifier: indentifier];
    if (cell == nil)  {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" 
                                                     owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[YourReminderCell class]])
                cell = (YourReminderCell *)oneObject;
	}
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    if ([[[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"System Custom Reminder"] || [[[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"System Precanned Reminder"]) {
        cell.labelName.text = @"Message";
    }
    else {
        //
        
    }
    NSString *dateText = [keys objectAtIndex:indexPath.section];
    //detect Medication Reminder
    
    if ([[[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"]) {
        cell.labelName.text = [NSString stringWithFormat:@"Take %@",[appDelegate getProperty:@"Medication Name" forData:[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]]] ;
        NSArray *arr = [[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"properties"];
        for (int i = 0; i < [arr count]; i++) {
            if ([[[arr objectAtIndex:i] objectForKey:@"propertyName"] isEqualToString:@"Strength"]) {
                cell.labelDate.text = [[arr objectAtIndex:i] objectForKey:@"propertyValue"];
                break;
            }
        }
    }
    else {
        cell.labelName.text = [[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"reminderName"];
        cell.labelDate.text = [dateText stringByReplacingOccurrencesOfString:[[dateText componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""];   
    }
    cell.labelTime.text = [self convertDateFromFloatString2:[[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"deliverydate"] toDateStype:NO withTimeZone:[[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"timeZone"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];   
    NSString *dateString = [self convertDateFromFloatString2:[[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"deliverydate"] toDateStype:YES withTimeZone:[[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"timeZone"]];
    [formatter release];
    cell.labelDate.text = dateString;
    cell.imageViewIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",
                                                    [[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"reminderName"]
                                                    ]];
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //h
    static NSString *indentifier = @"YourReminderCell";
    
    YourReminderCell *cell = (YourReminderCell *)[tableView dequeueReusableCellWithIdentifier: indentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    //end h
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ReminderDetailViewController *reminderDetailViewController = [[ReminderDetailViewController alloc] init];
    reminderDetailViewController.dictReminderDetail = [NSMutableDictionary dictionaryWithDictionary:[[dict objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
    
    reminderDetailViewController.selectIndexPath = indexPath;
    
    NSString *msgid = [NSString stringWithFormat:@"%@",[reminderDetailViewController.dictReminderDetail objectForKey:@"msgboxid"]];
    NSLog(@"%@",msgid);
    if ([msgid isEqualToString:@"0"]) {
        msgid = [NSString stringWithFormat:@"%@",[reminderDetailViewController.dictReminderDetail objectForKey:@"msgschedulerid"]];
    }
    
    reminderDetailViewController.iD = [recordDao getIndexOfARecordWithMsgid:msgid];
    NSLog(@"%d",reminderDetailViewController.iD);
    [self.navigationController pushViewController:reminderDetailViewController animated:YES];
    [reminderDetailViewController release];
}


/*
 #pragma mark -
 #pragma mark asihttprequest 
 - (void)imageFetchComplete:(ASIHTTPRequest *)request {
 [tableView reloadData];
 }
 - (void)imageFetchFailed:(ASIHTTPRequest *)request {
 [tableView reloadData];
 }*/

#pragma mark -
#pragma mark action
- (void)requestData {
    if (appDelegate.deviceToken != nil) {
        if (appDelegate.isLoadingYourReminder == YES) {
            [indicator startAnimating];
            [self reloadData];
            return;
        }
        appDelegate.isLoadingYourReminder = YES;
        //indicator.hidden = NO;
        [indicator startAnimating];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        //NSLog(@"Device Token: %@ ",appDelegate.deviceToken);
        
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"25" forKey:@"limit"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"desc" forKey:@"sortorder"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"deliverydate" forKey:@"sortfield"]];
        
        restConnection = [[RestConnection alloc] init];
        restConnection.viewController = self;
        [restConnection getDataWithPathSource:@"/rest/msgb/due" andParam:arr forService:@"getYourRemiders"];
        
        [arr release];
    }
}
- (void)reloadTable {

    if (appDelegate.arrayYourReminders != nil) {
        if (arrayReminders != nil) {
            [arrayReminders release];
        }
        arrayReminders = [[NSMutableArray alloc] initWithArray:appDelegate.arrayYourReminders];
        if (keys != nil) {
            [keys release];
            [dict release];
        }
        keys = [[NSMutableArray alloc] initWithArray:appDelegate.keysYourReminder];
        dict = [[NSMutableDictionary alloc] initWithDictionary:appDelegate.dictYourReminder];
        [tableView reloadData];
    }
}

- (void)reloadData2 {    
    indicator.hidden = YES;
    if (arrayReminders != nil) {
        [arrayReminders release];
    }
    arrayReminders = [[NSMutableArray alloc] initWithArray:appDelegate.arrayYourReminders];
    if (!appDelegate.isHaveInternetConnection) {
        ParseJSON *parseJson = [[ParseJSON alloc] init];
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTable:UPCOMING_REMINDER_TABLE withoutStatus:@"aaa"]];
        [parseJson release];
        
        for (int i = 0; i < [arr count]; i++) {
            double deliverydate = [[[arr objectAtIndex:i] objectForKey:@"deliverydate"] doubleValue];
            double now = (double)[[NSDate date] timeIntervalSince1970]*1000.0;
            
            if (deliverydate <= now) {
                [arrayReminders insertObject:[arr objectAtIndex:i] atIndex:0];
                
                RecordDao *recordD = [[RecordDao alloc] init];
                recordD.tableName = [[NSString alloc] initWithString:UPCOMING_REMINDER_TABLE];
                NSString *msgid = [NSString stringWithFormat:@"%@",[[arr objectAtIndex:i] objectForKey:@"deliverydate"]];
                NSInteger iD = [recordD getIndexOfARecordWithMsgid:msgid];
                [recordD deleteAtIndex:iD];
                [recordD release];
            }
        }
        [arr release];
    }
    [self sortReminderByDeleveryDate];
    if (appDelegate.showDetailFirst == YES && [arrayReminders count]>0) {
        appDelegate.showDetailFirst = NO;
//        [self showDetailReminder];
        [self showAlertActionReminder];
    }
}

- (void)reloadData3 {
    ParseJSON *parseJson = [[ParseJSON alloc] init];
    if (arrayReminders != nil) {
        [arrayReminders release];
        arrayReminders = nil;
    }
    
    arrayReminders = [[parseJson parseDataFromTable:YOUR_REMINDER_TABLE withStatus:@"normal"] retain];
    appDelegate.arrayYourReminders = [[NSMutableArray alloc] initWithArray:arrayReminders];
    arrayReminderByDeleveryDate = [[NSMutableArray alloc] initWithArray:[self sortReminderByDeleveryDate]];
    [parseJson release];
}


- (void)reloadData {
    if (appDelegate.arrayYourReminders != nil) {
        arrayReminders = [[NSMutableArray alloc] initWithArray:appDelegate.arrayYourReminders];
        keys = [[NSMutableArray alloc] initWithArray:appDelegate.keysYourReminder];
        dict = [[NSMutableDictionary alloc] initWithDictionary:appDelegate.dictYourReminder];
        NSLog(@"%d",[arrayReminders count]);
        if (appDelegate.showDetailFirst == YES && [arrayReminders count] > 0) {
            appDelegate.showDetailFirst = NO;

//            [self showDetailReminder];
            [self showAlertActionReminder];
        }
        indicator.hidden = YES;
    }
    else {
        ParseJSON *parseJson = [[ParseJSON alloc] init];
        if (arrayReminders != nil) {
            [arrayReminders release];
            arrayReminders = nil;
        }
        
        indicator.hidden = YES;
        arrayReminders = [[parseJson parseDataFromTable:YOUR_REMINDER_TABLE withStatus:@"normal"] retain];
        NSArray *arrayAllYourReminder = [parseJson parseDataFromTable:YOUR_REMINDER_TABLE withoutStatus:@"a"];
        
        if (appDelegate.arrayYourReminders != nil) {
            [appDelegate.arrayYourReminders release];
            appDelegate.arrayYourReminders = nil;
        }
        appDelegate.arrayYourReminders = [[NSMutableArray alloc] initWithArray:arrayReminders];
        
        //tranfer reminder from Upcoming Reminder to Your Reminder
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTable:UPCOMING_REMINDER_TABLE withoutStatus:@"aaa"]];
        NSLog(@"%d",[arr count]);
        for (int i = 0; i < [arr count]; i++) {
            
            double deliverydate = [[[arr objectAtIndex:i] objectForKey:@"deliverydate"] doubleValue];
            double now = (double)[[NSDate date] timeIntervalSince1970]*1000.0;
            
            if (deliverydate <= now) {
                [arrayReminders insertObject:[arr objectAtIndex:i] atIndex:0];
                
                RecordDao *recordD = [[RecordDao alloc] init];
                recordD.tableName = [[NSString alloc] initWithString:UPCOMING_REMINDER_TABLE];
                NSString *msgid = [NSString stringWithFormat:@"%@",[[arr objectAtIndex:i] objectForKey:@"deliverydate"]];
                NSInteger iD = [recordD getIndexOfARecordWithMsgid:msgid];
                [recordD deleteAtIndex:iD];
                [recordD release];
            }
        }
        
        if ([arrayAllYourReminder count] == 0 && [arrayReminders count] == 0) {
            [appDelegate.backgroundService getYourReminder];
            [appDelegate.backgroundService getSetUpReminder];
        }
        else {
            [self saveYourReminderToDatabase];
            [self sortReminderByDeleveryDate];
            
            if (appDelegate.showDetailFirst == YES && [arrayReminders count]>0) {
                appDelegate.showDetailFirst = NO;
//                [self showDetailReminder];
                [self showAlertActionReminder];
            }
            if ([arrayReminders count] == 0) {
                appDelegate.showDetailFirst = NO;
            }
        }
        indicator.hidden = YES;
        [arr release];
        [parseJson release];
    }
    if ([arrayReminders count] > 0) {
        appDelegate.showDetailFirst = NO;
    }
}

- (void)reloadTableView:(NSIndexPath*)indexPath {
    NSString *key = [keys objectAtIndex:indexPath.section];    
    [arrayReminders removeObject:[[dict objectForKey:key] objectAtIndex:indexPath.row]];
    NSLog(@"%d",[arrayReminders count]);
    
    appDelegate.arrayYourReminders = [NSMutableArray arrayWithArray:arrayReminders];
    
    [[dict objectForKey:key] removeObjectAtIndex:indexPath.row];
    [tableView reloadData];
}

- (void)reloadBanner {
    NSLog(@"%@",appDelegate.dictBanner);
    if(!appDelegate.isAirplaneModeSet)
    {
        [buttonBanner setImage:[UIImage imageNamed:@"YRmotivationMsg.png"] forState:UIControlStateNormal]; 
        if ([appDelegate.dictBanner count] == 0) {
            return;
        }
        labelBanner.text = [appDelegate.dictBanner objectForKey:@"textmessage"];
        NSLog(@"%@",[appDelegate.dictBanner objectForKey:@"bannermessage"]);
        buttonBanner.userInteractionEnabled = NO;
        if (![[appDelegate.dictBanner objectForKey:@"bannermessage"] isEqualToString:@""] && [appDelegate.dictBanner objectForKey:@"bannermessage"] != nil) {
            labelBanner.hidden = YES;
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[appDelegate.    dictBanner objectForKey:@"bannermessage"]]]];
            [buttonBanner setImage:image forState:UIControlStateNormal];
        }
        if (![[appDelegate.dictBanner objectForKey:@"link"] isEqualToString:@""] && [appDelegate.dictBanner objectForKey:@"link"] != nil) {
            buttonBanner.userInteractionEnabled = YES;
        }
    }
    else
    {
        labelBanner.text = @"Airplane Mode - Limited Functionality";
        [buttonBanner setImage:[UIImage imageNamed:@"YRmotivationMsg_airplanemode.png"] forState:UIControlStateNormal]; 
    }
}

- (IBAction)showMovitationView:(id)sender {
    BannerViewController *bannerViewController = [[BannerViewController alloc] init];
    bannerViewController.link = [[NSString alloc] initWithString:[appDelegate.dictBanner objectForKey:@"link"]];
    [self.navigationController pushViewController:bannerViewController animated:YES];
    [bannerViewController release];
}
#pragma mark Get request from server
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    NSLog(@"connection failed ----");
    finishLoading = YES;
    indicator.hidden = YES;
    keys = nil;
    dict = nil;
    [self reloadData];
    appDelegate.showDetailFirst = NO;
    appDelegate.isLoadingYourReminder = NO;
    
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest { 
    indicator.hidden = YES;
    appDelegate.theFirstShowYourReminder = NO;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    finishLoading = YES;
    appDelegate.isLoadingYourReminder = NO;
    SBJSON *parser = [SBJSON new];
    id dataDict = [parser objectWithString:responseData];
    
    [parser release];
    if ([[dataDict class] isSubclassOfClass:[NSArray class]]) {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"deliveryDate"
                                                      ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        arrayReminders = [[NSMutableArray alloc] initWithArray:[(NSArray *)dataDict sortedArrayUsingDescriptors:sortDescriptors]];
        
        
        appDelegate.arrayYourReminders = [[NSMutableArray alloc] initWithArray:arrayReminders];
        
        if (arrayReminderByDeleveryDate) {
            [arrayReminderByDeleveryDate release];
            arrayReminderByDeleveryDate = nil;
        }
        //[self sortReminderByDeleveryDate];
        arrayReminderByDeleveryDate = [[NSMutableArray alloc] initWithArray:[self sortReminderByDeleveryDate]];
        [tableView reloadData];
        
        
        [self saveYourReminderToDatabase];
        if (appDelegate.showDetailFirst == YES && [arrayReminders count]>0) {
            //NSIndexPath *ns = [[NSIndexPath alloc] initWithIndex:1];
            NSIndexPath *ns = [NSIndexPath indexPathForRow:0 inSection:0];
            ReminderDetailViewController *reminderDetailViewController = [[ReminderDetailViewController alloc] init];
            reminderDetailViewController.dictReminderDetail = [NSMutableDictionary dictionaryWithDictionary:[arrayReminders objectAtIndex:0]];
            reminderDetailViewController.selectIndexPath = ns;
            
            NSString *msgid = [NSString stringWithFormat:@"%@",[reminderDetailViewController.dictReminderDetail objectForKey:@"msgboxid"]];
            if ([msgid isEqualToString:@"0"]) {
                msgid = [NSString stringWithFormat:@"%@",[reminderDetailViewController.dictReminderDetail objectForKey:@"msgschedulerid"]];
            }
            
            reminderDetailViewController.iD = [recordDao getIndexOfARecordWithMsgid:msgid];
            
            //[self.navigationController pushViewController:reminderDetailViewController animated:YES];
            [reminderDetailViewController release];
            [responseData release];
            return;
        }
        else{
            //[self reloadData];
        }
    }
    [responseData release]; 
    appDelegate.showDetailFirst = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"configurationItem"]) {
    }
}

@end
