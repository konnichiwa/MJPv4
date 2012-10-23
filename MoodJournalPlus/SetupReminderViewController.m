

#import <QuartzCore/QuartzCore.h>
#import "SetupReminderViewController.h"
#import "SetupReminderCell.h"
#import "AddReminderTypeView.h"
#import "SetupAReminderViewController.h"
#import "YourReminderViewController.h"
#import "ParseJSON.h"
//#import "DownloadImage.h"
#import "ASIHTTPRequest.h"
#import "TermOfUseViewController.h"
#import "RestConnection.h"
#import "SBJSON.h"
#import "AppDelegate.h"
#import "BackgroundService.h"



// Private stuff
@interface SetupReminderViewController ()
- (void)imageFetchComplete:(ASIHTTPRequest *)request;
- (void)imageFetchFailed:(ASIHTTPRequest *)request;
- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;
@end


@implementation SetupReminderViewController
@synthesize isShowAddReminderTypeView;
@synthesize tableView;
@synthesize bottomAction;
@synthesize termOfUse;
@synthesize isDeleteCell;
#pragma mark -
#pragma mark action
- (IBAction)toggleEdit:(id)sender{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
	if (self.tableView.editing){
        isDeleteCell = YES;
        [bottomAction setTitle:@"Done" forState:UIControlStateNormal];
    }
    
	else{
        isDeleteCell = NO;
        [bottomAction setTitle:@"Delete..." forState:UIControlStateNormal];
    }
    [tableView reloadData];
    
}

- (IBAction)pressTermOfUse{//show term of use
    if(!appDelegate.isAirplaneModeSet)
    {
        TermOfUseViewController *viewController = [[TermOfUseViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:NOT_AVAIL_OFFLINE_MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
- (void)saveSetupReminderToDatabase {
    if (arrayReminders != nil) {
        [arrayReminders release];
    }
    arrayReminders = [[NSMutableArray alloc] initWithArray:appDelegate.arraySetupReminders];
    
    [recordDao deleteNormalRecord];
    
    for (int i = 0; i < [arrayReminders count]; i++) {
        SBJSON *json = [SBJSON new];
        NSString *str = [json stringWithObject:[arrayReminders objectAtIndex:i] error:nil];
        NSString *msgid = [NSString stringWithFormat:@"%@",[[arrayReminders objectAtIndex:i] objectForKey:@"msgschedulerid"]];
        //[recordDao insertWithContent:[appDelegate doCipher:str :kCCEncrypt] WithStatus:@"normal" WithMsgid:msgid];
        [recordDao insertWithContent:str WithStatus:@"normal" WithMsgid:msgid];
    }
    
    [self reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    recordDao = [[RecordDao alloc] init];
    recordDao.tableName = [[NSString alloc] initWithString:SETUP_REMINDER_TABLE];
    indicator.hidden = YES;
    [indicator startAnimating];
    
    
    if (appDelegate.arraySetupReminders != nil || [appDelegate.arraySetupReminders count] != 0) {
        arrayReminders = [[NSMutableArray alloc] initWithArray:appDelegate.arraySetupReminders];
    }
    else {
        [self reloadData];
    }
    
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 66)];
    UILabel *labelNoRecord = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 20)];
    labelNoRecord.text = @"No Reminders Available";
    labelNoRecord.font = [UIFont boldSystemFontOfSize:18];
    labelNoRecord.textAlignment = UITextAlignmentCenter;
    labelNoRecord.backgroundColor = [UIColor clearColor];
    [bgView addSubview:labelNoRecord];
    [labelNoRecord release];
    [tableView addSubview:bgView];
    bgView.hidden = NO;
    //[self reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData2) name:@"reloadSetUpReminder" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewWillDisappear:(BOOL)animated{
    isDeleteCell = NO;
    //[tableView reloadData];
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    
    if (isShowAddReminderTypeView) {
        [addReminderTypeView removeFromSuperview];
        isShowAddReminderTypeView = NO;
        self.navigationItem.leftBarButtonItem = nil;
    }
    [super viewWillAppear:animated]; 
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    //[self reloadData];
    if (appDelegate.theFirstShowSetupReminder) {
        [self loadData];
        appDelegate.theFirstShowSetupReminder = NO;
    }
    else {
        indicator.hidden = YES;
        
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Set Up Reminder";
        
        //Add button
        UIBarButtonItem *buttonAdd = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addNewReminder)];
        self.navigationItem.rightBarButtonItem = buttonAdd;
        [buttonAdd release];
        
        //back button
        self.navigationItem.backBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                          style:UIBarButtonItemStyleBordered
                                         target:nil
                                         action:nil] autorelease];
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
    //[downLoadImage release];
    [tableView release];
    [imageViewAmoundReminderBG release];
    [arrayReminders release];
    [arrayReminderByDeleveryDate release];
    [dictAReminder release];
    [indicator release];
    [restConnection release];
    [bgView release];
    [recordDao release];
    
}

#pragma mark -
#pragma mark action
- (void)loadData {
    if (appDelegate.deviceToken != nil) {
        indicator.hidden = NO;
        [indicator startAnimating];
        index = 0;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        
        restConnection = [[RestConnection alloc] init];
        restConnection.viewController = self;
        [restConnection getDataWithPathSource:@"/rest/Reminders" andParam:arr forService:@"setUpReminders"];
        [arr release];
    }
    else {
        indicator.hidden = YES;
    }
}

- (void)reloadData2 {
    if (arrayReminders != nil) {
        [arrayReminders release];
    }
    arrayReminders = [[NSMutableArray alloc] initWithArray:appDelegate.arraySetupReminders];
    [tableView reloadData];
}

- (void)reloadData {
    selectedIndex = -1;
    ParseJSON *parseJson = [[ParseJSON alloc] init];
    [arrayReminders release];
    arrayReminders = [[parseJson parseDataFromTable:SETUP_REMINDER_TABLE withoutStatus:@"Delete"] retain];
    [parseJson release];
    appDelegate.arraySetupReminders = [[NSMutableArray alloc] initWithArray:arrayReminders];
    
    if (isShowAddReminderTypeView) {
        [addReminderTypeView removeFromSuperview];
        isShowAddReminderTypeView = NO;
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)addNewReminder {
    if (!isShowAddReminderTypeView) {
        isShowAddReminderTypeView = YES;
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"AddReminderTypeView"
                                                          owner:self
                                                        options:nil];
        
        addReminderTypeView = [[nibViews objectAtIndex:0] retain];
        [self.view addSubview:addReminderTypeView];
        addReminderTypeView.delegate = self;	
        // set up an animation for the transition between the views
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromTop];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [[addReminderTypeView layer] addAnimation:animation forKey:@"SwitchToView1"];
        
        UIBarButtonItem *buttonAdd = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissAddReminderView)];
        self.navigationItem.leftBarButtonItem = buttonAdd;
        [buttonAdd release];   
    }
}

- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone {
    NSString *dateString;
    double deliveryDate = [floatString doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (date) {
        [formatter setDateStyle:NSDateFormatterFullStyle];   
    }
    else {
        [formatter setTimeStyle:NSDateFormatterShortStyle];   
    }
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
    dateString = [[NSString alloc] initWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)(deliveryDate/1000)]]];
    [formatter release];
    return [dateString autorelease];
}

- (void)dismissAddReminderView {
    isShowAddReminderTypeView = NO;
    [addReminderTypeView setFrame:CGRectMake(480, 320, 320, 460)];
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	
	[[addReminderTypeView  layer] addAnimation:animation forKey:kCATransition];
    self.navigationItem.leftBarButtonItem = nil;
    [addReminderTypeView release];
}

- (IBAction)pressHome{
    //[self.navigationController setViewControllers:nil];
    //YourReminderViewController *y = [[YourReminderViewController alloc] initWithNibName:@"YourReminderView" bundle:nil];
    //[self.navigationController pushViewController:y animated:YES];
    ///[y release];
    
    NSArray *arr = [self.navigationController viewControllers];
    if (appDelegate.isFirstSignUp) {
        appDelegate.isFirstSignUp = NO;
        appDelegate.isSecondSignUp = YES;
        YourReminderViewController *yourReminder = [[YourReminderViewController alloc] init];
        [self.navigationController pushViewController:yourReminder animated:YES];
        [yourReminder release];
    }
    else {
        if (appDelegate.isSecondSignUp) {
            for (int i = 0; i < [arr count]; i++) {
                if ([[arr objectAtIndex:i] isKindOfClass:[YourReminderViewController class]]) {
                    [self.navigationController popToViewController:[arr objectAtIndex:i] animated:YES];
                    return;
                }
            }
        }
        else {
            //[self.navigationController popToViewController:[arr objectAtIndex:1] animated:YES];
            for (int i = 0; i < [arr count]; i++) {
                if ([[arr objectAtIndex:i] isKindOfClass:[YourReminderViewController class]]) {
                    [self.navigationController popToViewController:[arr objectAtIndex:i] animated:YES];
                    return;
                }
            }
        }
    }
}
- (IBAction)pressAdd:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
        {
            [self selectRemiderType:kMedication];
            break;
        }
        case 2:
        {
            [self selectRemiderType:kPrescriptionFill];
            break;
        }
        default:
            viewAddReminder.hidden = YES;
            break;
    }
}
- (IBAction)showAddForm:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@" " delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Medication",@"Prescription Refill", nil];
    
    
    //CGRect oldFrame = [(UILabel*)[[actionSheet subviews] objectAtIndex:0] frame];
    CGRect oldFrame = CGRectMake(0, 0, 320, 50);
    UILabel *newTitle = [[[UILabel alloc] initWithFrame:oldFrame] autorelease];
    newTitle.font = [UIFont boldSystemFontOfSize:22];
    newTitle.textAlignment = UITextAlignmentCenter;
    newTitle.backgroundColor = [UIColor clearColor];
    newTitle.textColor = [UIColor whiteColor];
    newTitle.text = @"Add Reminder"; 
    [actionSheet addSubview:newTitle];
    [actionSheet showInView:self.view];
    
    [actionSheet release];
}


#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            [self selectRemiderType:kMedication];
            break;
        }
        case 1:
        {
            [self selectRemiderType:kPrescriptionFill];
            break;
        }
        default:
            break;
    }
}

- (IBAction)changeReminderStatus:(id)sender {
    if (appDelegate.deviceToken != nil) {
        indicator.hidden = NO;
        UISwitch *switchView = (UISwitch*)sender;
        selectedIndex = [switchView tag];
        NSMutableDictionary *aReminder = [arrayReminders objectAtIndex:selectedIndex];
        SBJSON *json = [SBJSON new];
        NSString *postData;
        
        NSString *msgid = [NSString stringWithFormat:@"%@",[aReminder objectForKey:@"msgschedulerid"]];
        iD = [recordDao getIndexOfARecordWithMsgid:msgid];
        
        if (!switchView.on) {
            [aReminder setObject:@"Inactive" forKey:@"status"];
            postData = [json stringWithObject:aReminder];
            //[recordDao updateAtIndex:iD Content:[appDelegate doCipher:postData :kCCEncrypt] Status:@"Inactive"];
            active = NO;
        }
        else {
            [aReminder setObject:@"Active" forKey:@"status"];
            postData = [json stringWithObject:aReminder];
            //[recordDao updateAtIndex:iD Content:[appDelegate doCipher:postData :kCCEncrypt] Status:@"Active"];
            active = YES;
        }
        
        [arrayReminders replaceObjectAtIndex:selectedIndex withObject:aReminder];
        [appDelegate.arraySetupReminders release];
        appDelegate.arraySetupReminders = [[NSMutableArray alloc] initWithArray:arrayReminders];
        
        index = 1;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        restConnection = [[RestConnection alloc] init];
        restConnection.viewController = self;
        [restConnection putDataWithPathSource:@"/rest/Reminders" andParam:arr withPostData:postData];
        [json release];
        [arr release];
    }
    else {
        indicator.hidden = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [tableView reloadData];
    }
}

- (void)writeDataToTextFile {
    // write data to text file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingString:@"/SetupReminder.txt"];
    SBJSON *json = [SBJSON new];
    NSString *str = [json stringWithObject:arrayReminders error:nil];
    //[[appDelegate doCipher:str :kCCEncrypt] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [json release];
}



#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([arrayReminders count] == 0) {
        bgView.hidden = NO;
    }
    else {
        bgView.hidden = YES;
    }
    return [arrayReminders count];
}

- (UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *indentifier = @"SetupReminderCell";
    
    SetupReminderCell *cell = (SetupReminderCell *)[tableView dequeueReusableCellWithIdentifier: indentifier];
    if (cell == nil)  {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" 
                                                     owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SetupReminderCell class]])
                cell = (SetupReminderCell *)oneObject;
        
        //h: set color background view and switch button
        //cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reminderDetailBG.png"]] autorelease];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        if ([cell.switchActive respondsToSelector:@selector(onTintColor)]) {
            cell.switchActive.onTintColor = [UIColor colorWithRed:236.0f/255.0f 
                                                            green:157.0f/255.0f 
                                                             blue:86.0f/255.0f 
                                                            alpha:1.0f];
        }
        
        //end h
	}
    
    cell.switchActive.hidden = NO;
    cell.switchActive.tag = indexPath.row;
    [cell.switchActive addTarget:self action:@selector(changeReminderStatus:) forControlEvents:UIControlEventValueChanged];
    if ([[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"status"] isEqualToString:@"Active"]) {
        [cell.switchActive setOn:YES];
    }
    else {
        [cell.switchActive setOn:NO];
    }//end 1402
    
    
    //cell.labelName.text = [[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"reminderName"];
    if ([[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"]) {
        cell.labelName.text = [NSString stringWithFormat:@"Take %@",[self getProperty:@"Medication Name" forData:[arrayReminders objectAtIndex:indexPath.row]]] ;
    }
    else{
        cell.labelName.text = [NSString stringWithFormat:@"Refill %@",[self getProperty:@"Medication Name" forData:[arrayReminders objectAtIndex:indexPath.row]]] ;
    }
    
    cell.labelDate.text = [[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"frequency"];
    /*if ([[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"]) {
     cell.labelDate.hidden = YES;
     [cell.labelName setFrame:CGRectMake(71, 8, 245, 23)];
     [cell.labelTime setFrame:CGRectMake(71, 33, 150, 21)];
     
     }
     else {
     cell.labelDate.hidden = NO;
     [cell.labelName setFrame:CGRectMake(71, 1, 245, 23)];
     [cell.labelTime setFrame:CGRectMake(71, 38, 150, 21)];
     NSString *date = [self convertDateFromFloatString:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"startdate"] toDateStype:YES withTimeZone:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"timezone"]];
     cell.labelDate.text = [date stringByReplacingOccurrencesOfString:[[date componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""];
     }*/
    
    cell.labelTime.text = [[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"remindertime"];
    //cell.imageView.image = [UIImage imageWithContentsOfFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"reminderIcon"] componentsSeparatedByString:@"/"] lastObject]]];
    cell.imageView.image = [UIImage imageNamed:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"reminderName"]];
    if (isDeleteCell == YES) {
        cell.switchActive.hidden = YES;
    }
    else
    {
        cell.switchActive.hidden = NO;
    }
	return cell;
}
- (NSString *)getProperty: (NSString *)key forData: (NSDictionary *)dataList{
    NSArray *properties;
    NSString *value=@"";
    properties = [dataList objectForKey:@"properties"];
    for (int i = 0; i <[properties count]; i++) {
        //NSLog(@"data %d la %@ for key %@",i,[properties objectAtIndex:i], key);
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:key] &&[[properties objectAtIndex:i] objectForKey:@"propertyvalue"]!=nil&& ![[[properties objectAtIndex:i] objectForKey:@"propertyvalue"] isKindOfClass:[NSNull class]]) {
            value = [NSString stringWithString:[[properties objectAtIndex:i] objectForKey:@"propertyvalue"]];
            break;
        }
    }
    return value;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    indicator.hidden = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SetupAReminderViewController *setUpAReminderViewController = [[SetupAReminderViewController alloc] init];
    setUpAReminderViewController.dictReminderDetail = [NSMutableDictionary dictionaryWithDictionary:[arrayReminders objectAtIndex:indexPath.row]];
    
    NSString *msgid = [NSString stringWithFormat:@"%@",[setUpAReminderViewController.dictReminderDetail objectForKey:@"msgschedulerid"]];
    setUpAReminderViewController.iD = [recordDao getIndexOfARecordWithMsgid:msgid];
    
    setUpAReminderViewController.isUpdateReminder = YES;
    setUpAReminderViewController.currentEditIndex = indexPath;
    if ([[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"]) {
        setUpAReminderViewController.reminderType = kMedication;
        NSMutableDictionary *n = [[NSMutableDictionary alloc] init];
        
        [n setObject:[self getProperty:@"Medication Name" forData:[arrayReminders objectAtIndex:indexPath.row]] forKey:@"Med"];
        
        [n setObject:[self getProperty:@"Medication Image" forData:[arrayReminders objectAtIndex:indexPath.row]] forKey:@"Image"];
        appDelegate.medicationImageLink = [n objectForKey:@"Image"];
        
        if ([[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"frequency"]) {
            if ([[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"frequency"]isEqualToString:@"1 days"] ) {
                [n setObject:@"every 1 day(s)" forKey:@"Fre"];
                setUpAReminderViewController.allowMultipleTimePerDay = NO;
            }
            else if ([[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"frequency"]isEqualToString:@"1 months"] ) {
                [n setObject:@"every 1 month(s)" forKey:@"Fre"];
                setUpAReminderViewController.allowMultipleTimePerDay = NO;
            }
            else
                if ([[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"frequency"]isEqualToString:@"1 hours"] ) {
                    [n setObject:@"every 1 hour(s)" forKey:@"Fre"];
                    setUpAReminderViewController.allowMultipleTimePerDay = NO;
                }
                else{
                    [n setObject:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"frequency"] forKey:@"Fre"];
                }
            
        }
        else
        {
            [n setObject:@"" forKey:@"Fre"];
        }
        
        if ([[n objectForKey:@"Fre"] rangeOfString:@"day"].location==NSNotFound
            &&[[n objectForKey:@"Fre"] rangeOfString:@"year"].location==NSNotFound
            &&[[n objectForKey:@"Fre"] rangeOfString:@"month"].location==NSNotFound
            )
        {      
            //NSLog(@"Substring Not Found");
        }
        else
        {
            setUpAReminderViewController.allowMultipleTimePerDay = NO;
            //NSLog(@"Substring Found Successfully");
        }
        
        if ([[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"remindertime"] ) {
            if ([[n objectForKey:@"Fre"] isEqualToString:@"Daily"]) {
                NSArray *array = [[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"remindertime"] componentsSeparatedByString:@","];
                [n setObject:[NSString stringWithFormat:@"%dx Per Day", [array count]] forKey:@"TPD"];
            }
            else{
                [n setObject:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"remindertime"] forKey:@"TPD"];
            }
            
        }
        else
        {
            [n setObject:@"" forKey:@"TPD"];
        }
        if ([[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"startdate"] ) {
            double deliveryDate = [[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"startdate"] doubleValue];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterFullStyle];  
            NSString *dateString = [NSString stringWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)(deliveryDate/1000)]]];
            
            [n setObject:[dateString stringByReplacingOccurrencesOfString:[[dateString componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""] forKey:@"Start"];
            [formatter release];
            
            //[n setObject:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"startdate"] forKey:@"Start"];
        }
        else
        {
            [n setObject:@"" forKey:@"Start"];
        }
        if ([[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"enddate"] ) {
            //[n setObject:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"enddate"] forKey:@"End"];
            double deliveryDate = [[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"enddate"] doubleValue];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterFullStyle];  
            NSString *dateString = [NSString stringWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)(deliveryDate/1000)]]];
            [n setObject:[dateString stringByReplacingOccurrencesOfString:[[dateString componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""] forKey:@"End"];
            [formatter release];
            
        }
        else
        {
            [n setObject:@"" forKey:@"End"];
        }
        
        setUpAReminderViewController.dictParamValueReminder = n;
        [n release];
        
        
    }
    /* choose refill reminder */
    if ([[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"reminderName"] isEqualToString:@"Refill Reminder"]) {
        
        setUpAReminderViewController.reminderType = kPrescriptionFill;
        NSMutableDictionary *n = [[NSMutableDictionary alloc] init];
        //refill reminder
        [n setObject:[self getProperty:@"Medication Name" forData:[arrayReminders objectAtIndex:indexPath.row]] forKey:@"Med"];
        if ([[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"remindertime"] ) {
            [n setObject:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"remindertime"] forKey:@"Time"];
        }else{
            [n setObject:@"" forKey:@"Time"];
        }
        
        if ([[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"startdate"] ) {            double deliveryDate = [[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"startdate"] doubleValue];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterFullStyle];  
            NSString *dateString = [NSString stringWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)(deliveryDate/1000)]]];
            dateString = [dateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            [n setObject:[[dateString stringByReplacingOccurrencesOfString:[[dateString componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"Date"];
            
            [formatter release];
        }else
        {
            [n setObject:@"" forKey:@"Date"];
        }
        
        [n setObject:@"" forKey:@"Fre"];
        setUpAReminderViewController.dictParamValueReminder = n;
        [n release];
        
    }
    
    [self.navigationController pushViewController:setUpAReminderViewController animated:YES];
    [setUpAReminderViewController release];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

/*
 - (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 isDeleteCell = YES;
 [arrayReminders removeObjectAtIndex:indexPath.row];
 [tableView reloadData];
 SetupReminderCell *cell = (SetupReminderCell*)[aTableView cellForRowAtIndexPath:indexPath];
 cell.switchActive.hidden = NO;
 }*/
#pragma mark -
#pragma mark Table View Data Source Methods
- (void)tableView:(UITableView *)aTableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSaving) {
        return;
    }
    isSaving = YES;
    selectedIndex = indexPath.row;
    isDeleteCell = YES;
    if (dictAReminder != nil) {
        [dictAReminder release];
        dictAReminder = nil;
    }
    dictAReminder = [[NSDictionary alloc] initWithDictionary:[arrayReminders objectAtIndex:indexPath.row]];
    
   //NSString *msgid = [NSString stringWithFormat:@"%@",[dictAReminder objectForKey:@"msgschedulerid"]];
    //iD = [recordDao getIndexOfARecordWithMsgid:msgid];
    //[recordDao updateAtIndex:iD Status:@"Delete"];
    
    
    indicator.hidden = NO;
    index = 2;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    if (appDelegate.deviceToken != nil) {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    }
    else {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    restConnection = [[RestConnection alloc] init];
    restConnection.viewController = self;
    
    [restConnection deleteDataWithPathSource:[NSString stringWithFormat:@"/rest/Reminders/%@",[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"msgschedulerid"]] andParam:arr withReminderID:[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"msgschedulerid"]];
    [arr release];
    //NSLog(@"%d",[arrayReminders count]);
    [arrayReminders removeObjectAtIndex:indexPath.row];
    //NSLog(@"%d",[arrayReminders count]);
    [appDelegate.arraySetupReminders release];
    appDelegate.arraySetupReminders = [[NSMutableArray alloc] initWithArray:arrayReminders];
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return isDeleteCell;
}

- (void)tableView:(UITableView *)aTableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    SetupReminderCell *cell = (SetupReminderCell*)[aTableView cellForRowAtIndexPath:indexPath];
    cell.switchActive.hidden = YES;
}

- (void)tableView:(UITableView *)aTableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!isDeleteCell) {
        SetupReminderCell *cell = (SetupReminderCell*)[aTableView cellForRowAtIndexPath:indexPath];
        cell.switchActive.hidden = NO;   
    }
    isDeleteCell = NO;
}


//#pragma mark -
//#pragma mark AddReminderTypeViewDelegate (Donot mark selectReminderType as delegate

- (void)selectRemiderType:(ReminderType)reminderType {
    viewAddReminder.hidden = YES;
    SetupAReminderViewController *setUpAReminderViewController = [[SetupAReminderViewController alloc] init];
    setUpAReminderViewController.reminderType = reminderType;
    [self.navigationController pushViewController:setUpAReminderViewController animated:YES];
    [setUpAReminderViewController release];
}

#pragma mark -
#pragma mark asihttprequest 
- (void)imageFetchComplete:(ASIHTTPRequest *)request {
    NSLog(@"complete");
    [tableView reloadData];
}
- (void)imageFetchFailed:(ASIHTTPRequest *)request {
    NSLog(@"failed");
    [tableView reloadData];
}

- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    isSaving = NO;
    indicator.hidden = YES;
    //NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    //SBJSON *parser = [SBJSON new];
    //NSDictionary *dataDict = (NSDictionary*)[parser objectWithString:responseData];
    //NSLog(@"%@",dataDict);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    if (index == 2) {
     [arrayReminders insertObject:dictAReminder atIndex:selectedIndex];
     [tableView reloadData];
    }
    
    if (index == 1) {
        if (active) {
            [[arrayReminders objectAtIndex:selectedIndex] setObject:@"Inactive" forKey:@"status"];
        }
        else {
            [[arrayReminders objectAtIndex:selectedIndex] setObject:@"Active" forKey:@"status"];
        }
    }
    [appDelegate.arraySetupReminders release];
    appDelegate.arraySetupReminders = [[NSMutableArray alloc] initWithArray:arrayReminders];
    
    [tableView reloadData];
    
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    indicator.hidden = YES;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    SBJSON *parser = [SBJSON new];
    id dataDict = [parser objectWithString:responseData];
    if (index == 0) {
        //after load reminders success, set it to loaded.
        appDelegate.theFirstShowSetupReminder = NO;
        if ([[dataDict class] isSubclassOfClass:[NSArray class]]) {
            arrayReminders = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
            appDelegate.arraySetupReminders = [[NSMutableArray alloc] initWithArray:arrayReminders];
            [tableView reloadData];            
            [self saveSetupReminderToDatabase];
        }
    }
    else {
        if (index == 1) {//update status
            if (!active) {
                [[arrayReminders objectAtIndex:selectedIndex] setObject:@"Inactive" forKey:@"status"];
            }
            else {
                [[arrayReminders objectAtIndex:selectedIndex] setObject:@"Active" forKey:@"status"];
            }
            [appDelegate.backgroundService getSetUpReminder];
        }
        else {
            isSaving = NO;
            NSLog(@"%@",responseData);
            if ([responseData rangeOfString:@"{Status: \"Schedule removed successfully\"}"].location == NSNotFound) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Reminder could not be deleted.  Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                [arrayReminders insertObject:dictAReminder atIndex:selectedIndex];
                [tableView reloadData];
            }
            else {
                [appDelegate.backgroundService getSetUpReminder];
            }
        }
    }
    appDelegate.theFirstShowSetupReminder = NO;
    [parser release];
    [responseData release];
}
@end
