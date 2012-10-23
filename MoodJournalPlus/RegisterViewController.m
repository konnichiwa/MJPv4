#import "RegisterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "YourReminderViewController.h"
#import "FistRegisterViewController.h"
#import "TermOfUseViewController.h"
#import "SBJSON.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "RestConnection.h"
#import "NSData-AES.h"
#import "Base64.h"
#import "RecordDao.h"
#import "BackgroundService.h"

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Set Up";
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
    [textFieldPassword release];
    [textFieldPassConfirm release];
    [textFieldUserID release];
    [buttonCheckbox release];
    [imageViewBG release];
    [arraySecurityQuestion release];
    [textFieldAnwser release];
    [labelQuestion release];
    [stringQuestion release];
    [stringAnswer release];
    [super dealloc];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    isSave = NO;
    indicator.hidden = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    arraySecurityQuestion = [[NSArray alloc] initWithObjects:@"Mother's maiden name?",
                             @"Favorite high school teacher?",
                             @"Favorite movie name?",
                             @"Favorite pet's name?", @"What is your favorite color?", nil];
    //[self.view addSubview:viewSecurityQuestion];
    //instance app delegate
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    b64UserID = [[NSString alloc] initWithString:@""];
    b64Password = [[NSString alloc] initWithString:@""];
    if (stringQuestion == nil) {
        stringQuestion = @"";
    }
    if (stringAnswer == nil) {
        stringAnswer = @"";
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
- (IBAction)save:(id)sender {
    [self hiddenKeyboard:nil];
    //first time view.
    
    if (!isSave) {
        isValidData = NO;
        if ([textFieldUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 5) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE 
                                                            message:@"User ID should be at least 5 characters long." delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [self.view addSubview:alert];
            [alert show];
            [alert release];
            return;
            
        }
        if (!isCheckBox) {
            //alert to user that they must agree with policy.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE
                                                            message:@"In order to use our services, you must agree to our Terms of Use and Privacy Policy." delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [self.view addSubview:alert];
            [alert show];
            [alert release];
            return;
        }
        //password is not correct
        if (![textFieldPassword.text isEqualToString:textFieldPassConfirm.text]) {
            isValidData  = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE
                                                            message:@"Password and Confirm Password do not match." delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [self.view addSubview:alert];
            [alert show];
            [alert release];
            return;
        }
        if (![[textFieldUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
            
            isValidData = YES;
        }
    }
    
    if (isValidData && !isSave) {
        //appDelegate.userID = [NSString stringWithString:[textFieldUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        //appDelegate.password = 
        //[NSString stringWithString:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        index = 0;
        isSave = YES;
        indicator.hidden = NO;
        [indicator startAnimating];
        [self hiddenKeyboard:nil];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        
        restConnection = [[RestConnection alloc] init];
        restConnection.viewController = self;
        [restConnection postDataWithPathSource:@"/rest/User" andParam:arr withPostData:[self createJSON]];
        [arr release];
    }
    else {
        if (!isValidData) {
            NSString *message = @"Please enter  ";
            if ([[textFieldUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) { //userID textfield is blank
                message = [message stringByAppendingString:@"UserID, "];
            }
            
            if ([[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) { //Password textfield is blank
                message = [message stringByAppendingString:@"Password, "];
            }
            
            message = [[message substringToIndex:message.length-2] stringByAppendingString:@"."];//remove 2 last characters
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    }
}

- (IBAction)hiddenKeyboard:(id)sender {
    [textFieldPassConfirm resignFirstResponder];
    [textFieldPassword resignFirstResponder];
    [textFieldUserID resignFirstResponder];
    [textFieldAnwser resignFirstResponder];
}

- (IBAction)checkBox:(id)sender {
    isCheckBox = !isCheckBox;
    if (isCheckBox) {
        [buttonCheckbox setImage:[UIImage imageNamed:@"tickImage.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonCheckbox setImage:nil forState:UIControlStateNormal];
    }
    
}

- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)setSecurityQuestion:(id)sender {
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

- (IBAction)answerEditor:(id)sender{
    stringQuestion = [labelQuestion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([stringQuestion isEqualToString:@""]||[stringQuestion isEqualToString:@"Select the Security Question"]) {
        //call editor.
        [self setSecurityQuestion:nil];
        [textFieldAnwser resignFirstResponder];
        return;
    }
    else{
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect newFrame = self.view.frame;
        newFrame.origin.y = -200;
        self.view.frame = newFrame;
        [UIView commitAnimations];
        NSLog(@"Press Register");
    }
}

- (IBAction)endAnswerEditor:(id)sender{
    [sender resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = 0;
    self.view.frame = newFrame;
    [UIView commitAnimations];
}
- (void)dismissSecurityQuestionView {
    
}

- (IBAction)saveSecurityQuestion:(id)sender {
    
}


- (IBAction)pressTermOfUse:(id)sender{
    if(appDelegate.isHaveInternetConnection)
    {
        TermOfUseViewController *t = [[TermOfUseViewController alloc] init];
        //[t loadDetail:6];
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
- (IBAction)pressPrivacy:(id)sender{
    if(appDelegate.isHaveInternetConnection)
    {
        TermOfUseViewController *t = [[TermOfUseViewController alloc] init];
        [t loadDetail:1];
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
- (IBAction)checkUserID:(id)sender {
    NSString *userName = [[textFieldUserID text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([userName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Please enter your UserID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {
        if ([textFieldUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 5) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE
                                                            message:@"User ID must have more 5 characters." delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [self.view addSubview:alert];
            [alert show];
            [alert release];
            return;
            
        }
        else {
            if (!isChecking) {
                indicator.hidden = NO;
                [indicator startAnimating];
                isChecking = YES;
                index = 5;
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
                NSLog(@"%@",[appDelegate doCipher:userName :kCCEncrypt]);
                NSLog(@"%@", [appDelegate doCipher:[appDelegate doCipher:userName :kCCEncrypt] :kCCDecrypt]);
                [arr addObject:[NSMutableDictionary dictionaryWithObject:[[appDelegate doCipher:userName :kCCEncrypt] stringByReplacingOccurrencesOfString:@"+" withString:@""] forKey:@"username"]];
                
                restConnection = [[RestConnection alloc] init];
                restConnection.viewController = self;
                [restConnection getDataWithPathSource:@"/rest/User/username" andParam:arr forService:@"checkUserID"];
                
                [arr release];
                
            }
        }
    }
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
    labelQuestion.text = [arraySecurityQuestion objectAtIndex:indexPath.row];
    if (labelQuestion.text != nil) {
        stringQuestion = [labelQuestion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if (textFieldAnwser.text != nil) {
        stringAnswer = [textFieldAnwser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    if ([textFieldAnwser.text isEqualToString:@""]) {
        [textFieldAnwser becomeFirstResponder];
    }
}
#pragma mark -
#pragma mark action
- (NSString*)createJSON {
    NSString *userID = [textFieldUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    b64UserID = [appDelegate doCipher:userID :kCCEncrypt];
    NSString *password;  
    password = [textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    b64Password = [appDelegate doCipher:password :kCCEncrypt]; 
    //set, encrypt security question
    
    NSString *b64Question;
    NSString *b64Ans;
    stringQuestion = [labelQuestion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    stringAnswer = [textFieldAnwser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([stringQuestion isEqualToString:@""]) {
        b64Question = @"";
    }else{
        b64Question = stringQuestion;
    }
    if ([stringAnswer isEqualToString:@""]) {
        b64Ans = @"";
    }else{
        b64Ans = [appDelegate doCipher:stringAnswer :kCCEncrypt];
    }
    //set stringQuestion if exists
    /*
     NSMutableDictionary *m = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     b64UserID,@"username",
     b64Password,@"password",
     @"MOODJOURNAL",@"appname"
     , nil];
     SBJSON *s = [[SBJSON alloc] init];
     NSString *json = [s stringWithObject:m error:nil];
     */
    NSString *json = [NSString stringWithFormat: @"{\"userID\":0,\"username\":\"%@\",\"password\":\"%@\",\"lastModifiedDate\":0,\"creationDate\":0,\"userResources\":[{\"userresourceid\":0,\"propertyname\":\"appname\",\"propertytypeid\":700603,\"propertyvalue\":\"MOODJOURNAL\",\"propertyvaluenumber\":0,\"propertyvaluedate\":0,\"groupid\":0}],\"userPreferences\":[{\"userpreferenceid\":0,\"propertyname\":\"securityQuestion\",\"propertytypeid\":1998890,\"propertyvalue\":\"%@\",\"propertyvaluenumber\":0,\"propertyvaluedate\":0,\"groupid\":0},{\"userpreferenceid\":0,\"propertyname\":\"securityAnswer\",\"propertytypeid\":1998891,\"propertyvalue\":\"%@\",\"propertyvaluenumber\":0,\"propertyvaluedate\":0,\"groupid\":0},{\"userpreferenceid\":0,\"propertyname\":\"email\",\"propertytypeid\":1998892,\"propertyvalue\":\"\",\"propertyvaluenumber\":0,\"propertyvaluedate\":0,\"groupid\":0},{\"userpreferenceid\":0,\"propertyname\":\"gender\",\"propertytypeid\":1998893,\"propertyvalue\":\"\",\"propertyvaluenumber\":0,\"propertyvaluedate\":0,\"groupid\":0},{\"userpreferenceid\":0,\"propertyname\":\"age\",\"propertytypeid\":1998894,\"propertyvalue\":\"\",\"propertyvaluenumber\":0,\"propertyvaluedate\":0,\"groupid\":0},{\"userpreferenceid\":0,\"propertyname\":\"maritalStatus\",\"propertytypeid\":1998895,\"propertyvalue\":\"\",\"propertyvaluenumber\":0,\"propertyvaluedate\":0,\"groupid\":0},{\"userpreferenceid\":0,\"propertyname\":\"mobilenumber\",\"propertytypeid\":2058778,\"propertyvalue\":\"\",\"propertyvaluenumber\":0,\"propertyvaluedate\":0,\"groupid\":0}]}",b64UserID,b64Password,b64Question,b64Ans];
    NSLog(@"Send JSon: %@",json);
    return json;
}


#pragma mark -
#pragma mark Restconnection Delegate
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    isChecking = NO;
    indicator.hidden = YES;
    isSave = NO;
    //if (isLogin) {
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@" respond Data: %@",responseData);
    [responseData release];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    //isLogin = NO;
    //}
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"respondata: %@",responseData);
    SBJSON *parser = [SBJSON new];
    NSDictionary *dataDict = (NSDictionary*)[parser objectWithString:responseData];
    //NSLog(@"%@",dataDict);
    [parser release];
    if (index == 3) {//get respond from push notification, do nothing
        [responseData release];
        return;
    }
    if (index == 5) {
        indicator.hidden = YES;
        isChecking = NO;
        if ([responseData isEqualToString:@"true"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"UserID available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else 
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"UserID already exists" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        [responseData release];
        return;
    }
    if (index == 0) { //sign up successfully
        NSLog(@"----------------");
        if ([[dataDict objectForKey:@"status"] isEqualToString:@"ACTIVE"]) {
            [appDelegate.backgroundService unregisterPushNotification];
            //register successfully --> login
            index = 1;
            NSMutableArray *arr2 = [[NSMutableArray alloc] init];
            [arr2 addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
            
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appname forKey:@"appname"]];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceID"]];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:deviceType forKey:@"deviceType"]];
            
            NSString *userID = [textFieldUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *password = [textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            userID = [appDelegate doCipher:userID :kCCEncrypt];
            password = [appDelegate doCipher:password :kCCEncrypt];
            [appDelegate.dictSetting setObject:userID forKey:@"userID"]; 
            [appDelegate.dictSetting setObject:password forKey:@"password"]; 
            [arr addObject:[NSMutableDictionary dictionaryWithObject:password forKey:@"password"]];
            
            [arr addObject:[NSMutableDictionary dictionaryWithObject:userID forKey:@"username"]];
            restConnection = nil;
            restConnection = [[RestConnection alloc] init];
            restConnection.viewController = self;
            [restConnection postDataWithPathSource2:@"/rest/Auth" andParam:arr2 withPostData:arr];
            [arr release];
            [arr2 release];
            
            //clear cache data
            // write data to text file 
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
            NSString *cacheDirectory = [paths objectAtIndex:0];
            NSArray *cacheDirectoryFile = [[NSFileManager defaultManager] directoryContentsAtPath:cacheDirectory];
            for (int i = 0; i < [cacheDirectoryFile count]; i++) {
                if ([[cacheDirectoryFile objectAtIndex:i] rangeOfString:@".txt"].location != NSNotFound && [[cacheDirectoryFile objectAtIndex:i] rangeOfString:@"MedicationList"].location == NSNotFound) {
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
            
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            RecordDao *recordDao = [[RecordDao alloc] init];
            recordDao.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
            [recordDao deleteAllData];
            [recordDao.tableName release];
            recordDao.tableName = [[NSString alloc] initWithString:SETUP_REMINDER_TABLE];
            [recordDao deleteAllData];
            [recordDao release];
            
        }
        else {
            NSLog(@"----------------");
            indicator.hidden = YES;
            isSave = NO;
            NSString *message = [dataDict objectForKey:@"Description"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }  
    }
    else { //login successfully
        NSLog(@"----------------");
        appDelegate.deviceToken = [NSString stringWithString:[dataDict objectForKey:@"deviceToken"]]; 
        NSLog(@"%@",appDelegate.dictSetting);
        [appDelegate.dictSetting setObject:[appDelegate doCipher:[textFieldUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] :kCCEncrypt] forKey:@"userID"];
        if (isCheckBox) {//Remember password  
            //[appDelegate.dictSetting setObject:@"1" forKey:@"checkBox"];
        }
        else {
            [appDelegate.dictSetting setObject:[appDelegate doCipher:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] :kCCEncrypt] forKey:@"password"];
            [appDelegate.dictSetting setObject:@"0"
                                        forKey:@"rememberPass"];
            //[appDelegate.dictSetting setObject:@"0" forKey:@"checkBox"];
        }
        [appDelegate.dictSetting setObject:
         [appDelegate doCipher:[appDelegate.deviceToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                    forKey:@"token"];  
        NSLog(@"%@",appDelegate.dictSetting);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
        [appDelegate.dictSetting writeToFile:filePath atomically:YES];
        
        indicator.hidden = YES;
        
        appDelegate.isFirstSignUp = YES;
        FistRegisterViewController *f = [[FistRegisterViewController alloc] init];
        [self.navigationController pushViewController:f animated:YES];
        [f release];
        
        if (![responseData isEqualToString:@"{Status: \"SUCCESS\"}"]) {
            NSLog(@"register pushnotification failed!");
        }
        //request to push notification
        if (appDelegate.pushNotificationToken != nil) {
            NSLog(@"Sent request push notification");
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:APPPUSH forKey:@"apppush"]];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
            
            restConnection = [[RestConnection alloc] init];
            restConnection.viewController = self;
            NSMutableArray *arr2 = [[NSMutableArray alloc] init];
            [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.pushNotificationToken forKey:@"notification_token"]];
            [arr2 addObject:[NSMutableDictionary dictionaryWithObject:@"ACTIVE" forKey:@"status"]];
            NSLog(@"Send connection %@ Notification %@",arr, arr2);
            [restConnection postDataWithPathSource2:@"/rest/Notification" andParam:arr withPostData:arr2];
            [arr release];
            [arr2 release];
            index = 3;
        }
        [appDelegate.backgroundService getMedicationList];
        [appDelegate.backgroundService registerPushNotification];
        //end request to push notification
    }
    [responseData release];
}
@end
