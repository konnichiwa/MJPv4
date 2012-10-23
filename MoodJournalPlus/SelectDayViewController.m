

#import "SelectDayViewController.h"
#import "SetupAReminderCell.h"
#import "SetupAReminderViewController.h"
#import "AppDelegate.h"

@implementation SelectDayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Select Days";
        UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
        self.navigationItem.rightBarButtonItem = buttonDone;
        [buttonDone release];
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
    [arrayDate release];
    [arrayCheck release];
}

- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    arrayDate = [[NSMutableArray alloc] initWithObjects:@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday", nil];
    arrayCheck = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0", nil];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayDate count];
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    cell.labelReminderParam.text = [arrayDate objectAtIndex:indexPath.row];
    cell.labelReminderParamValue.text = nil;
    cell.imageViewItem.image = nil;
    
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = indexPath.row;
    SetupAReminderCell *cell = (SetupAReminderCell*)[tableView cellForRowAtIndexPath:indexPath];
    if ([[arrayCheck objectAtIndex:row] isEqualToString:@"0"]) {
        [[cell imageViewAccessory] setHidden:YES];
        [arrayCheck replaceObjectAtIndex:row withObject:@"1"];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [[cell imageViewAccessory] setHidden:NO];
        [arrayCheck replaceObjectAtIndex:row withObject:@"0"];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
}

#pragma mark -
#pragma mark action
- (void)done {
    NSString *string = @"Weekly: ";

    for (int i = 0; i < [arrayCheck count]; i++) {
        if ([[arrayCheck objectAtIndex:i] isEqualToString:@"1"]) {
            string = [string stringByAppendingFormat:@"%@,",[[arrayDate objectAtIndex:i] substringToIndex:3]];
        }
    }
    string = [string substringToIndex:string.length-1];
    if ([string length]<9) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Please select at least one day." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];  
        [alert show];
        [alert release];
        return;
    }  
    appDelegate.frequency = [NSString stringWithString:string];
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] dictParamValueReminder] setObject:string forKey:@"Fre"];
    [(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] setAllowMultipleTimePerDay:YES];
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] arrayParamReminder] replaceObjectAtIndex:2 withObject:@"Times Per Day*"];
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] arrayParamReminder] replaceObjectAtIndex:3 withObject:@"Start Date*"];
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] dictParamValueReminder] setObject:@"" forKey:@"TPD"];
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] tableView] reloadData];
    
    
    [self.navigationController popToViewController:(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3]  animated:YES];
}
@end
