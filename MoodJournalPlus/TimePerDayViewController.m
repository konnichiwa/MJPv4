

#import "TimePerDayViewController.h"
#import "SetupAReminderCell.h"
#import "SetupAReminderViewController.h"

@implementation TimePerDayViewController
@synthesize allowMultipleTimePerDay;
@synthesize timePerDay;
@synthesize isDeleteCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Times Per Day";    }
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
    [arrayTimePerDay release];
    [viewDatePicker release];
    [stringDate release];
    [datePicker release];
    [indexPathSelected release];
    [viewShadowMinute release];
    [reminderTime release];
    //[timePerDay release];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    isDeleteCell = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    indexPathSelected = nil;
    NSLog(@"Time per day %@",timePerDay);
    if (!timePerDay) {
        [timePerDay = [NSString alloc] initWithString:@" "];
    }
    //NSLog(@"%@",timePerDay);
    stringDate = [[NSString alloc] initWithString:[[[[NSDate date] description] componentsSeparatedByString:@" "] objectAtIndex:0]];
    if ([timePerDay isEqualToString:@""]) {
        arrayTimePerDay = [[NSMutableArray alloc] initWithObjects:@"Tap to add", nil];
        arrayTime = [[NSMutableArray alloc] initWithObjects:@" ", nil];
        reminderTime = [[NSString alloc] initWithString:@""];
    }
    else {
        arrayTimePerDay = [[NSMutableArray alloc] init];
        arrayTime = [[NSMutableArray alloc] init];
        reminderTime = [[NSString alloc] initWithString:timePerDay];
        NSArray *array = [timePerDay componentsSeparatedByString:@","];
        for (int i = 0 ; i < [array count]; i++) {
            [arrayTimePerDay addObject:[NSString stringWithFormat:@"%dx Per Day",i+1]];
            [arrayTime addObject:[[array objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        [arrayTimePerDay addObject:[NSString stringWithFormat:@"Tap to add",[array count]+1]];
        [arrayTime addObject:@" "];
    }
    viewDatePicker.hidden = YES;
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
   // NSLog(@"count arraydate %d reminder time %d", [arrayDate count],[arrayTime count]);
    return [arrayTimePerDay count];
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
    //cell.labelReminderParam.text = [arrayTimePerDay objectAtIndex:indexPath.row];
    if (indexPath.row < [arrayTimePerDay count]-1) {
        cell.labelReminderParam.text = [NSString stringWithFormat:@"%dx Per Day",indexPath.row+1];
    }
    else {
        cell.labelReminderParam.text = @"Tap to add";
    }
    cell.labelReminderParamValue.text = [arrayTime objectAtIndex:indexPath.row];
    cell.imageViewItem.image = nil;
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    //end h
	return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPathSelected != nil) {
        [indexPathSelected release];
        indexPathSelected = nil;
    }
    indexPathSelected = [indexPath retain];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPathSelected.row == 0) {
        viewShadowMinute.hidden = YES;
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *str;
        if (indexPath.row != 0) {
            NSString *time = [arrayTime objectAtIndex:0];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            NSDate *date = [formatter dateFromString:time];
            [datePicker setDate:date];
            str = [NSString stringWithString:[formatter stringFromDate:date]];
            [formatter release];
        }
        else {
            str = [NSString stringWithString:[formatter stringFromDate:[NSDate date]]];  
        }
        
        [formatter release];
        
        if ([str rangeOfString:@"M"].location != NSNotFound) {
            viewShadowMinute.frame = CGRectMake(131, 54, 53, 196);
        }
        else {
            viewShadowMinute.frame = CGRectMake(157, 54, 53, 196);
        }
        viewShadowMinute.hidden = NO;
        
    }
    viewDatePicker.hidden = NO;
    
    NSString *time = [arrayTime objectAtIndex:indexPath.row];
    
    if ([time isEqualToString:@" "] == NO) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSDate *date = [formatter dateFromString:time];
        [formatter release];
        [datePicker setDate:date];
    }    

}

#pragma mark
#pragma mark delete cell action
- (void)tableView:(UITableView *)aTableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    isDeleteCell = YES;         
    if ([[[arrayTime objectAtIndex:indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        isDeleteCell = NO;
        return;
    }
    [arrayTime removeObjectAtIndex:indexPath.row];
    [arrayTimePerDay removeObjectAtIndex:indexPath.row];
    [tableView reloadData];    
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*if ([[[arrayTime objectAtIndex:indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        return NO;
     }*/
    if (indexPath.row == [arrayTimePerDay count] - 1) {
        return NO;
    }
    else {
        return isDeleteCell;
    }
}

- (void)tableView:(UITableView *)aTableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    //SetupReminderCell *cell = (SetupReminderCell*)[aTableView cellForRowAtIndexPath:indexPath];
    //cell.switchActive.hidden = YES;
}

- (void)tableView:(UITableView *)aTableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!isDeleteCell) {
        //SetupReminderCell *cell = (SetupReminderCell*)[aTableView cellForRowAtIndexPath:indexPath];
        //cell.switchActive.hidden = NO;   
    }
    isDeleteCell = NO;
}


#pragma mark -
#pragma mark action

- (IBAction)toggleEdit:(id)sender{
    [tableView setEditing:!tableView.editing animated:YES];
	if (tableView.editing){
        isDeleteCell = YES;
        [bottomAction setTitle:@"Done" forState:UIControlStateNormal];
    }
    
	else{
        isDeleteCell = NO;
        [bottomAction setTitle:@"Delete..." forState:UIControlStateNormal];
    }
    [tableView reloadData];
    
}
- (IBAction)done:(id)sender {
    if ([arrayTime count]==1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Please choose at least one time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    //appDelegate.reminderTime = [NSString stringWithString:reminderTime];
    NSLog(@"r 2 %@",appDelegate.reminderTime);
    NSMutableArray *arr2 = [NSMutableArray arrayWithArray:arrayTime];
    [arr2 removeObjectAtIndex:[arr2 count]-1];
    appDelegate.reminderTime =  [arr2 componentsJoinedByString:@","];
    NSLog(@" r %@",appDelegate.reminderTime);
    //NSLog(@"%@",appDelegate.reminderTime);
    if ([arrayTime count] == 1) {
        [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:@"" forKey:@"TPD"];
    }
    else {
     //[[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:[arrayTimePerDay objectAtIndex:[arrayTime count]-2] forKey:@"TPD"];   
        [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:[NSString stringWithFormat:@"%dx Per Day", [arr2 count]] forKey:@"TPD"];

    }
    
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] tableView] reloadData];
    [self.navigationController popToViewController:(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2]  animated:YES];
}
- (IBAction)cancel:(id)sender {
    viewDatePicker.hidden = YES;
}
- (IBAction)setDate:(id)sender {
    viewDatePicker.hidden = YES;
    [stringDate release];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    stringDate = [[NSString alloc] initWithString:[formatter stringFromDate:[datePicker date]]];
    [formatter release];
    
    for (int i = 0; i < [arrayTime count]-1; i++) {
        if (i != indexPathSelected.row) {
            if ([stringDate isEqualToString:[arrayTime objectAtIndex:i]]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Time already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                return;
            }
        }
    }
    
    [arrayTime replaceObjectAtIndex:indexPathSelected.row withObject:stringDate];
    if (indexPathSelected.row >= [arrayTimePerDay count]-1) {
        [arrayTime addObject:@" "];
        [arrayTimePerDay addObject:[NSString stringWithFormat:@"%dx Per Day",[arrayTimePerDay count]+1]];
    }
    if (indexPathSelected.row == 0) {
        NSString *minute;
        if ([stringDate rangeOfString:@"M"].location == NSNotFound) {
            minute = [[stringDate componentsSeparatedByString:@":"] objectAtIndex:1];
        }
        else {
            minute = [[[[stringDate componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
        }
        NSLog(@"---%@",arrayTime);
        for (int i = 1; i < [arrayTime count]-1; i++) {
            NSString *minu;
            if ([[arrayTime objectAtIndex:i] rangeOfString:@"M"].location == NSNotFound) {
                minu = [[[arrayTime objectAtIndex:i] componentsSeparatedByString:@":"] objectAtIndex:1];
            }
            else {
                minu = [[[[[arrayTime objectAtIndex:i] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
            }
            
            NSString *str = [[arrayTime objectAtIndex:i] stringByReplacingOccurrencesOfString:minu withString:minute];
            [arrayTime replaceObjectAtIndex:i withObject:str];
        }
    }
    NSLog(@"%@",arrayTime);
    for (int i = 0; i < [arrayTime count]-1; i++) {
        NSString *time1 = [arrayTime objectAtIndex:i];
        for (int j = i+1; j < [arrayTime count]; j++) {
            NSString *time2 = [arrayTime objectAtIndex:j];
            if ([time2 isEqualToString:time1]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Time already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                return;
            }
        }
    }
    [tableView reloadData];
    
    NSString *str = @"";
    for (int i = 0; i < [arrayTime count] - 1; i++) {
        str = [str stringByAppendingFormat:@" ,%@",[arrayTime objectAtIndex:i]];
    }
    if (reminderTime != nil) {
        [reminderTime release];
    }
    reminderTime = [[NSString alloc] initWithString:[str substringFromIndex:2]];
}

- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
