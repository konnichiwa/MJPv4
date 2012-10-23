

#import <QuartzCore/QuartzCore.h>
#import "SetupAReminderViewController.h"
#import "SetupAReminderCell.h"
#import "SubcategoryViewController.h"
#import "YourReminderViewController.h"
#import "FrequencyViewController.h"
#import "TimePerDayViewController.h"
#import "RemindeMeView.h"
#import "SelectStockImageView.h"
#import "SetupReminderViewController.h"
#import "ASIHTTPRequest.h"
#import "RestConnection.h"
#import "SBJSON.h"
#include "DownloadImage.h"
#import "BackgroundService.h"
#import "ReminderMessageCell.h"
#import "ChooseStrength.h"

// Private stuff
@interface YourReminderViewController ()
- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;
- (void)imageFetchComplete:(ASIHTTPRequest *)request;
- (void)imageFetchFailed:(ASIHTTPRequest *)request;
@end


@implementation SetupAReminderViewController
@synthesize reminderType;
@synthesize tableView;
@synthesize dictParamValueReminder;
@synthesize allowMultipleTimePerDay;
@synthesize arrayParamReminder;
@synthesize isShowImageStock;
@synthesize firstTimeSignin;
@synthesize isUpdateReminder;
@synthesize viewPickerImage;
@synthesize pickerImage;
@synthesize scrollView;
@synthesize dictReminderDetail;
@synthesize gotoTimePerDay;
@synthesize currentEditIndex;
@synthesize iD;
@synthesize pharmacyList;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
     allowMultipleTimePerDay = YES;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Custom initialization
        //self.title = @"Set Up Reminder";
        //Add button
        
        UIBarButtonItem *buttonSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveReminder)];
        self.navigationItem.rightBarButtonItem = buttonSave;
        [buttonSave release];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    folderCheckArray =[[NSMutableArray alloc] init];
    [folderCheckArray addObject:@" Image"];
    [folderCheckArray addObject:@"No Image"];    
    [viewPickerImage setHidden:YES];
    [tableView reloadData];
    scrollView.frame = CGRectMake(0, 44, 320, 580); 
    [scrollView setContentSize:CGSizeMake(320, 680)];
    scrollView.contentMode=UIViewContentModeTop;
    [super viewWillAppear:animated];
    NSLog(@" %d",gotoTimePerDay);
}
- (void)viewDidAppear:(BOOL)animated{
    


    if (gotoTimePerDay == YES) {
        [self callTimePerDayVC];
        //reset time per day.
        /*
        NSArray *array = [[[arrayReminders objectAtIndex:indexPath.row] objectForKey:@"remindertime"] componentsSeparatedByString:@","];
        [n setObject:[NSString stringWithFormat:@"%dx Per Day", [array count]] forKey:@"TPD"];*/
        if (![[appDelegate.reminderTime stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
            NSArray *arr= [appDelegate.reminderTime componentsSeparatedByString:@","];
            [dictParamValueReminder setObject:[NSString stringWithFormat:@"%dx Per Day",[arr count]] forKey:@"TPD"];
        }
        
        gotoTimePerDay = NO;
    }
    if (reminderType == kMedication) {
        if (allowMultipleTimePerDay == NO) {
            [arrayParamReminder replaceObjectAtIndex:2 withObject:@"Start time*"];
        }
        else{
            [arrayParamReminder replaceObjectAtIndex:2 withObject:@"Times Per Day*"];
        }
        [tableView reloadData];
    }
    
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [scrollView release];
    [pickerImage release];
    [viewPickerImage release];
    [super dealloc];
    [tableView release];
    [arrayParamReminder release];
    [dictParamValueReminder release];
    [datePicker release];
    [viewDatePicker release];
    [stringDate release];
    //[startDate release];
    //[endDate release];
    //[downLoadImage release];
    [stringLinkImage release];
    appDelegate.reminderTime = [NSString stringWithString:@""];
    if (!startDate) {
        [startDate release];
    }
    if (!endDate) {
        [endDate release];
    }
    if (!downLoadImage) {
        [downLoadImage release];
    }
    if (!stringLinkImage) {
        [stringLinkImage release];
    }
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:) 
                                                 name:UIKeyboardDidHideNotification
                                               object:self.view.window];
    
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    indicator.hidden = YES;
   
    gotoTimePerDay = NO;
    hasRefillDate = NO;
    pressedSave = NO;
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    viewDatePicker.hidden = YES;
    stringDate = [[NSString alloc] initWithString:[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
    if (dictReminderDetail != nil) {
        appDelegate.frequency = [NSString stringWithString:[dictReminderDetail objectForKey:@"frequency"]];
        appDelegate.reminderTime = [NSString stringWithString:[dictReminderDetail objectForKey:@"remindertime"]];
    }
    else {
        appDelegate.reminderTime = [NSString stringWithString:@""];
    }
    switch (reminderType) {
        case kMedication:
            if (!dictParamValueReminder) {
                //set start date to current date, end date to one year.
                //NSString *preStart = [NSString stringWithString::[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                NSString *preStart = [NSString stringWithString:[formatter stringFromDate:[NSDate date]]];
                NSString *preEnd = [NSString stringWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:60*60*24*365]]];
                [formatter release];
                //dictParamValueReminder = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"",@"",@"",@"",preStart,preEnd,@"", nil] forKeys:[NSArray arrayWithObjects:@"Med",@"Image",@"Fre",@"TPD",@"Start",@"End",@"RefillDate", nil]];
                
                //arrayParamReminder = [[NSMutableArray alloc] initWithObjects:@"Medication*", @"Image",@"Frequency*",@"Times Per Day*",@"Start Date*",@"End Date*",@"Refill Reminder", nil];
                
                dictParamValueReminder = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"",@"",@"",preStart,preEnd,@"",@"", nil] forKeys:[NSArray arrayWithObjects:@"Med",@"Fre",@"TPD",@"Start",@"End",@"RefillDate",@"Image", nil]];
                
                arrayParamReminder = [[NSMutableArray alloc] initWithObjects:@"Medication*", @"Frequency*",@"Times Per Day*",@"Start Date*",@"End Date*",@"Medication Image*",@"Refill Reminder",@"Strength*",@"Pharmacy",@"Reminder Message",nil];
                appDelegate.medicationImageLink = @"";
                
                SubcategoryViewController *subcategoryViewController = [[SubcategoryViewController alloc] init];
                subcategoryViewController.reminderType = reminderType;
                [self.navigationController pushViewController:subcategoryViewController animated:YES];
                [subcategoryViewController release];
            }
            else{
                //update reminder
                NSString *image;
                image = [appDelegate getProperty:@"Medication Image" forData:dictReminderDetail];
                downLoadImage = [[DownloadImage alloc] init];
                stringLinkImage = [[NSString alloc] initWithString:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[image componentsSeparatedByString:@"/"] lastObject]]];
                downLoadImage.viewController = self;
                [downLoadImage downloadImageWithData:[NSArray arrayWithArray:[NSArray arrayWithObject:image]]];
                
                NSLog(@"%@",dictParamValueReminder);
                if ([[dictParamValueReminder objectForKey:@"Fre"] isEqualToString:@"Monthly"]) {
                    arrayParamReminder = [[NSMutableArray alloc] initWithObjects:@"Medication*",@"Frequency*",@"Times Per Day*",@"Day of Month*",@"End Date*",@"Medication Image", nil];
                }
                else {
                    if ([[dictParamValueReminder objectForKey:@"Fre"] isEqualToString:@"Yearly"]) {
                        arrayParamReminder = [[NSMutableArray alloc] initWithObjects:@"Medication*",@"Frequency*",@"Times Per Day*",@"Day of Year*",@"End Date*",@"Medication Image", nil];
                    }
                    else {
                         arrayParamReminder = [[NSMutableArray alloc] initWithObjects:@"Medication*",@"Frequency*",@"Times Per Day*",@"Start Date*",@"End Date*", @"Medication Image", nil];
                    }
                }
            }
            
            labelTitle.text = @"Setup Medication Reminder";
            
            break;
        case kPrescriptionFill:
;
            RecordDao *recordD=[[RecordDao alloc]init];
            recordD.tableName=[NSString stringWithFormat:CONTACT_TABLE];
            pharmacyList=[[NSMutableArray alloc] init];
            pharmacyList=[recordD getContactsFromType:@"Pharmacy"];
            arrayParamReminder = [[NSMutableArray alloc] initWithObjects:@"Medication*",@"Refill Date*",@"Reminder Time*",@"Repeat Every",@"Pharmacy",@"Reminder Message",nil];
            labelTitle.text = @"Prescription Reminder";
            NSLog(@"%@",dictParamValueReminder);
            if (!dictParamValueReminder) {
                dictParamValueReminder = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"",@"",@"",@"", nil] forKeys:[NSArray arrayWithObjects:@"Med",@"Date",@"Time",@"Every",nil]];
            }
            stringDate = [[NSString alloc] initWithString:[dictParamValueReminder objectForKey:@"Date"]];
            break;
        default:
            break;
    }

}
#pragma mark -
#pragma mark keyboard delegate
-(void) keyboardDidShow:(NSNotification *) notification {
    NSLog(@"%f",tableView.frame.size.height);
    CGRect tFrame = self.tableView.frame;
    tFrame.size.height -= 170;
        [tableView setFrame:tFrame];
    if (reminderType==kPrescriptionFill) {
                 [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else {
                 [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
        NSLog(@"%f",tableView.frame.size.height);
    
}

//—-when the keyboard disappears—-
-(void) keyboardDidHide:(NSNotification *) notification { 
    CGRect tFrame = self.tableView.frame;
    tFrame.size.height += 170;
    [tableView setFrame:tFrame];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setPickerImage:nil];
    [self setViewPickerImage:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification 
                                                  object:self.view.window];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:self.view.window];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)callTimePerDayVC{
    TimePerDayViewController *timePerDayViewController = [[TimePerDayViewController alloc] init];
    timePerDayViewController.allowMultipleTimePerDay = allowMultipleTimePerDay;
    if (dictReminderDetail != nil) {
        timePerDayViewController.timePerDay = [NSString stringWithString:appDelegate.reminderTime];   
    }
    else {
        timePerDayViewController.timePerDay = [NSString stringWithString:appDelegate.reminderTime];
    }
    [self.navigationController pushViewController:timePerDayViewController animated:YES];
    [timePerDayViewController release];
}
#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@" %@",dictParamValueReminder);
    return [arrayParamReminder count];
}


- (UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *indentifier1 = @"RemindMessage";
    ReminderMessageCell *cell1 = (ReminderMessageCell *)[tableView dequeueReusableCellWithIdentifier: indentifier1];
    if (cell1 == nil)  {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" 
                                                     owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[ReminderMessageCell class]])
                cell1 = (ReminderMessageCell *)oneObject;
	}
    
    static NSString *indentifier = @"SectionsTableIdentifier";
    SetupAReminderCell *cell = (SetupAReminderCell *)[tableView dequeueReusableCellWithIdentifier: indentifier];
    if (cell == nil)  {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" 
                                                     owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SetupAReminderCell class]])
                cell = (SetupAReminderCell *)oneObject;
	}
    
    //[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    //[cell.labelReminderParamValue setTextColor:];
    cell.labelReminderParam.text = [arrayParamReminder objectAtIndex:indexPath.row];
    cell.imageViewItem.image = nil;
    if (reminderType == kMedication) {
        switch (indexPath.row) {
            case 0:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"Med"];
                break;
            case 5:
                cell.labelReminderParamValue.text = nil;
                NSString *image = [dictParamValueReminder objectForKey:@"Image"];
                if ([image rangeOfString:@"http"].location == NSNotFound) { //use stock image
                    if (![image isEqualToString:@""]) { //update Reminder , stock image
                        if ([image rangeOfString:@"Documents"].location != NSNotFound) {
                            cell.imageViewItem.image = [UIImage imageWithContentsOfFile:image];//create new Reminder                         
                        }
                        else {
                            NSString *imagePath = [[NSBundle mainBundle] pathForResource:[[[[image componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] objectAtIndex:0] ofType:@"png"];
                            cell.imageViewItem.image = [UIImage imageWithContentsOfFile:imagePath];
                        }
                    }
                    else { //create Reminder
                        //cell.imageViewItem.image = [UIImage imageWithContentsOfFile:[dictParamValueReminder objectForKey:@"Image"]];
                        cell.imageViewItem.image = nil;
                    }
                }
                else { //update Reminder, image of dosage
                    //cell.imageViewItem.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
                    cell.imageViewItem.image = [UIImage imageWithContentsOfFile:stringLinkImage];
                }
                
                break;
            case 1:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"Fre"];
                NSLog(@"Frequency %@",[dictParamValueReminder objectForKey:@"Fre"]);
                break;
            case 2:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"TPD"];
                NSLog(@"%@", [dictParamValueReminder objectForKey:@"TPD"]);
                cell.labelReminderParamValue.frame = CGRectMake(166, 14, 110, 21);
                break;
            case 3:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"Start"];
                break;
            case 4:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"End"];
                break;
            case 6:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"RefillDate"];
                break;
                
            case 9:
                cell1.textMessage.delegate=self;
                currentTextField=cell1.textMessage;
                return cell1;
                break;
            default:
                break;
        }   
    }
    if (reminderType == kPrescriptionFill) {
        switch (indexPath.row) {
            case 0:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"Med"];
                break;
            case 1:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"Date"];
                break;
            case 2:
                cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"Time"];
                break;
                
                 case 3:
                 cell.labelReminderParamValue.text = [dictParamValueReminder objectForKey:@"Every"];
                 break;
            case 4:
                break;
            case 5:
                cell1.textMessage.delegate=self;
                currentTextField=cell1.textMessage;
                return cell1;
                break;
            default:
                break;
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    //end h
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row==9)&&(reminderType==kMedication)) {
        return 80;
    }
    if ((indexPath.row==5)&&(reminderType==kPrescriptionFill)) {
        return 80;
    }
    return 44;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (reminderType == kMedication) { //Medication
        NSString *time;
        switch (indexPath.row) {
            case 0: //Select Medication
            {
                SubcategoryViewController *subcategoryViewController = [[SubcategoryViewController alloc] init];
                subcategoryViewController.reminderType = reminderType;
                [self.navigationController pushViewController:subcategoryViewController animated:YES];
                [subcategoryViewController release];
            }
                break;
         
            case 1: //select Frequency
            {
                FrequencyViewController *frequencyViewController = [[FrequencyViewController alloc] init];
                frequencyViewController.isFrequency = YES;
                frequencyViewController.reminderType = reminderType;
                [self.navigationController pushViewController:frequencyViewController animated:YES];
                [frequencyViewController release];
            }
                break;
            case 2: //Select Times Per days
                {
                    if (allowMultipleTimePerDay) {
                        [self callTimePerDayVC];
                    }
                    else {
                        time = [dictParamValueReminder objectForKey:@"TPD"];
                        datePicker.tag = 3;
                        if ([time isEqualToString:@""] == NO) {
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateStyle:NSDateFormatterShortStyle];
                            NSDate *date = [formatter dateFromString:time];
                            
                            [formatter release];
                            //[[[properties objectAtIndex:i] objectForKey:@"propertyValue"] isKindOfClass:[NSNull class]]
                            if (date == nil ||[date isKindOfClass:[NSNull class]] ) {
                                [datePicker setDate:[NSDate date]];
                            }
                            else {
                                [datePicker setDate:date];
                            }
                        }
                        
                        isMedicationTime = YES;
                        isStartDate = NO;
                        viewDatePicker.hidden = NO;
                        [datePicker setDatePickerMode:UIDatePickerModeTime];
                        [stringDate release];
                        stringDate = [[NSString alloc] initWithString:[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
                    }
                }
                break;
            case 3://Select start date
            {
                datePicker.tag = 0;
                isStartDate = YES;
                viewDatePicker.hidden = NO;
                [datePicker setDatePickerMode:UIDatePickerModeDate];
                [stringDate release];
                stringDate = [[NSString alloc] initWithString:[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
                
                time = [dictParamValueReminder objectForKey:@"Start"];
                if ([time isEqualToString:@""] == NO) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateStyle:NSDateFormatterMediumStyle];
                    NSDate *date = [formatter dateFromString:time];
                    [formatter release];
                    [datePicker setDate:date];
                }
            }
                break;
            case 4: //select end date
            {
                datePicker.tag = 1;
                isStartDate = NO;
                viewDatePicker.hidden = NO;
                [datePicker setDatePickerMode:UIDatePickerModeDate];
                [stringDate release];
                stringDate = [[NSString alloc] initWithString:[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
                
                time = [dictParamValueReminder objectForKey:@"End"];
                if ([time isEqualToString:@""] == NO) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateStyle:NSDateFormatterMediumStyle];
                    NSDate *date = [formatter dateFromString:time];
                    [formatter release];
                    [datePicker setDate:date];
                }

            }
                break;
            case 5: //Select Media Image
            {
                [viewPickerImage setHidden:NO];
                
                CGRect frame=viewPickerImage.frame;
                frame.origin=CGPointMake(0, 480);
                viewPickerImage.frame=frame;
                frame.origin=CGPointMake(0, 480-frame.size.height-20);
                [UIView animateWithDuration:0.5 animations:^{ 
                    viewPickerImage.frame=frame;  
                }];
                
                
                /* UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Medication Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use a Stock Image",@"No Image", nil];
                 [actionSheet showInView:self.view];
                 [actionSheet release];*/
            }
                break;
            case 6: //refill reminder.
                //isStartDate = YES;
                datePicker.tag = 2;
                viewDatePicker.hidden = NO;
                [datePicker setDatePickerMode:UIDatePickerModeDate];
                [stringDate release];
                stringDate = [[NSString alloc] initWithString:[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
                break;
            case 7:
            {   ChooseStrength *vc=[[ChooseStrength alloc] initWithNibName:@"ChooseStrength" bundle:nil];
                vc.medicationName=[dictParamValueReminder objectForKey:@"Med"];
                [self.navigationController pushViewController:vc animated:YES];
                [vc release];
                
            }
                break;
            case 9: //refill reminder.
                [currentTextField becomeFirstResponder];
                break;
            default:
                break;
        }   
    }
    if (reminderType == kPrescriptionFill) {
        NSString *time;
        switch (indexPath.row) {
            case 0:{
                SubcategoryViewController *subcategoryViewController = [[SubcategoryViewController alloc] init];
                subcategoryViewController.reminderType = reminderType;
                [self.navigationController pushViewController:subcategoryViewController animated:YES];
                [subcategoryViewController release];   
            }
                break;
            case 1: //select Date
                time = [dictParamValueReminder objectForKey:@"Date"];
                if ([time isEqualToString:@""] == NO) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateStyle:NSDateFormatterMediumStyle];
                    NSDate *date = [formatter dateFromString:time];
                    [formatter release];
                    [datePicker setDate:date];
                }
                isStartDate = YES;
                viewDatePicker.hidden = NO;
                [datePicker setDatePickerMode:UIDatePickerModeDate];
                [stringDate release];
                stringDate = [[NSString alloc] initWithString:[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
                break;
            case 2: //select Time
                time = [dictParamValueReminder objectForKey:@"Time"];
                if ([time isEqualToString:@""] == NO) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                    NSDate *date = [formatter dateFromString:time];
                    [formatter release];
                    [datePicker setDate:date];
                }
                isStartDate = NO;
                viewDatePicker.hidden = NO;
                [datePicker setDatePickerMode:UIDatePickerModeTime];
                [stringDate release];
                stringDate = [[NSString alloc] initWithString:[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];

                break;
            case 3://refill every same Frequency not accessory
            {   FrequencyViewController *frequencyViewController = [[FrequencyViewController alloc] init];
                frequencyViewController.isFrequency = NO;
                frequencyViewController.reminderType = reminderType;
                [self.navigationController pushViewController:frequencyViewController animated:YES];
                [frequencyViewController release];
            }
            case 4:
            {
                [viewPickerImage setHidden:NO];
                [self.view addSubview:viewPickerImage];
                CGRect frame=viewPickerImage.frame;
                frame.origin.y=480-frame.size.height-20;
                [viewPickerImage setFrame:frame];
            }
                break;
            default:
                break;
        }
        
    }
}
#pragma mark -
#pragma mark action
- (IBAction)dismissPickerImage:(id)sender {
    [viewPickerImage setHidden:YES];
    switch ([pickerImage selectedRowInComponent:0]) {
        case 0: //use stock image
        {
            NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"SelectStockImageView"
                                                              owner:self
                                                            options:nil];
            
            SelectStockImageView *selectStockImageView = [[nibViews objectAtIndex:0] retain];
            [selectStockImageView setUpView];
            selectStockImageView.delegate = self;
            selectStockImageView.frame = CGRectMake(0, 20, 320, 460);
            //[self.view addSubview:medicationStrengthView];
            [appDelegate.window addSubview:selectStockImageView];
            // set up an animation for the transition between the views
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.5];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            [[selectStockImageView layer] addAnimation:animation forKey:@"SwitchToView1"];
        }
            break;
        case 1: // no image
        {
            [dictParamValueReminder setObject:@"" forKey:@"Image"];
            appDelegate.medicationImageLink = @"";
            [tableView reloadData];
        }
            break;
        default:
            break;
    }

}

- (IBAction)changeValueDatePicker:(id)sender {
    [stringDate release];
    stringDate = [[NSString alloc] initWithString:[[[[sender date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
}
- (IBAction)setDate:(id)sender {
    viewDatePicker.hidden = YES;
    if (reminderType == kMedication || reminderType == kVital) {
        /** set refill time **/
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        stringDate = [[NSString alloc] initWithString:[formatter stringFromDate:[datePicker date]]];
        [formatter release];
        
        /** end set refill time **/
        if (datePicker.tag == 2) {
            hasRefillDate = YES;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            stringDate = [[NSString alloc] initWithString:[formatter stringFromDate:[datePicker date]]];
            [formatter release];
            NSLog(@"%@",stringDate);
            [dictParamValueReminder setValue:stringDate forKey:@"RefillDate"];
            [tableView reloadData];
            return;
        }
        if (datePicker.tag == 3) {
            appDelegate.reminderTime = [[stringDate copy] autorelease];
            NSLog(@" %@ ",appDelegate.reminderTime);
        }
        if (isStartDate) {
            if (startDate != nil) {
                [startDate release];
                startDate = nil;
            }
            startDate = [[datePicker date] retain];
            if ([startDate compare:endDate] == NSOrderedDescending) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Invalid Start Date!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            }
            else {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                stringDate = [[NSString alloc] initWithString:[formatter stringFromDate:[datePicker date]]];
                [formatter release];
                [dictParamValueReminder setValue:stringDate forKey:@"Start"];
            }
        }
        else {
            if (1){
                if (isMedicationTime) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                    stringDate = [[NSString alloc] initWithString:[formatter stringFromDate:[datePicker date]]];
                    [formatter release];
                    [dictParamValueReminder setValue:stringDate forKey:@"TPD"];
                    isMedicationTime = NO;
                }
                else { 
                    if (endDate != nil) {
                        [endDate release];
                        endDate = nil;
                    }
                    endDate = [[datePicker date] retain];
                    if ([endDate compare:startDate] == NSOrderedAscending) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Invalid End Date!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                        [alertView release];
                    }
                    else {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateStyle:NSDateFormatterMediumStyle];
                        stringDate = [[NSString alloc] initWithString:[formatter stringFromDate:[datePicker date]]];
                        [formatter release];
                        [dictParamValueReminder setValue:stringDate forKey:@"End"];
                    }
                }
            }
        }
    }
    if (reminderType == kPrescriptionFill) {
        if (isStartDate) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            stringDate = [[NSString alloc] initWithString:[formatter stringFromDate:[datePicker date]]];
            [formatter release];
            [dictParamValueReminder setValue:stringDate forKey:@"Date"];
        }
        else {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            stringDate = [[NSString alloc] initWithString:[formatter stringFromDate:[datePicker date]]];
            [formatter release];
            [dictParamValueReminder setValue:stringDate forKey:@"Time"];
        }
    }
    
    [tableView reloadData];
}

- (IBAction)dismissViewDatePicker:(id)sender {
    viewDatePicker.hidden = YES;
}
- (IBAction)saveReminder {
    
    NSString *strMedName = [[NSString alloc] initWithString:[[dictParamValueReminder objectForKey:@"Med"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    if ([strMedName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood  Journal" message:@"You must fill all required field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.view addSubview:alert];
        [alert show];
        [alert release];
        [strMedName release];
        return;
    }
    else{
        [strMedName release];
    }
        //check error time, date 
    switch (reminderType) {
        case kMedication:
        {
            //get current date
            if ([[dictParamValueReminder objectForKey:@"Start"] isEqualToString:[dictParamValueReminder objectForKey:@"End"]]) {
                //CHECK IF TIME SET IS SMALLER THAN CURRENT TIME
                
            }
            if ([[appDelegate.reminderTime stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Journal Plus" message:@"You must fill all required field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
                return;
            }
        }
            break;
            
        case kPrescriptionFill:
        {
            if([[[dictParamValueReminder objectForKey:@"Date"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]||[[[dictParamValueReminder objectForKey:@"Time"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
             //Time   
                //log error
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Journal Plus" message:@"You must fill all required field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
                return;
            }
            
        }
            break;
            
        default:
            break;
    }
    
    //if medication name is not set, alert error
    
    if (isUpdateReminder) {
        switch (reminderType) {
            case kMedication:
                [self setUpMedicationReminder:dictReminderDetail];
                break;
            case kPrescriptionFill:
                [self setUpRefillReminder:dictReminderDetail];
                break;
                
            default:
                break;
        }
    }
    else {
        if (!isSaving) {
            isSaving = YES;
            NSString *msgtypeid = @"";
            
            switch (reminderType) {
                case kMedication:
                {
                    //NSLog(@"value %@",[dictParamValueReminder objectForKey:@"Fre"]);
                    if ([[dictParamValueReminder objectForKey:@"Fre"] isEqualToString:@""]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Journal" message:@"You must fill all required field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [alert release];
                        indicator.hidden = YES;
                        isSaving = NO;
                        return;
                    }
                    msgtypeid = @"700210";
                }
                    break;
                case kPrescriptionFill:
                {
                    if ([[[dictParamValueReminder objectForKey:@"Every"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mood Jounal" message:@"Error 500 : 1" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                        [alertView release];
                        return;
                    }
                    else {
                        msgtypeid = @"700165";
                    }
                }
                    break;
                default:
                    break;
            }
            //step 1 : prebuild
            if (pressedSave == YES) {
                return;
                
            }
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
            if (appDelegate.deviceToken != nil) {
                [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
                NSLog(@"%@",appDelegate.deviceToken);
            }
            else {
                [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
            }
            [arr addObject:[NSMutableDictionary dictionaryWithObject:msgtypeid forKey:@"msgtypeid"]];
            indicator.hidden = NO;
            restConnection = [[RestConnection alloc] init];
            restConnection.viewController = self;
            isMedication = YES;
            [restConnection getDataWithPathSource:@"/rest/Reminders/prebuild" andParam:arr forService:@"getYourRemiders"];
            [arr release];
            index = 0;   
        }
    }
    
    pressedSave = YES;
    indicator.hidden = NO;
    [indicator startAnimating];
}

- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString*)converTimeToMilisecond:(NSDate*)date {
    NSString *timeInterval = [[NSString alloc] initWithString:[[NSString stringWithFormat:@"%20.0f",[date timeIntervalSince1970]*1000] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    return [timeInterval autorelease];
}

- (NSString*)timezone {
    NSString *timezone = [[NSString alloc] initWithFormat:@"%@",[[NSTimeZone systemTimeZone] name]];
    return [timezone autorelease];
}

- (void)setUpRimider:(NSMutableDictionary*)baseTemplate {
    index = 1;
    SBJSON *json = [SBJSON new];
    NSString *postData = [json stringWithObject:baseTemplate];
    NSLog(@"luan");
    [json release];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    if (appDelegate.deviceToken != nil) {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    }
    else {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    
    indicator.hidden = NO;
    restConnection = [[RestConnection alloc] init];
    restConnection.viewController = self;
    NSLog(@"final setup: for final posted data ---------------");
    if (isUpdateReminder) {
        //NSLog(@"put data %@",postData);
        [restConnection putDataWithPathSource:@"/rest/Reminders" andParam:arr withPostData:postData];
    }
    else {
        [restConnection postDataWithPathSource:@"/rest/Reminders" andParam:arr withPostData:postData];
    }
    [arr release];
}


- (void)setUpMedicationReminder:(NSMutableDictionary*)baseTemplate {
    //NSLog(@"%@",baseTemplate);
    if (appDelegate.frequency == nil) {
        appDelegate.frequency = [NSString stringWithString:@""];
    }
    if (appDelegate.reminderTime == nil) {
        appDelegate.reminderTime = [NSString stringWithString:@""];
    }
    //start date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSDate *startdate = [formatter dateFromString:[dictParamValueReminder objectForKey:@"Start"]];
    NSString *stringStartDate = [self converTimeToMilisecond:startdate];
      NSLog(@"end date %@",stringStartDate);
    //end date
    NSDate *enddate = [formatter dateFromString:[dictParamValueReminder objectForKey:@"End"]];
    NSString *stringEndDate = [self converTimeToMilisecond:enddate];
    NSLog(@"end date %@",stringEndDate);
    [formatter release];
        NSLog(@"%@",yourMessage);
    if ([yourMessage isEqualToString:@""]) {
        yourMessage=[NSString stringWithFormat:@" Please take your medication"];
    }
    [baseTemplate setObject:[self converTimeToMilisecond:[NSDate date]] forKey:@"createddate"];
    [baseTemplate setObject:appDelegate.frequency forKey:@"frequency"];
    [baseTemplate setObject:[self timezone] forKey:@"timezone"];
    [baseTemplate setObject:stringStartDate forKey:@"startdate"];
    [baseTemplate setObject:stringEndDate forKey:@"enddate"];
    [baseTemplate setObject:appDelegate.reminderTime forKey:@"remindertime"];
    [baseTemplate setObject:@"Active" forKey:@"status"];
    NSArray *properties = [baseTemplate objectForKey:@"properties"];
    for (int i = 0; i < [properties count]; i++) {
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"Medication Name"]) {
            [[[baseTemplate objectForKey:@"properties"] objectAtIndex:i] setObject:[dictParamValueReminder objectForKey:@"Med"] forKey:@"propertyvalue"];
        }
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"Medication Image"]) {
            [[[baseTemplate objectForKey:@"properties"] objectAtIndex:i] setObject:appDelegate.medicationImageLink forKey:@"propertyvalue"];
            NSLog(@"set image %@",appDelegate.medicationImageLink);
        }
        
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"Content"]) {
            [[[baseTemplate objectForKey:@"properties"] objectAtIndex:i] setObject:[NSString stringWithFormat:@"%@",yourMessage] forKey:@"propertyvalue"];
        }
        
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"Strength"]) {
            [[[baseTemplate objectForKey:@"properties"] objectAtIndex:i] setObject:@"12 mg" forKey:@"propertyvalue"];
        }
        
        
    }
    
    NSLog(@"%@",baseTemplate);
    [self setUpRimider:baseTemplate];
}


- (void)setUpRefillReminder:(NSMutableDictionary*)baseTemplate {
    if (!hasRefillDate) {
        if (appDelegate.frequency == nil) {
            appDelegate.frequency = [NSString stringWithString:@""];
        }
        if (appDelegate.reminderTime == nil) {
            appDelegate.reminderTime = [NSString stringWithString:@""];
        }
        //start date
        NSLog(@"%@",dictParamValueReminder);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        NSDate *startdate = [formatter dateFromString:[dictParamValueReminder objectForKey:@"Date"]];
        NSString *stringStartDate = [self converTimeToMilisecond:startdate];
        
        //end date
        NSString *enddate;
        NSInteger year = [[[[[dictParamValueReminder objectForKey:@"Date"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "] objectAtIndex:2] intValue]+5;
        enddate = [[dictParamValueReminder objectForKey:@"Date"] stringByReplacingOccurrencesOfString:[[[dictParamValueReminder objectForKey:@"Date"] componentsSeparatedByString:@" "] objectAtIndex:2] withString:[NSString stringWithFormat:@"%d",year]];
        if ([[[[dictParamValueReminder objectForKey:@"Date"] componentsSeparatedByString:@" "] objectAtIndex:0] isEqualToString:@"Every"] && [[[[dictParamValueReminder objectForKey:@"Date"] componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"29,"]) {
            enddate = [enddate stringByReplacingOccurrencesOfString:@"29" withString:@"28"];
        }
        NSString *stringEndDate = [self converTimeToMilisecond:[formatter dateFromString:enddate]];     
        [formatter release];
        [baseTemplate setObject:[self converTimeToMilisecond:[NSDate date]] forKey:@"createddate"];
        NSLog(@"%@",[dictParamValueReminder objectForKey:@"Every"]);
        
        [baseTemplate setObject:[dictParamValueReminder objectForKey:@"Every"] forKey:@"frequency"];
        [baseTemplate setObject:[self timezone] forKey:@"timezone"];
        [[[baseTemplate objectForKey:@"properties"] objectAtIndex:0] setObject:[dictParamValueReminder objectForKey:@"Med"] forKey:@"propertyvalue"];
        [[[baseTemplate objectForKey:@"properties"] objectAtIndex:2] setObject:yourMessage forKey:@"propertyvalue"];
        [baseTemplate setObject:stringStartDate forKey:@"startdate"];
        [baseTemplate setObject:stringEndDate forKey:@"enddate"];
        [baseTemplate setObject:[dictParamValueReminder objectForKey:@"Time"] forKey:@"remindertime"];
        [baseTemplate setObject:@"Active" forKey:@"status"];
        //NSLog(@" base temp: \n %@",baseTemplate);
        [self setUpRimider:baseTemplate];
    }
    else { 
        if (appDelegate.frequency == nil) {
            appDelegate.frequency = [NSString stringWithString:@""];
        }
        if (appDelegate.reminderTime == nil) {
            appDelegate.reminderTime = [NSString stringWithString:@""];
        }
        //start date
       // NSLog(@"%@",dictParamValueReminder);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        NSDate *startdate = [formatter dateFromString:[dictParamValueReminder objectForKey:@"RefillDate"]];
        NSString *stringStartDate = [self converTimeToMilisecond:startdate];
        
        //end date
        NSString *enddate;
        NSInteger year = [[[[dictParamValueReminder objectForKey:@"RefillDate"] componentsSeparatedByString:@" "] objectAtIndex:2] intValue]+5;
        enddate = [[dictParamValueReminder objectForKey:@"RefillDate"] stringByReplacingOccurrencesOfString:[[[dictParamValueReminder objectForKey:@"RefillDate"] componentsSeparatedByString:@" "] objectAtIndex:2] withString:[NSString stringWithFormat:@"%d",year]];
        if ([[[[dictParamValueReminder objectForKey:@"RefillDate"] componentsSeparatedByString:@" "] objectAtIndex:0] isEqualToString:@"Feb"] && [[[[dictParamValueReminder objectForKey:@"RefillDate"] componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"29,"]) {
            enddate = [enddate stringByReplacingOccurrencesOfString:@"29" withString:@"28"];
        }
        NSString *stringEndDate = [self converTimeToMilisecond:[formatter dateFromString:enddate]];
        [formatter release];
        
        [baseTemplate setObject:[self converTimeToMilisecond:[NSDate date]] forKey:@"createddate"];
        //[baseTemplate setObject:[[dictParamValueReminder objectForKey:@"Every"] lowercaseString] forKey:@"frequency"];
        [baseTemplate setObject:@"28 days" forKey:@"frequency"];
        [baseTemplate setObject:[self timezone] forKey:@"timezone"];
        [[[baseTemplate objectForKey:@"properties"] objectAtIndex:0] setObject:[dictParamValueReminder objectForKey:@"Med"] forKey:@"propertyvalue"];
        [baseTemplate setObject:stringStartDate forKey:@"startdate"];
        [baseTemplate setObject:stringEndDate forKey:@"enddate"];
        [baseTemplate setObject:@"12:00 PM" forKey:@"remindertime"];
        [baseTemplate setObject:@"Active" forKey:@"status"];
        
        //NSLog(@" base temp: \n %@",baseTemplate);
        [self setUpRimider:baseTemplate];
        hasRefillDate = NO;
    }
}

- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone {
    NSString *dateString;
    double deliveryDate = [floatString doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (date) {
        [formatter setDateStyle:NSDateFormatterMediumStyle];   
    }
    else {
        [formatter setTimeStyle:NSDateFormatterShortStyle];   
    }
    dateString = [[NSString alloc] initWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)((double)deliveryDate/(double)1000)]]];
    [formatter release];
    return [dateString autorelease];
}

#pragma mark -
#pragma mark SelectStockImageView
- (void)selectStockImage:(NSString *)image {

    appDelegate.medicationImageLink = [NSString stringWithString:[[image componentsSeparatedByString:@"/"] lastObject]];
    [dictParamValueReminder setObject:image forKey:@"Image"];
    [tableView reloadData];
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   }

#pragma mark -
#pragma mark RemindeMeViewDelegate
- (void)selectRemindeMe:(NSString *)time {
    [dictParamValueReminder setObject:time forKey:@"Remind"];
    [tableView reloadData];
}


#pragma mark -
#pragma mark asihttprequest 
- (void)imageFetchComplete:(ASIHTTPRequest *)request {
    [tableView reloadData];
}
- (void)imageFetchFailed:(ASIHTTPRequest *)request {
    
}

- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    isSaving = NO;
    pressedSave = NO;
    indicator.hidden = YES;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseData);
    [responseData release];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Jounal" message:@"Connection failed! Please check connection and try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    indicator.hidden = YES;
    isSaving = NO;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"-=-=-=%@",responseData);
    SBJSON *parser = [[SBJSON new] autorelease];
    id dataDict = [parser objectWithString:responseData];
    NSLog(@"%@",dataDict);    
    if ([appDelegate hasErrorMessage:(NSDictionary *)dataDict]) {
        pressedSave = NO;
        return;
    }
    if (index == 0) {
        switch (reminderType) {
            case kPrescriptionFill:
                [self setUpRefillReminder:[NSMutableDictionary dictionaryWithDictionary:dataDict]];
                break;
            case kMedication:
                if (isMedication) {
                    [self setUpMedicationReminder:[NSMutableDictionary dictionaryWithDictionary:dataDict]];
                       
                    
                }
                else {
                    [self setUpRefillReminder:[NSMutableDictionary dictionaryWithDictionary:dataDict]];
                }
                break;
            default:
                break;
        }
    }
    else {
        
        if (isUpdateReminder) {
            
            if ([responseData isEqualToString:@"{ JOBID : SUCCESS}"]) {
            
               // NSArray *array = [self.navigationController viewControllers];                
            if (firstTimeSignin == YES) {
                SetupReminderViewController *s = [[SetupReminderViewController alloc] init];
                [self.navigationController pushViewController:s animated:YES];
                [s release];
                return;
            }
            //[(SetupReminderViewController*)[array objectAtIndex:[array count]-2] loadData];
            
            [self.navigationController popViewControllerAnimated:YES];
            [appDelegate.backgroundService getSetUpReminder];
            }
            else{//update failed
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Journal" message:responseData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            appDelegate.theFirstShowSetupReminder = YES;//reupdate reminder
        }
        else {
            //insert reminder.
            if ([responseData isEqualToString:@"{Status : \"Success\", html : \"null\"}"]||[responseData isEqualToString:@"{Status : \"Success\"}"]) {
                if (firstTimeSignin == YES) {
                    //save setting to settedMedication.
                        [appDelegate.dictSetting setObject:@"1" forKey:@"settedMedication"];    
                        //Cache data ---------------
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                                             NSUserDomainMask, YES); 
                        
                        NSString *cacheDirectory = [paths objectAtIndex:0];  
                        NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
                        [appDelegate.dictSetting writeToFile:filePath atomically:YES];
                    
                    if (!hasRefillDate) { //no set up refill date
                        SetupReminderViewController *s = [[SetupReminderViewController alloc] init];
                        [self.navigationController pushViewController:s animated:YES];
                        [s release];
                        [appDelegate.backgroundService getSetUpReminder];
                    }
                    else { //set up refill date
                        NSString *msgtypeid = @"700165";
                        NSMutableArray *arr = [[NSMutableArray alloc] init];
                        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
                        if (appDelegate.deviceToken != nil) {
                            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
                        }
                        else {
                            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
                        }
                        //[arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
                        [arr addObject:[NSMutableDictionary dictionaryWithObject:msgtypeid forKey:@"msgtypeid"]];
                        
                        restConnection = [[RestConnection alloc] init];
                        restConnection.viewController = self;
                        isMedication = NO; 
                        NSLog(@"prebuilt ------------");
                        [restConnection getDataWithPathSource:@"/rest/Reminders/prebuild" andParam:arr forService:@"getYourRemiders"];
                        [arr release];
                        index = 0;
                    }
                    return;
                }
                
                if (!hasRefillDate) { //no set up refill date
                    //NSArray *array = [self.navigationController viewControllers];
                    //[(SetupReminderViewController*)[array objectAtIndex:[array count]-2] loadData];
                    [self.navigationController popViewControllerAnimated:YES];
                    [appDelegate.backgroundService getSetUpReminder];
                }
                else { // set up refill date
                    NSString *msgtypeid = @"700165";
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
                    
                    //[arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
                    if (appDelegate.deviceToken != nil) {
                        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
                    }
                    else {
                        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
                    }
                    [arr addObject:[NSMutableDictionary dictionaryWithObject:msgtypeid forKey:@"msgtypeid"]];
                    
                    restConnection = [[RestConnection alloc] init];
                    restConnection.viewController = self;
                    isMedication = NO;
                    [restConnection getDataWithPathSource:@"/rest/Reminders/prebuild" andParam:arr forService:@"getYourRemiders"];
                    [arr release];
                    index = 0;
                }
                
                
            }
            else {
                isSaving = NO;
                [appDelegate hasErrorMessage:dataDict];
            }   
        }
    }
    appDelegate.theFirstShowSetupReminder = YES;
    
}
#pragma mark -
#pragma mark textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    yourMessage=[NSString stringWithFormat:@"%@",textField.text];
    [yourMessage retain];
    [textField resignFirstResponder];  
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextField=textField;
}
#pragma mark -
#pragma mark PickerData
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (reminderType) {
        case kMedication:
        {
            return 2;
        }
            break;
        case kPrescriptionFill:
        {
            return [pharmacyList count];
        }
        default:
            break;
    }

}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (reminderType==kMedication) {
    UIView *pickerviewtemp=[[UIView alloc] initWithFrame:CGRectZero];
    UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(35,0, 240, 30)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:[folderCheckArray objectAtIndex:row]];
    [lbl setFont:[UIFont boldSystemFontOfSize:20]];
    [pickerviewtemp addSubview:lbl];
    UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(20, 8, 15, 15)];
   // [imgView setImage:nil];
//    [imgView setImage:[UIImage imageNamed:@"check"]];
    if ([pickerImage selectedRowInComponent:0]==row) {
        [imgView setImage:[UIImage imageNamed:@"check"]];
    }
    else {      
        [imgView setImage:nil];
    }   
    [pickerviewtemp addSubview:imgView];
    return pickerviewtemp;
    }
    
    if (reminderType==kPrescriptionFill) {
        UIView *pickerviewtemp=[[UIView alloc] initWithFrame:CGRectZero];
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(35,0, 240, 30)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        NSMutableDictionary *pharmacy=[[NSMutableDictionary alloc] init];
        pharmacy=[pharmacyList objectAtIndex:row];
        NSLog(@"%@",pharmacy);
        [lbl setText:[appDelegate doCipher:[pharmacy objectForKey:@"name"] :kCCDecrypt]];
        [lbl setFont:[UIFont boldSystemFontOfSize:20]];
        [pickerviewtemp addSubview:lbl];
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(20, 8, 15, 15)];
        if ([pickerImage selectedRowInComponent:0]==row) {
            [imgView setImage:[UIImage imageNamed:@"check"]];
        }
        else {      
            [imgView setImage:nil];
        }   
        [pickerviewtemp addSubview:imgView];
        return pickerviewtemp;
    }
    return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{

}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerImage reloadAllComponents];
}
@end
