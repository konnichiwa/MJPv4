

#import "HistoryViewController.h"
#import "YourReminderCell.h"
#import "ReminderLogViewController.h"
#import "ParseJSON.h"
//#import "DownloadImage.h"
#import "ASIFormDataRequest.h"
#import "ReminderLogViewController.h"
#import "TermOfUseViewController.h"
#import "MoreOptionsViewController.h"
#import "ASIHTTPRequest.h"
#import "RestConnection.h"
#import "SBJSON.h"
#import "AppDelegate.h"
#import "ParseJSON.h"
#import "ASIHTTPRequest.h"
#import "BannerViewController.h"

// Private stuff
@interface HistoryViewController ()

- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;
@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"History";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
    [dataList release];
    [tableView release];
    [arrayDay release];
    [arrayReminders release];
    //[restConnection release];
    [indicator release];
    [bgView release];
    [arrayRestConnection release];
    //[downLoadImage release];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    theFirst = YES;
    [indicator startAnimating];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    buttonBanner.userInteractionEnabled = NO;
    [self reloadBanner];
    //restConnection = [[RestConnection alloc] init];
    arrayDateSelected = [[NSMutableArray alloc] init]; //new
    arrayDay = [[NSMutableArray alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];   
    NSDate *now = [NSDate date];
    for (int i = 31; i >= 0; i--) {
        if (i == 31) {
            [arrayDay addObject:[formatter stringFromDate:[now dateByAddingTimeInterval:(3600*24)]]];
        }
        else {
            if (i == 30) {
                [arrayDay addObject:[formatter stringFromDate:now]];
            }
            else {
                [arrayDay addObject:[formatter stringFromDate:[now dateByAddingTimeInterval:-(30-i)*(3600*24)]]];
            }
        }
    }
    
    for (int i = 0; i < [arrayDay count]/2; i++) {
        NSString *str = [arrayDay objectAtIndex:i];
        [arrayDay replaceObjectAtIndex:i withObject:[arrayDay objectAtIndex:31-i]];
        [arrayDay replaceObjectAtIndex:31-i withObject:str];
    }

    [formatter release];
    countDay = 30;
    
    /*if (appDelegate.theFirstShowHistory == YES) {
        //delete old file 
        NSLog(@"Delete old file");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSArray *historyDirectoryFile = [[NSFileManager defaultManager] directoryContentsAtPath:[cacheDirectory stringByAppendingString:@"/History"]];
        for (int i = 0; i < [historyDirectoryFile count]; i++) {
            if ([[historyDirectoryFile objectAtIndex:i] rangeOfString:@".txt"].location != NSNotFound) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[cacheDirectory stringByAppendingString:@"/History"],[historyDirectoryFile objectAtIndex:i]] error:nil];
            }
        }
        appDelegate.theFirstShowHistory = NO;
    }*/
    // Do any additional setup after loading the view from its nib.
    ParseJSON *parseJson = [[ParseJSON alloc] init];
    dataList = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTextFile:[NSString stringWithFormat:@"History/%@",[arrayDay objectAtIndex:countDay]]]];
    
    [arrayDateSelected addObject:[arrayDay objectAtIndex:countDay]];//new
    [parseJson release];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"deliverydate"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    dataList = [[NSMutableArray alloc] initWithArray:[(NSArray *)dataList sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self requestData];
    
    
    
    isLoading = YES;
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 33, 320, 66)];
    
    UILabel *labelNoRecord = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 20)];
    labelNoRecord.text = @"No Reminders Available";
    labelNoRecord.font = [UIFont boldSystemFontOfSize:18];
    labelNoRecord.textAlignment = UITextAlignmentCenter;
    labelNoRecord.backgroundColor = [UIColor clearColor];
    [bgView addSubview:labelNoRecord];
    [labelNoRecord release];
    bgView.hidden = NO;
    [tableView addSubview:bgView];
    
    
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
#pragma mark UITableViewDelegate, UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([dataList count]!=0) {//hide no record label
        bgView.hidden = YES;
    }
    else{//show no record label
        bgView.hidden = NO;
    }
    return [dataList count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 33)];
    
    UIImageView *imageViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 33)];
    imageViewBG.image = [UIImage imageNamed:@"titleHistoryBG.png"];
    [viewTitle addSubview:imageViewBG];
    [imageViewBG release];
    
    UIButton *buttonNext = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNext.frame = CGRectMake(270, 0, 50, 30);
    [buttonNext addTarget:self action:@selector(nextDay) forControlEvents:UIControlEventTouchUpInside];
    [viewTitle addSubview:buttonNext];
    
    UIButton *buttonPrevious = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonPrevious.frame = CGRectMake(10, 0, 50, 30);
    [buttonPrevious addTarget:self action:@selector(previousDay) forControlEvents:UIControlEventTouchUpInside];
    [viewTitle addSubview:buttonPrevious];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 2, 220, 30)];
    NSString *a = [arrayDay objectAtIndex:countDay];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:[a componentsSeparatedByString:@","]];
    [mutableArr removeObjectAtIndex:0];
    switch (countDay) {
        case 31:
            labelTitle.text = [NSString stringWithFormat:@"Tomorrow, %@", [mutableArr componentsJoinedByString:@","]];
            break;
        case 30:
            labelTitle.text = [NSString stringWithFormat:@"Today, %@", [mutableArr componentsJoinedByString:@","]];            break;
        case 29:
            labelTitle.text = [NSString stringWithFormat:@"Yesterday, %@", [mutableArr componentsJoinedByString:@","]];
            break;
        default:
            labelTitle.text = [arrayDay objectAtIndex:countDay];
            break;
    }
    [mutableArr release];
    [labelTitle setTextAlignment:UITextAlignmentCenter];
    labelTitle.font = [UIFont boldSystemFontOfSize:14];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.backgroundColor = [UIColor clearColor];
    [viewTitle addSubview:labelTitle];
    [labelTitle release];
    
    return [viewTitle autorelease];
}

#pragma mark
#pragma mark table view cell for row
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
    
    NSString *strStatus = [[dataList objectAtIndex:indexPath.row] objectForKey:@"systemstatus"];
    strStatus = [[strStatus lowercaseString] capitalizedString];
    if ([[[dataList objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"System Custom Reminder"] || [[[dataList objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"System Precanned Reminder"]) {
        cell.labelName.text = @"Message";
    }
    
        //detect Medication Reminder
    
    cell.labelDate.text = [self convertDateFromFloatString2:[[dataList objectAtIndex:indexPath.row] objectForKey:@"deliverydate"] toDateStype:YES withTimeZone:[[dataList objectAtIndex:indexPath.row] objectForKey:@"timeZone"]];
    //cell.labelTime.text = [NSString stringWithFormat:@" %@",[self convertDateFromFloatString:[[dataList objectAtIndex:indexPath.row] objectForKey:@"deliverydate"] toDateStype:NO withTimeZone:[[dataList objectAtIndex:indexPath.row] objectForKey:@"timeZone"]]];
    
    //H's test
    cell.labelTime.text = [NSString stringWithFormat:@" %@",[self convertDateFromFloatString:[appDelegate getProperty:@"Time taken" forData:[dataList objectAtIndex:indexPath.row]] toDateStype:NO withTimeZone:[[dataList objectAtIndex:indexPath.row] objectForKey:@"timeZone"]]];
    
    NSLog(@"time taken %@",[appDelegate getProperty:@"Time Taken" forData:[dataList objectAtIndex:indexPath.row]]);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:sszzz"];
    NSDate *date = [formatter dateFromString:[appDelegate getProperty:@"Time Taken" forData:[dataList objectAtIndex:indexPath.row]]];
    
    //NSLog(@"current date %@ and after %@ ",[appDelegate getProperty:@"Time Taken" forData:[dataList objectAtIndex:indexPath.row]],date);
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    cell.labelTime.text = [formatter stringFromDate:date];
    
    if (cell.labelTime.text == nil) {
        cell.labelTime.text = @"";
    }
    if ([[[dataList objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"]) {
        //medication reminder
        cell.labelName.text = [NSString stringWithFormat:@"%@ %@",strStatus, [appDelegate getProperty:@"Medication Name" forData:[dataList objectAtIndex:indexPath.row]]] ;
        cell.clockIcon.hidden = YES;
        if ([strStatus isEqualToString:@"Skipped"]) {
            cell.labelTime.text = [NSString stringWithFormat:@"%@ due to %@", strStatus,
                                   [appDelegate getProperty:@"Skipped Reason" forData:[dataList objectAtIndex:indexPath.row]]
                                   ];
        }
        else{
            if ([strStatus isEqualToString:@"Complete"]) {
                cell.labelName.text = [NSString stringWithFormat:@"Took %@", [appDelegate getProperty:@"Medication Name" forData:[dataList objectAtIndex:indexPath.row]]] ;
            }
            else
                cell.labelName.text = [NSString stringWithFormat:@"%@ %@",strStatus,[[dataList objectAtIndex:indexPath.row] objectForKey:@"reminderName"]];
            cell.labelTime.text = [NSString stringWithFormat:@"Took @%@",cell.labelTime.text];
        }
        
        [cell.labelTime setFrame:CGRectMake(69, 33, 201, 21)];
         //cell.labelTime.text = [NSString stringWithFormat:@"@Took %@",cell.labelTime.text];
    }
    else{
        //label time 
        cell.clockIcon.hidden = NO;
        [cell.labelTime setFrame:CGRectMake(91, 28, 192, 21)];
        //refill and other type reminder.
        cell.labelName.text =[[dataList objectAtIndex:indexPath.row] objectForKey:@"reminderName"];
        //NSString *timeRefill  =[formatter stringFromDate:[formatter dateFromString:[[dataList objectAtIndex:indexPath.row] objectForKey:@"deliverydate"]]];
         cell.labelTime.text = [NSString stringWithFormat:@"%@%@",[strStatus uppercaseString],[NSString stringWithFormat:@" %@",[self convertDateFromFloatString:[[dataList objectAtIndex:indexPath.row] objectForKey:@"deliverydate"] toDateStype:NO withTimeZone:[[dataList objectAtIndex:indexPath.row] objectForKey:@"timeZone"]]]];
    }
    [formatter release];
    cell.imageViewIcon.image = [UIImage imageNamed:[[dataList objectAtIndex:indexPath.row] objectForKey:@"reminderName"]];
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ReminderLogViewController *reminderLogViewController = [[ReminderLogViewController alloc] init];
    NSDictionary *aReminder = [[NSDictionary alloc] initWithDictionary:[dataList objectAtIndex:indexPath.row]];
    NSLog(@"%@",aReminder);
    
    reminderLogViewController.dictReminderDetail = aReminder;
    [aReminder release];
    [self.navigationController pushViewController:reminderLogViewController animated:YES];
    [reminderLogViewController release];
}


- (IBAction)pressTermOfUse:(id)sender{
    if(!appDelegate.isAirplaneModeSet)
    {
        TermOfUseViewController *t = [[TermOfUseViewController alloc] init];
        [self.navigationController pushViewController:t animated:YES];
        [t release]; 
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:NOT_AVAIL_OFFLINE_MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)pressMoreOptions:(id)sender{
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

- (IBAction)pressHome:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark
#pragma reload table
- (void) reloadTable{
    
}
#pragma mark -
#pragma mark action
- (void)nextDay {
    /*if (isLoading == YES) {
        return;
    }*/
    //if (!isLoading) {
        countDay++;
        if (countDay == 32) {
            countDay =  31;
            return;
        }
        if (dataList != nil) {
            [dataList release];
            dataList = nil;
        }
        
        ParseJSON *parseJson = [[ParseJSON alloc] init];
        [dataList release];
        dataList = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTextFile:[NSString stringWithFormat:@"/History/%@",[[arrayDay objectAtIndex:countDay] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]]];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"deliverydate"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    dataList = [[NSMutableArray alloc] initWithArray:[(NSArray *)dataList sortedArrayUsingDescriptors:sortDescriptors]];
        [parseJson release];        
    [tableView reloadData];
        
        NSString *startDate = [arrayDay objectAtIndex:countDay];
        BOOL had = NO;
        for (int i = 0; i < [arrayDateSelected count]; i++) {
            if ([[arrayDateSelected objectAtIndex:i] isEqualToString:startDate]) {
                had = YES;
                break;
            }
        }
        
        if (!had) {
            [arrayDateSelected addObject:startDate];
            indicator.hidden = NO;
            [self requestData]; 
            /*if ([dataList count] == 0) {
               [self requestData]; 
            }  
            else {
                indicator.hidden = YES;
            }*/
        }
    //}
}

- (void)previousDay {
    /*if (isLoading == YES) {
        return;
    }*/
    //if (!isLoading) {
        countDay--;
        if (countDay == -1) {
            countDay = 31;
        }
        if (dataList != nil) {
            [dataList release];
            dataList = nil;
        }
        
        ParseJSON *parseJson = [[ParseJSON alloc] init];
        [dataList release];
        dataList = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTextFile:[NSString stringWithFormat:@"/History/%@",[[arrayDay objectAtIndex:countDay] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]]];
        [parseJson release];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"deliverydate"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    dataList = [[NSMutableArray alloc] initWithArray:[(NSArray *)dataList sortedArrayUsingDescriptors:sortDescriptors]];
        [tableView reloadData];
        
        NSString *startDate = [arrayDay objectAtIndex:countDay];
        BOOL had = NO;
        for (int i = 0; i < [arrayDateSelected count]; i++) {
            if ([[arrayDateSelected objectAtIndex:i] isEqualToString:startDate]) {
                had = YES;
                break;
            }
        }
        
        if (!had) {
            [arrayDateSelected addObject:startDate];
            indicator.hidden = NO;
            [self requestData];
            /*if ([dataList count] == 0) {
                [self requestData]; 
            }  
            else {
                indicator.hidden = YES;
            }*/
        }
    //}
}
- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone {
    NSString *dateString;
    //NSLog(@"%@",floatString);
    double deliveryDate = [floatString doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (date) {
        [formatter setDateStyle:NSDateFormatterFullStyle];   
    }
    else {
        [formatter setTimeStyle:NSDateFormatterShortStyle];   
    }
    dateString = [[NSString alloc] initWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)((double)deliveryDate/(double)1000)]]];
    [formatter release];
    return [dateString autorelease];
}

- (NSString*)convertDateFromFloatString2:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone {
    NSString *dateString;    double deliveryDate = [floatString doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (date) {
        [formatter setDateStyle:NSDateFormatterLongStyle];   
    }
    else {
        [formatter setTimeStyle:NSDateFormatterShortStyle];   
    }
    dateString = [[NSString alloc] initWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)((double)deliveryDate/(double)1000)]]];
    [formatter release];
    return [dateString autorelease];
}

- (void)sortReminderByDeleveryDate {
    if (dict != nil) {
        [dict release];
        [keys release];
        dict = nil;
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
    
    NSLog(@"%@",dict);
}

- (NSMutableArray*)findDataForTableView:(NSString*)date {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[dict objectForKey:date]];
    return [arr autorelease];
}

- (void)requestData {
    if (appDelegate.deviceToken != nil) {
        isLoading = YES;
        indicator.hidden = NO;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        startdate = [[formatter dateFromString:[arrayDay objectAtIndex:countDay]] timeIntervalSince1970];
        [formatter release];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"deliverydate" forKey:@"sortfield"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"desc" forKey:@"sortorder"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%13.0f",startdate*1000] forKey:@"startdate"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%13.0f",(startdate+3600*24-1)*1000] forKey:@"enddate"]];
        
        
        /*restConnection.viewController = self;
         [restConnection getDataWithPathSource:@"/rest/msgb/history" andParam:arr forService:@"history"];*/
        
        RestConnection *rest = [[RestConnection alloc] init];
        rest.viewController = self;
        //rest.tag = countDay;
        [rest getDataWithPathSource:@"/rest/msgb/history" andParam:arr forService:@"history"];
        rest.request.tag = countDay;
        [arrayRestConnection addObject:rest];
        
        [arr release];
    }
    else {
        indicator.hidden = YES;
        if (theFirst) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            theFirst = NO;
        }
    }
}

#pragma mark -
#pragma mark asihttprequest 
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    isLoading = NO;
    if (theRequest.tag == countDay) {
        indicator.hidden = YES;
    }
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseData);
    [responseData release];
    keys = nil;
    dict = nil;
    [tableView reloadData];
    if (theFirst) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        [alert release];
        theFirst = NO;
    }
    
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    isLoading = NO;
    if (theRequest.tag == countDay) {
    indicator.hidden = YES;
    }
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    SBJSON *parser = [SBJSON new];
    id dataDict = [parser objectWithString:responseData];
    [parser release];
    
    if ([responseData isEqualToString:@"{\"ID\" : \"2002\" , \"Description\" : \"Authentication failed \" }"]) {
        [appDelegate showLoginViewWhenAuthenFailed];
    } 
    [responseData release];
    if ([[dataDict class] isSubclassOfClass:[NSArray class]]) {
        if (arrayReminders != nil) {
            [arrayReminders release];
        }
        arrayReminders = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
        [self sortReminderByDeleveryDate];
        
        NSLog(@"%d",[dataList count]);
        NSLog(@"%d",[arrayReminders count]);
        if (theRequest.tag == countDay) {
            if ([dataList count] > 0) {
                for (int i = 0; i < [arrayReminders count]; i++) {
                    NSDictionary *aDict = [arrayReminders objectAtIndex:i];
                    BOOL have = NO;
                    for (int j= 0; j < [dataList count]; j++) {
                        NSLog(@"%@",[dataList objectAtIndex:j]);
                        NSString *str1 = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"msgboxid"]];
                        NSString *str2 = [NSString stringWithFormat:@"%@",[[dataList objectAtIndex:j] objectForKey:@"msgboxid"]];
                        
                        NSString *str3 = [NSString stringWithFormat:@"%@",[aDict objectForKey:@"msgschedulerid"]];
                        NSString *str4 = [NSString stringWithFormat:@"%@",[[dataList objectAtIndex:j] objectForKey:@"msgschedulerid"]];
                        
                        
                        if ([str1 isEqualToString:str2] || [str3 isEqualToString:str4]) {
                            have = YES;
                            break;
                        }
                    }
                    
                    if (!have) {
                        [dataList addObject:aDict];
                    }
                }
            }
            else {
                dataList = [[NSMutableArray alloc] initWithArray:arrayReminders];
            }
            
            NSLog(@"%d",[dataList count]);
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"deliverydate"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            dataList = [[NSMutableArray alloc] initWithArray:[(NSArray *)dataList sortedArrayUsingDescriptors:sortDescriptors]];
             NSLog(@"%d",[dataList count]);
            [tableView reloadData];
        }
        
        // write data to text file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *filePath = [cacheDirectory stringByAppendingString:[NSString stringWithFormat:@"/History/%@.txt",[[arrayDay objectAtIndex:theRequest.tag] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        SBJSON *json = [SBJSON new];
        NSString *str = [json stringWithObject:dataList error:nil];
        //[[appDelegate doCipher:str :kCCEncrypt] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [json release];
    }
    else{
        [tableView reloadData];
    }
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


@end
