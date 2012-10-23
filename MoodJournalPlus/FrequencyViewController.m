

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "FrequencyViewController.h"
#import "SetupAReminderCell.h"
#import "SetupAReminderViewController.h"
#import "SelectDayViewController.h"
#import "SetupAReminderViewController.h"
#import "RemindeMeView.h"


@implementation FrequencyViewController
@synthesize isFrequency;
@synthesize reminderType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Frequency";
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
    [tableView release];
    [arrayFrequency release];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
    allowMultipleTimePerDay = YES;
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (isFrequency) {
        //arrayFrequency = [[NSMutableArray alloc] initWithObjects:@"Daily",@"Weekly",@"Every 1x",@"Monthly",@"Yearly", nil];   
        arrayFrequency = [[NSMutableArray alloc] initWithObjects:@"Daily",@"Weekly",@"Monthly",@"Yearly",@"Other", nil]; 
    }
    else {
        arrayFrequency = [[NSMutableArray alloc] initWithObjects:@"30 Days",@"60 Days",@"90 Days",@"120 Days",@"Other", nil];
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

- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayFrequency count];
}

- (UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *indentifier = @"SetupAReminderCell";
    
    SetupAReminderCell *cell = (SetupAReminderCell *)[tableView dequeueReusableCellWithIdentifier: indentifier];
    if (cell == nil)  {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" 
                                                     owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[SetupAReminderCell class]])
                cell = (SetupAReminderCell *)oneObject;
	}
    //[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    cell.labelReminderParam.text = [arrayFrequency objectAtIndex:indexPath.row];
    cell.labelReminderParamValue.text = nil;
    cell.imageViewAccessory.image = nil;
    cell.imageViewItem.image = nil;
    //h: change background color
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reminderDetailBG.png"]] autorelease];
    //end h
    /*
     UIView *v = [[[UIView alloc] init] autorelease];
     v.backgroundColor = [UIColor colorWithRed:(CGFloat) green:(CGFloat) blue:<#(CGFloat)#> alpha:(CGFloat)];
     cell.selectedBackgroundView = v; */
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0||indexPath.row == 1 ||indexPath.row == 3 || indexPath.row == 2) {
        [(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] setGotoTimePerDay:NO];
        //set times per day to every X
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isFrequency) {
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3) {
            appDelegate.frequency = [NSString stringWithString:[arrayFrequency objectAtIndex:indexPath.row]];
            
            [(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] setAllowMultipleTimePerDay:YES];
            [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:[arrayFrequency objectAtIndex:indexPath.row] forKey:@"Fre"];
            NSLog(@"set object as %@",[arrayFrequency objectAtIndex:indexPath.row]);
            if (reminderType == kMedication) {
                [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] arrayParamReminder] replaceObjectAtIndex:2 withObject:@"Times Per Day*"];
            }
            
            if (indexPath.row == 2) {
                [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] arrayParamReminder] replaceObjectAtIndex:3 withObject:@"Day of Month*"];
            }
            else {
                if (indexPath.row == 3) {
                    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] arrayParamReminder] replaceObjectAtIndex:3 withObject:@"Day of Year*"];
                }
                else {
                    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] arrayParamReminder] replaceObjectAtIndex:3 withObject:@"Start Date*"];
                }

            }
            
            [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:@"" forKey:@"TPD"];
            
            [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] tableView] reloadData];
            [self.navigationController popViewControllerAnimated:YES]; 
        }
        if (indexPath.row == 1) {
            SelectDayViewController *selectDayViewController = [[SelectDayViewController alloc] init];
            [self.navigationController pushViewController:selectDayViewController animated:YES];
            [selectDayViewController release];
        }
        if (indexPath.row == 4) {
            allowMultipleTimePerDay = NO;
            NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"RemindeMeView"
                                                              owner:self
                                                            options:nil];
            
            RemindeMeView *remindeMeView = [[nibViews objectAtIndex:0] retain];
            [remindeMeView setUpView];
            remindeMeView.delegate = self;
            remindeMeView.isRemindeMeInAppointment = NO;
            //[self.view addSubview:remindeMeView];
            remindeMeView.frame = CGRectMake(0, 20, 320, 460);
            [appDelegate.window addSubview:remindeMeView];
            // set up an animation for the transition between the views
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.5];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            [[remindeMeView layer] addAnimation:animation forKey:@"SwitchToView1"];
            appDelegate.reminderTime = @"";
        }
    }
    else {
         if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3|| indexPath.row == 1) {
        [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:[arrayFrequency objectAtIndex:indexPath.row] forKey:@"Every"];
        [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] tableView] reloadData];
        [self.navigationController popViewControllerAnimated:YES];
         }
        if (indexPath.row == 4) {
            allowMultipleTimePerDay = NO;
            NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"RemindeMeView"
                                                              owner:self
                                                            options:nil];
            
            RemindeMeView *remindeMeView = [[nibViews objectAtIndex:0] retain];
            [remindeMeView setUpView];
            remindeMeView.delegate = self;
            remindeMeView.isRemindeMeInAppointment = NO;
            //[self.view addSubview:remindeMeView];
            remindeMeView.frame = CGRectMake(0, 20, 320, 460);
            [appDelegate.window addSubview:remindeMeView];
            // set up an animation for the transition between the views
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.5];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            [[remindeMeView layer] addAnimation:animation forKey:@"SwitchToView1"];
            appDelegate.reminderTime = @"";
        }

    }
}

#pragma mark -
#pragma mark RemindeMeViewDelegate
- (void)selectRemindeMe:(NSString *)time {
    if (reminderType==kPrescriptionFill) {
        NSString *str = [[NSString stringWithString:[time stringByReplacingOccurrencesOfString:[[time componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:[NSString stringWithString:[[str stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""]] forKey:@"Every"];
    }
    else {
        NSString *str = [[NSString stringWithString:[time stringByReplacingOccurrencesOfString:[[time componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        appDelegate.frequency = [NSString stringWithString:[[str stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""]];
        
        [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:time forKey:@"Fre"];
        
        [(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] setAllowMultipleTimePerDay:allowMultipleTimePerDay];
        if (!allowMultipleTimePerDay) {
            if (reminderType == kMedication) {
                [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] arrayParamReminder] replaceObjectAtIndex:2 withObject:@"Start Time*"];
                [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:@"" forKey:@"TPD"];
                [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] arrayParamReminder] replaceObjectAtIndex:3 withObject:@"Start Date*"];
            }
            else {
                [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] arrayParamReminder] replaceObjectAtIndex:2 withObject:@"Start Time*"];
                [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:@"" forKey:@"TPD"];
            }
        }
        [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] tableView] reloadData];

    }
       [self.navigationController popViewControllerAnimated:YES];
}
@end
