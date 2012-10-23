

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "YourReminderViewController.h"
#import "ForgotPassViewController.h"
#import "ReminderDetailViewController.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "RestConnection.h"
#import "FistRegisterViewController.h"
#import "BackgroundService.h"

@implementation LoginViewController
@synthesize textFieldUserName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    [textFieldPassword release];
    [textFieldUserName release];
    [buttonRemember release];
    [labelUserName release];
    [indicator release];
    [super dealloc];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate.dictSetting objectForKey:@"userID"] isEqualToString:@"0"]) {
        welcomeBack.text = [NSString stringWithFormat:@"Welcome back, %@",
                            [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"userID"] :kCCDecrypt]];
        
        if ([[appDelegate.dictSetting objectForKey:@"rememberPass"] isEqualToString:@"1"]) {
            isRememberPassword = YES;
        }
    }
    textFieldUserName.text= [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"userID"] :kCCDecrypt];
    if ([[appDelegate.dictSetting objectForKey:@"rememberPass"] isEqualToString:@"1"]) {
        textFieldPassword.text = [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"password"] :kCCDecrypt];
        NSLog(@"%d",isRememberPassword);
        if (isRememberPassword) {
            [buttonRemember setImage:[UIImage imageNamed:@"tickImage.png"] forState:UIControlStateNormal];
        }
        else {
            [buttonRemember setImage:nil forState:UIControlStateNormal];
        }
        
    }
    else{
        textFieldPassword.text = @"";
    }
    indicator.hidden = YES;
    
    UIView *paddingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)] autorelease];
    textFieldUserName.leftView = paddingView;
    textFieldUserName.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView2 = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)] autorelease];
    textFieldPassword.leftView = paddingView2;
    textFieldPassword.leftViewMode = UITextFieldViewModeAlways;
    
    //view did load 
    
    //[paddingView release];
}

- (void)viewDidAppear:(BOOL)animated{
    //textFieldUserName.text= [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"userID"] :kCCDecrypt];
    if ([[appDelegate.dictSetting objectForKey:@"rememberPass"] isEqualToString:@"1"]) {
        textFieldPassword.text = [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"password"] :kCCDecrypt];
    }
    textFieldUserName.text = [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"userID"] :kCCDecrypt];
    [super viewDidAppear:animated];
    [self checkForInternetConnection];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)checkForInternetConnection{
    indicator.hidden=YES;
    if(!appDelegate.isFirstConnectionTested)
    {
         [self performSelector:@selector(checkForInternetConnection) withObject:nil afterDelay:1.0];
    }
    else if(!appDelegate.isHaveInternetConnection && !appDelegate.isAirplaneModeSet)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again or use Airplane Mode." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Airplane Mode", nil];        
        [self.view addSubview:alert];
        [alert show];
        [alert release];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        appDelegate.isAirplaneModeSet=YES;
        NSNotification *notification = [NSNotification notificationWithName:@"reloadBanner" object:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
    }
    else if(buttonIndex == 0)
    {
        indicator.hidden=NO;
        [self performSelector:@selector(checkForInternetConnection) withObject:nil afterDelay:2.0];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark action
- (IBAction)hiddenKeyboard:(id)sender {
    [textFieldPassword resignFirstResponder];
    if (textFieldUserName.hidden == NO) {
        [textFieldUserName resignFirstResponder];
    }
    
}

- (IBAction)rememberPassword:(id)sender {
    [self hiddenKeyboard:nil];
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        if (isRememberPassword) {
            [buttonRemember setImage:nil forState:UIControlStateNormal];
        }
        else {
            [buttonRemember setImage:[UIImage imageNamed:@"tickImage.png"] forState:UIControlStateNormal];
        }
    }
                    completion:nil];
    isRememberPassword = !isRememberPassword;
}



- (IBAction)login:(id)sender {
    if (appDelegate.isHaveInternetConnection && [[appDelegate.dictSetting objectForKey:@"userID"] isEqualToString:@""]) { //login
            NSString *userID;
            NSString *password;
            [self hiddenKeyboard:nil];
            //NSLog(@"pas %@, user %@",textFieldPassword.text, textFieldUserName.text);
            if (!isLogin) {
                
                //login by Password
                if ([[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Please enter userID and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                    indicator.hidden = YES;
                    return;
                }
                if ([[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                    textFieldUserName.text = [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"userID"] :kCCDecrypt];
                }    
                appDelegate.userID = [NSString stringWithString:[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                
                appDelegate.password = [NSString stringWithString:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                
                userID = [textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                password = [textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                userID = [appDelegate doCipher:userID :kCCEncrypt];
                password = [appDelegate doCipher:password: kCCEncrypt];
                //rest connection 
                isLogin = YES;
                indicator.hidden = NO;
                [indicator startAnimating];
                
                NSMutableArray *arr2 = [[NSMutableArray alloc] init];
                [arr2 addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
                
                
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                [arr addObject:[NSMutableDictionary dictionaryWithObject:appname forKey:@"appname"]];
                [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceID"]];
                [arr addObject:[NSMutableDictionary dictionaryWithObject:deviceType forKey:@"deviceType"]];
                [arr addObject:[NSMutableDictionary dictionaryWithObject:password forKey:@"password"]];
                [arr addObject:[NSMutableDictionary dictionaryWithObject:userID forKey:@"username"]];
                restConnection = nil;
                restConnection = [[RestConnection alloc] init];
                restConnection.viewController = self;
                [restConnection postDataWithPathSource2:@"/rest/Auth" andParam:arr2 withPostData:arr];
                [arr release];
                [arr2 release];
            }
        }
        else {
            NSString *pin = [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"password"] :kCCDecrypt];
            
            if ([[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) { //PIN textfield is blank
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Please enter Password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                return;
            }
            if (![[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:pin]) { //wrong Password
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Wrong Password. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                return;
            }
            if (isRememberPassword) {
                [appDelegate.dictSetting setObject:@"1"
                                            forKey:@"rememberPass"]; 
                
            } 
            else{
                [appDelegate.dictSetting setObject:@"0"
                                            forKey:@"rememberPass"];
            }
            
            [appDelegate.dictSetting setObject:
             [appDelegate doCipher:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                        forKey:@"password"]; 
            [appDelegate.dictSetting setObject:
             [appDelegate doCipher:[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                        forKey:@"userID"];    
            
            //Cache data ---------------
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                                 NSUserDomainMask, YES); 
            
            NSString *cacheDirectory = [paths objectAtIndex:0];  
            NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
            [appDelegate.dictSetting writeToFile:filePath atomically:YES];
            
            SBJSON *json = [SBJSON new];
            NSString *str = [NSString stringWithFormat:@"%@",[appDelegate.dictSetting objectForKey:@"movitationalMessage"]];
            appDelegate.dictBanner = [[NSMutableDictionary alloc] initWithDictionary:[json objectWithString:str]];
            [json release];
            [self gotoHome];
            [appDelegate.backgroundService performSelectorInBackground:@selector(verifyAccount) withObject:nil];
        }
}



/*if (appDelegate.isHaveInternetConnection || [[appDelegate.dictSetting objectForKey:@"userID"] isEqualToString:@""]) {
 if ([[appDelegate.dictSetting objectForKey:@"userID"] isEqualToString:@""]) { //login
 NSString *userID;
 NSString *password;
 [self hiddenKeyboard:nil];
 if (!isLogin) {
 
 //login by Password
 if ([[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mood Jounal" message:@"Please enter user name and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
 [alertView show];
 [alertView release];
 indicator.hidden = YES;
 return;
 }
 if ([[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
 textFieldUserName.text = [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"userID"] :kCCDecrypt];
 }    
 appDelegate.userID = [NSString stringWithString:[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
 
 appDelegate.password = [NSString stringWithString:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
 
 userID = [textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
 
 password = [textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
 
 userID = [appDelegate doCipher:userID :kCCEncrypt];
 password = [appDelegate doCipher:password: kCCEncrypt];
 //rest connection 
 isLogin = YES;
 indicator.hidden = NO;
 [indicator startAnimating];
 
 NSMutableArray *arr2 = [[NSMutableArray alloc] init];
 [arr2 addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
 
 
 NSMutableArray *arr = [[NSMutableArray alloc] init];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:appname forKey:@"appname"]];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceID"]];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:deviceType forKey:@"deviceType"]];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:password forKey:@"password"]];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:userID forKey:@"username"]];
 restConnection = nil;
 restConnection = [[RestConnection alloc] init];
 restConnection.viewController = self;
 [restConnection postDataWithPathSource2:@"/rest/Auth" andParam:arr2 withPostData:arr];
 [arr release];
 [arr2 release];
 } 
 }
 else { //verify account
 indicator.hidden = NO;
 [indicator startAnimating];
 if ([[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mood Jounal" message:@"Please enter user name and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
 [alertView show];
 [alertView release];
 indicator.hidden = YES;
 return;
 }
 if ([[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
 textFieldUserName.text = [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"userID"] :kCCDecrypt];
 }    
 appDelegate.userID = [NSString stringWithString:[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
 
 appDelegate.password = [NSString stringWithString:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
 
 NSString *userID;
 NSString *password;
 userID = [textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
 
 password = [textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
 
 userID = [appDelegate doCipher:userID :kCCEncrypt];
 password = [appDelegate doCipher:password: kCCEncrypt];
 
 isVerifyAccount = YES;
 appDelegate.deviceToken = [[NSString alloc] initWithFormat:@"%@",[appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"token"] :kCCDecrypt]];
 
 NSMutableArray *arr2 = [[NSMutableArray alloc] init];
 [arr2 addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
 [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
 
 
 NSMutableArray *arr = [[NSMutableArray alloc] init];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:appname forKey:@"appname"]];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:password forKey:@"password"]];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:@"25" forKey:@"limit"]];
 [arr addObject:[NSMutableDictionary dictionaryWithObject:@"1.0" forKey:@"version"]];
 restConnection = nil;
 restConnection = [[RestConnection alloc] init];
 restConnection.viewController = self;
 [restConnection postDataWithPathSource2:@"/rest/User/verify" andParam:arr2 withPostData:arr];
 [arr release];
 [arr2 release];
 }
 }
 else {
 NSString *pin = [appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"password"] :kCCDecrypt];
 
 if ([[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) { //PIN textfield is blank
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mood Jounal" message:@"Please enter Password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
 [alertView show];
 [alertView release];
 return;
 }
 if (![[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:pin]) { //wrong Password
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mood Jounal" message:@"Wrong Password. Please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
 [alertView show];
 [alertView release];
 return;
 }
 if (isRememberPassword) {
 [appDelegate.dictSetting setObject:@"1"
 forKey:@"rememberPass"]; 
 
 } 
 else{
 [appDelegate.dictSetting setObject:@"0"
 forKey:@"rememberPass"];
 }
 
 [appDelegate.dictSetting setObject:
 [appDelegate doCipher:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
 forKey:@"password"]; 
 [appDelegate.dictSetting setObject:
 [appDelegate doCipher:[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
 forKey:@"userID"];    
 
 //Cache data ---------------
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
 NSUserDomainMask, YES); 
 
 NSString *cacheDirectory = [paths objectAtIndex:0];  
 NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
 [appDelegate.dictSetting writeToFile:filePath atomically:YES];
 
 SBJSON *json = [SBJSON new];
 NSString *str = [NSString stringWithFormat:@"%@",[appDelegate.dictSetting objectForKey:@"movitationalMessage"]];
 appDelegate.dictBanner = [[NSMutableDictionary alloc] initWithDictionary:[json objectWithString:str]];
 [json release];
 [self gotoHome];
 }
 }*/

- (IBAction)registerAccount:(id)sender {
        textFieldPassword.text = @"";
        textFieldUserName.text = @"";
        [self hiddenKeyboard:nil];
        
        RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterView" bundle:nil];
        [self.navigationController pushViewController:registerViewController animated:YES];
        [registerViewController release];
    }


- (IBAction)forgotPassword:(id)sender{
    //check if user is not type user name
    /*NSString *username;
     username = [textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
     if ([username isEqualToString:@""]) {
     //alert error
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"You must enter username!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
     [alert release];
     return;
     }*/
    ForgotPassViewController *forgot = [[ForgotPassViewController alloc] init];
    //forgot.userID = username;
    [self.navigationController  pushViewController:forgot animated:YES];
    [forgot release];
}
- (IBAction)setHighlight:(id)sender{
    //TODO: Set highlight.
}

- (void)gotoHome{
    appDelegate.showDetailFirst = YES;
    YourReminderViewController *viewController = [[YourReminderViewController alloc] initWithNibName:@"YourReminderView" bundle:nil];
    id detail = [viewController getFirstReminder];
    if (detail == nil) {
        //show reminder detail.
        
        if ([[appDelegate.dictSetting objectForKey:@"settedMedication"] isEqualToString:@"0"]) {
            FistRegisterViewController *f = [[FistRegisterViewController alloc] init];
            [self.navigationController pushViewController:f animated:YES];
            [f release];
        } 
        else{
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    else{
        [self.navigationController pushViewController:viewController animated:YES];
    }
    [viewController release];   
}
#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIView *paddingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)] autorelease];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.background = [UIImage imageNamed:@"highlightText.png"];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    UIView *paddingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)] autorelease];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.background = [UIImage imageNamed:@"signinText.png"];
    return YES;
}


#pragma mark -
#pragma mark Restconnection Delegate
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    //textFieldPassword.text = @"";
    indicator.hidden = YES;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",[theRequest responseData]);
    NSLog(@"%@",responseData);
    [appDelegate.backgroundService getMedicationList];
    indicator.hidden = YES;
    if (isLogin) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Login unsuccessful. Please check connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        isLogin = NO;
    }
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    indicator.hidden = YES;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    SBJSON *parser = [SBJSON new];
    NSDictionary *dataDict = (NSDictionary*)[parser objectWithString:responseData];
    [parser release];
    NSLog(@"Respond data: %@",responseData);
    if (index == 1) {
        NSLog(@"push notification successfull %@",responseData);
        if ([responseData isEqualToString:@"{Status: \"SUCCESS\"}"]) {
            //send token to push notification successful
            NSLog(@"Push notification successful");
        }
        else{
            NSLog(@"Register notification failed");
        }
        [responseData release];
        return;
    }
    
    if (isVerifyAccount) {
        if ([responseData rangeOfString:@"\"ID\" : \"500\""].location == NSNotFound) {
            appDelegate.arrayYourReminders = [[NSMutableArray alloc] initWithArray:(NSArray*)dataDict];
            
            [appDelegate.backgroundService getMedicationList];
            
            if (isRememberPassword) {
                [appDelegate.dictSetting setObject:@"1"
                                            forKey:@"rememberPass"]; 
                
            } 
            else{
                [appDelegate.dictSetting setObject:@"0"
                                            forKey:@"rememberPass"];
            }
            
            [appDelegate.dictSetting setObject:
             [appDelegate doCipher:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                        forKey:@"password"]; 
            [appDelegate.dictSetting setObject:
             [appDelegate doCipher:[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                        forKey:@"userID"];    
            
            [appDelegate.dictSetting setObject:
             [appDelegate doCipher:appDelegate.deviceToken  :kCCEncrypt]
                                        forKey:@"token"]; 
            
            //Cache data ---------------
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                                 NSUserDomainMask, YES); 
            
            NSString *cacheDirectory = [paths objectAtIndex:0];  
            NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
            [appDelegate.dictSetting writeToFile:filePath atomically:YES];
            [appDelegate.backgroundService getUpcomingReminder];
            if (appDelegate.isDownloadMotivationalMessage) {
                [appDelegate.backgroundService getMotivationalMessage];
            }
            else {
                SBJSON *json = [SBJSON new];
                NSString *str = [NSString stringWithFormat:@"%@",[appDelegate.dictSetting objectForKey:@"movitationalMessage"]];
                appDelegate.dictBanner = [[NSMutableDictionary alloc] initWithDictionary:[json objectWithString:str]];
                [json release];
            }
            
            [self gotoHome];
            
            //H: push notification
            if (index != 1) {
                if (appDelegate.pushNotificationToken != nil) {
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
                    [arr addObject:[NSMutableDictionary dictionaryWithObject:APPPUSH forKey:@"apppush"]];
                    [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
                    
                    restConnection = [[RestConnection alloc] init];
                    restConnection.viewController = self;
                    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
                    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.pushNotificationToken forKey:@"notification_token"]];
                    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:@"ACTIVE" forKey:@"status"]];
                    index = 1;
                    [restConnection postDataWithPathSource2:@"/rest/Notification" andParam:arr withPostData:arr2];
                    [arr release];
                    [arr2 release];
                }
                
            }
            return;
        }
        else {
            textFieldPassword.text = @"";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Wrong userID or password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
    }
    if (isLogin) {
        if ([dataDict objectForKey:@"deviceToken"] != nil) {
            appDelegate.deviceToken = [NSString stringWithString:[dataDict objectForKey:@"deviceToken"]];
            //store userid and password if user press remember.
            if (isRememberPassword) {
                [appDelegate.dictSetting setObject:@"1"
                                            forKey:@"rememberPass"]; 
                
            } 
            else{
                [appDelegate.dictSetting setObject:@"0"
                                            forKey:@"rememberPass"];
            }
            
            [appDelegate.dictSetting setObject:
             [appDelegate doCipher:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                        forKey:@"password"]; 
            [appDelegate.dictSetting setObject:
             [appDelegate doCipher:[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                        forKey:@"userID"];    
            
            [appDelegate.dictSetting setObject:
             [appDelegate doCipher:appDelegate.deviceToken  :kCCEncrypt]
                                        forKey:@"token"]; 
            
            //Cache data ---------------
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                                 NSUserDomainMask, YES); 
            
            NSString *cacheDirectory = [paths objectAtIndex:0];  
            NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
            [appDelegate.dictSetting writeToFile:filePath atomically:YES];
            
            if (appDelegate.isDownloadMotivationalMessage) {
                [appDelegate.backgroundService getMotivationalMessage];
            }
            else {
                SBJSON *json = [SBJSON new];
                NSString *str = [NSString stringWithFormat:@"%@",[appDelegate.dictSetting objectForKey:@"movitationalMessage"]];
                appDelegate.dictBanner = [[NSMutableDictionary alloc] initWithDictionary:[json objectWithString:str]];
                [json release];
            }
            
            [appDelegate.backgroundService syncToServer];
            appDelegate.needToSync = YES;
            [appDelegate.backgroundService getMedicationList];
            [self gotoHome];
            
            //H: push notification
            if (index != 1) {
                if (appDelegate.pushNotificationToken != nil) {
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
                    [arr addObject:[NSMutableDictionary dictionaryWithObject:APPPUSH forKey:@"apppush"]];
                    [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
                    
                    restConnection = [[RestConnection alloc] init];
                    restConnection.viewController = self;
                    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
                    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.pushNotificationToken forKey:@"notification_token"]];
                    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:@"ACTIVE" forKey:@"status"]];
                    index = 1;
                    [restConnection postDataWithPathSource2:@"/rest/Notification" andParam:arr withPostData:arr2];
                    [arr release];
                    [arr2 release];
                }
            }
        }
        else {
            textFieldPassword.text = @"";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Wrong userID or password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        isLogin = NO;
    }
    else {
        if (![responseData isEqualToString:@"{Status: \"SUCCESS\"}"]) {
            NSLog(@"register pushnotification failed!");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        [self gotoHome];
        if (isRememberPassword) {
            [appDelegate.dictSetting setObject:@"1"
                                        forKey:@"rememberPass"]; 
            
        } 
        else{
            [appDelegate.dictSetting setObject:@"0"
                                        forKey:@"rememberPass"];
        }
        
        [appDelegate.dictSetting setObject:
         [appDelegate doCipher:[textFieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                    forKey:@"password"];
        [appDelegate.dictSetting setObject:
         [appDelegate doCipher:[textFieldUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                    forKey:@"userID"];   
        [appDelegate.dictSetting setObject:
         [appDelegate doCipher:appDelegate.deviceToken  :kCCEncrypt]
                                    forKey:@"token"]; 
        
        //Cache data ---------------
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                             NSUserDomainMask, YES); 
        
        NSString *cacheDirectory = [paths objectAtIndex:0];  
        NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
        [appDelegate.dictSetting writeToFile:filePath atomically:YES];
        
        
        //H: push notification
        if (index != 1) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:APPPUSH forKey:@"apppush"]];
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
            
            restConnection = [[RestConnection alloc] init];
            restConnection.viewController = self;
            NSMutableArray *arr2 = [[NSMutableArray alloc] init];
            [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.pushNotificationToken forKey:@"notification_token"]];
            [arr2 addObject:[NSMutableDictionary dictionaryWithObject:@"ACTIVE" forKey:@"status"]];
            index = 1;
            NSLog(@"Send connection %@ Notification %@",arr, arr2);
            [restConnection postDataWithPathSource2:@"/rest/Notification" andParam:arr withPostData:arr2];
            [arr release];
            [arr2 release];
        }
        
        
    }
    [responseData release];
}

@end
