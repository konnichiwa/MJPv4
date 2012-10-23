#import "AccountSettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "YourReminderViewController.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import "RestConnection.h"
#import "SBJSON.h"
#import "ChangePassViewController.h"

@implementation AccountSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Update Account";
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
    [arraySecurityQuestion release];
    [textFieldAnwser release];
    [textFieldPassword release];
    [textFieldUserID release];
    [textFieldQuestion release];
    [labelSecurityQuestion release];
    [viewSecurityQuestion release];
    [asGender release];
    [asMaterialStatus release];
    [asAge release];
    [super dealloc];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //NSLog(@"Dict setting %@",appDelegate.dictSetting);
    // Do any additional setup after loading the view from its nib.
    arraySecurityQuestion = [[NSArray alloc] initWithObjects:@"Mother's maiden name?",@"Favorite high scholl teacher?",@"Favorite movie name?",@"Favorite pet's name?", @"What is your favorite color?",nil];
    viewSecurityQuestion.frame = CGRectMake(0, 480, 320, 460);
    [self.view addSubview:viewSecurityQuestion];
    asGender = [[UIActionSheet alloc] initWithTitle:@"Choose your gender" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Male", @"Female",@"Transgender", nil];
    
    
    asMaterialStatus  = [[UIActionSheet alloc] initWithTitle:@"Choose your marital status" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Single",@"Engaged", @"Married", @"Widowed",@"Divorced", @"Domestic Partner", nil];
    
    asAge  = [[UIActionSheet alloc] initWithTitle:@"Please specify your age range" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"18 and lower",@"19-25", @"26-40", @"41-60",@"60 and above", nil];
    
    textFieldQuestion.text = @"";
    //custom title font size.
    /*
    CGRect oldFrame = CGRectMake(0, 0, 320, 50);
    UILabel *newTitle = [[UILabel alloc] initWithFrame:oldFrame];
    newTitle.font = [UIFont boldSystemFontOfSize:20];
    newTitle.textAlignment = UITextAlignmentCenter;
    newTitle.backgroundColor = [UIColor clearColor];
    newTitle.textColor = [UIColor whiteColor];
    newTitle.text = @"Choose your gender"; 
    [asGender addSubview:newTitle];
    newTitle.text = @"Choose your marital status";
    [asMaterialStatus addSubview:newTitle];    
    [newTitle release];*/
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //get user info
    restConnection = [[RestConnection alloc]  init];
    NSMutableArray *arr =[[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    
    if (appDelegate.deviceToken != nil) {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    }
    else {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    
    restConnection.viewController = self;
    [indicator startAnimating];
    [restConnection getDataWithPathSource:@"/rest/User" andParam:arr forService:@"Get User"];
    numConnection = 0;
    [arr release];
    index = 0;
    isSave = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hiddenKeyboard:nil];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark action
- (IBAction)hiddenKeyboard:(id)sender {
    [textFieldUserID resignFirstResponder];
    [textFieldPassword resignFirstResponder]; 
    [textFieldEmail resignFirstResponder];
    [textfieldAge resignFirstResponder];
    [textFieldQuestion resignFirstResponder];
    [textFieldAnwser resignFirstResponder];
    [sender resignFirstResponder];
}


- (IBAction)setSecurityQuestion:(id)sender {
    [self hiddenKeyboard:nil];
    if (!isShowSecurityQuestionView) {
        isShowSecurityQuestionView = YES;
        [viewSecurityQuestion setFrame:CGRectMake(0, 0, 320, 460)];
        // set up an animation for the transition between the views
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromTop];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[viewSecurityQuestion layer] addAnimation:animation forKey:@"SwitchToView1"];
        
        UIBarButtonItem *buttonAdd = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissSecurityQuestionView)];
        self.navigationItem.leftBarButtonItem = buttonAdd;
        [buttonAdd release]; 
    }
}

- (void)dismissSecurityQuestionView {
    isShowSecurityQuestionView = NO;
    [viewSecurityQuestion setFrame:CGRectMake(0, 480, 320, 460)];
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	[[viewSecurityQuestion  layer] addAnimation:animation forKey:kCATransition];
    
    self.navigationItem.leftBarButtonItem = nil;
}

- (IBAction)saveChange:(id)sender {
    //save data
    if (isSave == YES||index==0) {
        return;
    }
    isSave = YES;
    NSArray *properties = [dataDict objectForKey:@"userPreferences"];
    NSLog(@"%@",properties);
    for (int i = 0; i < [properties count]; i++) {
        NSLog(@"Property name %@",[[properties objectAtIndex:i] objectForKey:@"propertyname"]);
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"securityQuestion"]) {
            [[[dataDict objectForKey:@"userPreferences"] objectAtIndex:i] setObject:textFieldQuestion.text  forKey:@"propertyvalue"];
        }
        
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"securityAnswer"]) {
            [[[dataDict objectForKey:@"userPreferences"] objectAtIndex:i] setObject:[appDelegate doCipher:textFieldAnwser.text: kCCEncrypt] forKey:@"propertyvalue"];
        }
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"email"]) {
            if ([textFieldEmail.text isEqualToString:@"Optional"]) {
                [[[dataDict objectForKey:@"userPreferences"] objectAtIndex:i] 
                 setObject: @"" 
                 forKey:@"propertyvalue"];
            }
            else {
                [[[dataDict objectForKey:@"userPreferences"] objectAtIndex:i] 
                 setObject: [appDelegate doCipher:textFieldEmail.text :kCCEncrypt] 
                 forKey:@"propertyvalue"];
            }
        }
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"gender"]) {
            [[[dataDict objectForKey:@"userPreferences"] objectAtIndex:i] setObject:labelGender.text forKey:@"propertyvalue"];
        }
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"age"]) {
            [[[dataDict objectForKey:@"userPreferences"] objectAtIndex:i] setObject:textfieldAge.text forKey:@"propertyvalue"];
        }
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:@"maritalStatus"]) {
            [[[dataDict objectForKey:@"userPreferences"] objectAtIndex:i] setObject:labelMaterialStatus.text forKey:@"propertyvalue"];
        }
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    SBJSON *sb = [SBJSON new];
    
    NSString *json = [sb stringWithObject:dataDict];
    NSLog(@"json: %@",json);
    [restConnection putDataWithPathSource:@"/rest/User" andParam:arr withPostData:json];
    
    [sb release];
    [arr release];
}
//action of security question

- (IBAction)saveSecurityQuestion:(id)sender {
    //check if user press the answer or not???
    NSString *ansCheck = [[NSString alloc] initWithString:[textFieldAnwser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    if ([[textFieldQuestion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Please select a security question." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [ansCheck release];
        return;
    }
    if ([ansCheck isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Please provide security question answer." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [ansCheck release];
        return;
    }
    
    [ansCheck release];
    isShowSecurityQuestionView = NO;
    [viewSecurityQuestion setFrame:CGRectMake(0, 480, 320, 460)];
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	[[viewSecurityQuestion  layer] addAnimation:animation forKey:kCATransition];
    
    self.navigationItem.leftBarButtonItem = nil;
    [self hiddenKeyboard:nil];
    [textFieldAnwser resignFirstResponder];
}

- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressChangeGender:(id)sender{
 //show change gender action sheet
    [self exitAgeEditor:nil];
    [self hiddenKeyboard:nil];
    [asGender showInView:self.view];
}
- (IBAction)pressChangeMaterialStatus:(id)sender{
    [self exitAgeEditor:nil];
    [self hiddenKeyboard:nil];
    [asMaterialStatus showInView:self.view];
}
- (IBAction)pressChangeAge:(id)sender {
    [self exitAgeEditor:nil];
    [self hiddenKeyboard:nil];
    [asAge showInView:self.view];
}

- (IBAction)ageEditor:(id)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = -220;
    self.view.frame = newFrame;
    [UIView commitAnimations];
}
- (IBAction)exitAgeEditor:(id)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = 0;
    self.view.frame = newFrame;
    [UIView commitAnimations];
    
}
- (IBAction)pressChangePassword:(id)sender{
    ChangePassViewController *c = [[ChangePassViewController alloc]  init];
    [self.navigationController pushViewController:c animated:YES];
    [c release];
}
- (IBAction)showQuestionList:(id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please select security question." message:@"\n\n\n\n\n\n\n\n\n\n" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 50, 261, 185) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.delegate = self;
    tableView.dataSource = self;
    [alertView addSubview:tableView];
    [tableView release];
    [alertView show];
    [alertView release];
    [self hiddenKeyboard:nil];
}
- (IBAction)clickToEdit:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
            
            break;
            
        default:
            break;
    }
}
- (IBAction)answerEditor:(id)sender{
    NSLog(@"question %@", textFieldQuestion.text);
    if ([[textFieldQuestion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]
        ||[textFieldQuestion.text isEqualToString:@"Select the Security Question"]) {
        [self showQuestionList:nil];
    }
}
- (IBAction)editEmail{
    [textFieldEmail becomeFirstResponder];
}
- (IBAction)editAge{
    [textfieldAge becomeFirstResponder];
}
#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == textFieldQuestion) {
        [self hiddenKeyboard:nil];
        //show question security
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please select security question." message:@"\n\n\n\n\n\n\n\n\n\n" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 50, 261, 185) style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.delegate = self;
        tableView.dataSource = self;
        [alertView addSubview:tableView];
        [tableView release];
        [alertView show];
        [alertView release];
    }
    else {
        textFieldEmail.text = @"";
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hiddenKeyboard:nil];
    return YES;
}


- (NSString *)getProperty: (NSString *)key forData: (NSDictionary *)dataList{
    NSArray *properties;
    NSString *value=@"";
    properties = [dataList objectForKey:@"userPreferences"];
    for (int i = 0; i <[properties count]; i++) {
        //NSLog(@"data %d la %@",i,[properties objectAtIndex:i]);
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyname"] isEqualToString:key]) {
            value = [NSString stringWithString:[[properties objectAtIndex:i] objectForKey:@"propertyvalue"]];
            break;
        }
             }
    return value;
    }

#pragma mark - 
#pragma mark touch to screen.
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    NSLog(@"X: %f",location.x);
    NSLog(@"Y: %f",location.y);
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arraySecurityQuestion count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.textLabel.text = [arraySecurityQuestion objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    textFieldQuestion.text = [arraySecurityQuestion objectAtIndex:indexPath.row];
    labelSecurityQuestion.text = textFieldQuestion.text;
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == asGender) {
        if (buttonIndex == 3) {
            return;
        }
        labelGender.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        
    }
    else {
        if (actionSheet == asMaterialStatus) {
            if (buttonIndex == 6) {
                return;
            }
            labelMaterialStatus.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        else {
            if (buttonIndex == 5) {
                return;
            }
            textfieldAge.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
    }
}

#pragma mark -
#pragma mark Restconnection Delegate
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    indicator.hidden = YES;
    isSave = NO;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    SBJSON *parser = [SBJSON new];
    NSLog(@"respond %@, request: %@",responseData, [theRequest responseData]);
    NSDictionary *n = [NSDictionary dictionaryWithDictionary:[parser objectWithString:responseData]];
    [parser release];
    [responseData release];
    NSString *message;
    if ([n objectForKey:@"Description"] != nil) {
        message = [n objectForKey:@"Description"];
    }
    else {
        message = @"Limited or no connection detected. Try again later or use WIFI.";
    }
    
    if (message !=nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.view addSubview:alert];
        [alert show];
        [alert release];
    }
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    indicator.hidden = YES;
    isSave = NO;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    SBJSON *parser = [SBJSON new];
    NSDictionary *n = [NSDictionary dictionaryWithDictionary:[parser objectWithString:responseData]];
    NSString *message = [n objectForKey:@"Description"];
    if (message !=nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        [parser release];
        [responseData release];
        
        return;
    }
    switch (index) {
        case 0:
        {
            
            dataDict = [[NSMutableDictionary alloc] initWithDictionary:[parser objectWithString:responseData]];
            NSLog(@"Respond data: %@",responseData);
            //get info of account, display it //
            textFieldUserID.text = [appDelegate doCipher:[dataDict objectForKey:@"username"] :kCCDecrypt];
            textFieldQuestion.text = [self getProperty:@"securityQuestion" forData:dataDict];
            if (![[self getProperty:@"email" forData:dataDict] isEqualToString:@""]) {
                textFieldEmail.text = [appDelegate doCipher:[self getProperty:@"email" forData:dataDict] :kCCDecrypt];
            }
            if (![[textFieldQuestion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                labelSecurityQuestion.text = textFieldQuestion.text;
            }
            if (![[self getProperty:@"gender" forData:dataDict] isEqualToString:@""]) {
                labelGender.text = [self getProperty:@"gender" forData:dataDict];
            }
            if (![[self getProperty:@"maritalStatus" forData:dataDict] isEqualToString:@""]) {
                labelMaterialStatus.text = [self getProperty:@"maritalStatus" forData:dataDict];
            }
            if (![[self getProperty:@"age" forData:dataDict] isEqualToString:@""]) {
                textfieldAge.text =[self getProperty:@"age" forData:dataDict];
            }
            index = 1;
            if (![[self getProperty:@"securityAnswer" forData:dataDict] isEqualToString:@""]) {
                textFieldAnwser.text = [appDelegate doCipher:[self getProperty:@"securityAnswer" forData:dataDict] :kCCDecrypt];
            }
        }
            break;
        case 1:
        {                       
            YourReminderViewController *y = [[YourReminderViewController alloc] initWithNibName:@"YourReminderView" bundle:nil]; 
            [self.navigationController pushViewController:y animated:YES];  
            [y release];
        }
            break;
        default:
            break;
    }
    [parser release];
    [responseData release];
}
@end
