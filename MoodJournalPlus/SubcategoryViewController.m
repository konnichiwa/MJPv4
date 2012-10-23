

#import "SubcategoryViewController.h"
#import "ParseJSON.h"
#import "YourReminderViewController.h"
#import "SetupAReminderViewController.h"
#import "MedicationDetailViewController.h"
#import "SetupAReminderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RestConnection.h"
#import "SBJSON.h"
#import "ASIHTTPRequest.h"

// Private stuff
@interface SubcategoryViewController ()
- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;
@end


@implementation SubcategoryViewController
@synthesize reminderType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{ 
    NSLog(@"Init");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [searchBar release];
    [viewAddForm release];
    [actionSheet release];
    [dict release];
    [keys release];
    [restConnection release];
    [textFieldAddSubcategory release];
    [indicator release];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.title = @"Medication";
    isHaveTitle = YES;
    indicator.hidden = YES;
    
    keys = [[NSMutableArray alloc] initWithArray: appDelegate.arrayKeys];
    finishLoad = YES;
    if ([keys count] == 0) {
        indicator.hidden = NO;
        [indicator startAnimating];
        finishLoad = NO;
    }
    dict = [[NSMutableDictionary alloc] initWithDictionary:appDelegate.dictionaryMedicationList];
    [tableView reloadData];
    
    viewAddForm.frame = CGRectMake(0, 460, 320, 255);
    [self.view addSubview:viewAddForm];
    [self.view insertSubview:viewAddForm aboveSubview:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMedicationList) name:@"reloadMedicationList" object:nil];
}

- (void) viewDidAppear:(BOOL)animated{
    // Do any additional setup after loading the view from its nib.
    
    [super viewDidAppear:animated];
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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (isHaveTitle) {
        return [keys count];
    }   
    else {
        return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (isHaveTitle) {
        NSString *key = [keys objectAtIndex:section];
        NSArray *nameSection = [dict objectForKey:key];
        return [nameSection count];
    }
	else {
        return [appDelegate.appMedicationList count];
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    if (isHaveTitle) {
        //add for title section alphabet
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];
        NSString *key = [keys objectAtIndex:section];
        NSArray *nameSection = [dict objectForKey:key];
        //------
        cell.textLabel.text=[nameSection objectAtIndex:row];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    else {
        cell.textLabel.text=[appDelegate.appMedicationList objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
	//h: change background color
    //cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reminderDetailBG.png"]] autorelease];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    //end h
	return cell;
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (isHaveTitle) {
        NSString *key = [keys objectAtIndex:section];
        return key;
    }
    else {
        return nil;
    }
}

/*
- (UIView *) tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)aSection 
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, aTableView.bounds.size.width, 30)] autorelease]; 
        [headerView setBackgroundColor:[UIColor whiteColor]];
    UILabel *x = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    x.text =@"ABC";
    [headerView addSubview:x];
    return headerView;
} */

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (isHaveTitle) {
     return keys;   
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *str;
    if (isHaveTitle) {
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];
        NSString *key = [keys objectAtIndex:section];
        NSArray *nameSection = [dict objectForKey:key];
        //------
        str=[nameSection objectAtIndex:row];
    }
    else {
        str = [appDelegate.appMedicationList objectAtIndex:indexPath.row];
    }
    
    
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:str forKey:@"Med"];
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] tableView] reloadData];
    [self.navigationController popViewControllerAnimated:YES];
    
    
    /*
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isHaveTitle) {
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];
        NSString *key = [keys objectAtIndex:section];
        NSArray *nameSection = [dict objectForKey:key];
        
        MedicationDetailViewController *medicationDetailViewController = [[MedicationDetailViewController alloc] init];
        
        for (int i = 0; i < [appDelegate.appMedicationList count]; i++) {
            if ([[[appDelegate.appMedicationList objectAtIndex:i] objectForKey:@"drug_name"] isEqualToString:[nameSection objectAtIndex:row]]) {
                medicationDetailViewController.dictMedicationDetail = [[NSDictionary alloc] initWithDictionary:[appDelegate.appMedicationList objectAtIndex:i]];
                break;
            }
        }
        
        [self.navigationController pushViewController:medicationDetailViewController animated:YES];
        [medicationDetailViewController release];
    }
    else {
        [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:[appDelegate.appMedicationList objectAtIndex:indexPath.row] forKey:@"Med"];
        [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] tableView] reloadData];
        [self.navigationController popViewControllerAnimated:YES];   
    }
     */
}

#pragma mark - 
#pragma mark UISearchBarDelegate 
- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [aSearchBar resignFirstResponder];
    [aSearchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    [aSearchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    [self resetTableViewWithArray:appDelegate.appMedicationList];
    [aSearchBar setShowsCancelButton:NO animated:YES];
    [aSearchBar resignFirstResponder];
    aSearchBar.text = @"";
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchCategorybyName:searchText];
}

#pragma mark -
#pragma mark action
- (void)reloadMedicationList {
    keys = [[NSMutableArray alloc] initWithArray: appDelegate.arrayKeys];
    dict = [[NSMutableDictionary alloc] initWithDictionary:appDelegate.dictionaryMedicationList];
    [tableView reloadData];
    indicator.hidden = YES;
    finishLoad = YES;
}
- (void)resetTableViewWithArray:(NSMutableArray*)array {
    if (dict != nil) {
        [dict release];
        [keys release];
        dict = nil;
        keys = nil;
    }
    dict = [[NSMutableDictionary alloc] init];
    keys = [[NSMutableArray alloc] init];
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
    [tableView reloadData];
    indicator.hidden = YES;
}

- (void)searchCategorybyName:(NSString*)name {
    if (isHaveTitle) {
        NSMutableArray *arrayResultSearch = [[NSMutableArray alloc] init];
        for (int i = 0; i < [appDelegate.appMedicationList count]; i++) {
            NSRange range = [[[[appDelegate.appMedicationList objectAtIndex:i]  lowercaseString] substringToIndex:
                              MIN(name.length, [[[appDelegate.appMedicationList objectAtIndex:i]  lowercaseString] length])
                              ] rangeOfString:[name lowercaseString]];
            if (range.location != NSNotFound) {
                [arrayResultSearch addObject:[appDelegate.appMedicationList objectAtIndex:i]];
            }
        }
        
        [self resetTableViewWithArray:arrayResultSearch];
        [arrayResultSearch release];   
    }
}
- (IBAction)addMedication {

    
    NSString *str = textFieldAddSubcategory.text;
    if(str == nil){
        str = @"Unknow Name";
    }    
    //return;
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] dictParamValueReminder] setObject:str forKey:@"Med"];
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-2] tableView] reloadData];
    [self.navigationController popViewControllerAnimated:YES]; 
}



- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)pressCancelAdd:(id)sender{
    //NSLog(@"Cancel Add");
    viewAddForm.frame = CGRectMake(0, 460, 320, 355);
    CATransition *animation = [CATransition animation];
    textFieldAddSubcategory.text = @"";
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[viewAddForm layer] addAnimation:animation forKey:@"SwitchToView1"];
}

- (IBAction)pressShowAddView:(id)sender{
    if (finishLoad == NO) {
        return;
    }
    viewAddForm.frame = CGRectMake(0, 205, 320, 255);
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[viewAddForm layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    [textFieldAddSubcategory becomeFirstResponder];
    viewAddForm.frame = CGRectMake(0, 105, 320, 355);
    
    
}

- (IBAction)beginPressSubName:(id)sender{
    
    //NSLog(@"Begin Process");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect newFrame = viewAddForm.frame;
    newFrame.origin.y = 105; 
    viewAddForm.frame = newFrame;
    [UIView commitAnimations];
}
- (IBAction)endPressSubName:(id)sender{
    //NSLog(@"end Process");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect newFrame = viewAddForm.frame;
    //viewAddForm.frame.origin.y = 305;
    newFrame.origin.y = 205;
    viewAddForm.frame = newFrame;
    [UIView commitAnimations];
    [sender resignFirstResponder];
     
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self beginPressSubName:nil];
}

#pragma mark -
#pragma mark asihttprequest 
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    finishLoad = YES;
    indicator.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    indicator.hidden = YES;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    SBJSON *parser = [SBJSON new];
    id dataDict = [parser objectWithString:responseData];
    [parser release];
    if ([[dataDict class] isSubclassOfClass:[NSArray class]]) {
        if ([self.navigationController.visibleViewController isKindOfClass:([SubcategoryViewController class])]) {
            appDelegate.appMedicationList = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
            NSLog(@"%@",appDelegate.appMedicationList);
            [self resetTableViewWithArray:appDelegate.appMedicationList];
            appDelegate.appKey = [NSMutableArray arrayWithArray:keys];
            appDelegate.appDict = [NSDictionary dictionaryWithDictionary:dict];
            NSLog(@"save data %d %d ",[appDelegate.appKey count], [appDelegate.appDict count]);
            appDelegate.theFirstLoadMedication = NO;
        }
    }
    finishLoad = YES;
    
    [appDelegate.dictSetting setObject:[NSString stringWithFormat:@"%f",(double)[[NSDate date] timeIntervalSince1970]] forKey:@"date"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                         NSUserDomainMask, YES); 
    
    NSString *cacheDirectory = [paths objectAtIndex:0];  
    NSString *filePath1 = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
    [appDelegate.dictSetting writeToFile:filePath1 atomically:YES];
    
    //write data to text file
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    //NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingString:@"/MedicationList.txt"];
    SBJSON *json = [SBJSON new];
    NSString *str = [json stringWithObject:appDelegate.appMedicationList error:nil];
   //[[appDelegate doCipher:str :kCCEncrypt] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
      [responseData release];
}

@end
