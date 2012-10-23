

#import "ForgotPassViewController.h"
#import "YourReminderViewController.h"
#import "ReminderDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"
#import "SBJSON.h"
#import "RestConnection.h"
#import "AppDelegate.h"
#import "FistRegisterViewController.h"

@implementation ForgotPassViewController
@synthesize userID;
- (IBAction)submitQuestion:(id)sender{
    //request for username, password
    if (isSaving == TRUE) {
        return;
    }
    isSaving = 0;
    indicator.hidden = NO;
    restConnection.viewController = self;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    NSMutableArray *arrPost = [[NSMutableArray alloc] init];
    //[arrPost addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceId"]]; 
    //NSLog(@"userid la %@",userID);
    [arrPost addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate doCipher :userID: kCCEncrypt] forKey:@"username"]];
    [arrPost addObject:[NSMutableDictionary dictionaryWithObject:
                        [appDelegate doCipher :textAnswer.text: kCCEncrypt] forKey:@"securityAnswer"]];
    
    [restConnection postDataWithPathSource3:@"/rest/User/forgotPassword" andParam:arr withPostData:arrPost];
    index = 1;
    [arrPost release];
    [arr release];
}
- (IBAction)resignView{
    [textAnswer resignFirstResponder];
}

- (IBAction)returnSignin{
    index = 2;
    indicator.hidden = NO;
    [indicator startAnimating];
    [returnLoginView addSubview:indicator];
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appname forKey:@"appname"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceID"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:deviceType forKey:@"deviceType"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate doCipher:labelPassword.text : kCCEncrypt] forKey:@"password"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate doCipher:labelUsername.text : kCCEncrypt] forKey:@"username"]];
    //restConnection.viewController = self;
    [restConnection postDataWithPathSource2:@"/rest/Auth" andParam:arr2 withPostData:arr];
    [arr release];
    [arr2 release];
}

- (IBAction)pressBack{
    [self.navigationController popViewControllerAnimated:YES];
}

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //todo: get username from plist.
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    /*if ([userID isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Unknow Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.view addSubview:alert];
        [alert show];
        [alert release];
    }*/
    [super.view addSubview:returnLoginView];
    returnLoginView.frame = CGRectMake(0, 480, 320, 460);
    [self.view addSubview:returnLoginView];
    [super viewDidLoad];
    
    indicator.hidden = NO;
    [indicator startAnimating];
    //retrieve sercurity question
    restConnection = [[RestConnection alloc] init];
    restConnection.viewController = self;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    NSMutableArray *arrPost = [[NSMutableArray alloc] init];
    [arrPost addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceId"]];    
    //[arrPost addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate doCipher :userID: kCCEncrypt] forKey:@"username"]];
    [restConnection postDataWithPathSource3:@"/rest/User/securityQuestion" andParam:arr withPostData:arrPost];
    index = 0;
    [arr release];
    [arrPost release];
    //by default: submit deviceid
    submitDeviceID = YES;
    userID = [[NSString alloc] initWithString:@""];
    // Do any additional setup after loading the view from its nib.
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

- (void) dealloc {
    [labelQuestion release];
    [textAnswer release];
    [labelUsername release];
    [labelPassword release];
    [returnLoginView release];
    [super dealloc];
}

- (void)gotoHome{
    appDelegate.showDetailFirst = YES;
    YourReminderViewController *viewController = [[YourReminderViewController alloc] initWithNibName:@"YourReminderView" bundle:nil];
    id detail = [viewController getFirstReminder];
    if (detail == nil) {
        //show reminder detail.
        NSLog(@"dict setting %@",appDelegate.dictSetting);
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
        //end request to push notification
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
    indicator.hidden = YES;
    isSaving = NO;
//    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
//    NSLog(@"respond %@, request: %@",responseData, [theRequest responseData]);
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    isSaving = NO;
    indicator.hidden = YES;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@" Respond: %@",responseData);
    SBJSON *parser = [SBJSON new];
    NSDictionary *dataDict = (NSDictionary*)[parser objectWithString:responseData];
    id error = [dataDict objectForKey:@"ID"];
    if (error !=nil) {
        UIAlertView *alertView;  
        //if get sercurity question from deviceid failed, let user press user name.
        if (submitDeviceID == NO&&index == 0) {
            //can't get sercurity question, return login page
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        if (submitDeviceID == YES&&index == 0) {
            submitDeviceID = NO;
            //if user id setted, call to submit user id.
            if ([[[appDelegate.dictSetting objectForKey:@"userID"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                //else: alert to support new user id new rest connection to submit userid
                alertView = [[UIAlertView alloc] initWithTitle:@"Please enter your userID" message:@"\n" delegate:self cancelButtonTitle:@"Get question" otherButtonTitles:@"Cancel",nil];
                textUserId = [[UITextField alloc] initWithFrame:CGRectMake(13, 50, 260, 26)];
                textUserId.text = @"";
                [textUserId setBackgroundColor:[UIColor whiteColor]];
                [alertView addSubview:textUserId];
                index = 0;
            }
            else {
                //post current user id
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
                NSMutableArray *arrPost = [[NSMutableArray alloc] init];
                //[arrPost addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceId"]];    
                [arrPost addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate.dictSetting objectForKey:@"userID"] forKey:@"username"]];
                [restConnection postDataWithPathSource3:@"/rest/User/securityQuestion" andParam:arr withPostData:arrPost];
                index = 0;
                NSLog(@"repost: arr %@ and %@",arr, arrPost);
                [arr release];
                [arrPost release];
                [parser release];
                [responseData release];
                return;
            }
            
        }
        else{
            alertView = [[UIAlertView alloc] initWithTitle:POPUP_TITLE 
                                                            message: [dataDict objectForKey:@"Description"]
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        [alertView show];
        [alertView release];
        [parser release];
        [responseData release];
        
        return;
    }
    switch (index) {
        case 0://default: request for security question
        {
            labelQuestion.text = [dataDict objectForKey:@"question"];
            self.userID = [NSString stringWithString:[appDelegate doCipher:[dataDict objectForKey:@"username"] :kCCDecrypt]];
            NSLog(@"userid la %@",userID);
        }
            break;
        case 1:
        {
            //NSLog(@"user id la %@",appDelegate.userID);
            //labelUsername.text = [appDelegate doCipher:appDelegate.userID :kCCDecrypt];
            labelUsername.text = userID;
            labelPassword.text = [appDelegate doCipher:responseData :kCCDecrypt];
            [returnLoginView setFrame:CGRectMake(0, 0, 320, 460)];
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.5];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[returnLoginView layer] addAnimation:animation forKey:@"SwitchToView1"];
            
        }
            break;
        case 2:
        {
            if ([dataDict objectForKey:@"deviceToken"] != nil) {
                //store userid and password if user press remember.    
                [appDelegate.dictSetting setObject:[appDelegate doCipher:labelUsername.text :kCCEncrypt] forKey:@"userID"];    
                //Cache data ---------------
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                                     NSUserDomainMask, YES); 
                NSString *cacheDirectory = [paths objectAtIndex:0];  
                NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
                [appDelegate.dictSetting writeToFile:filePath atomically:YES];
                
                appDelegate.deviceToken = [NSString stringWithString:[dataDict objectForKey:@"deviceToken"]];
                [self gotoHome];
                
            }
        }
            break;
        case 3:{
               //dosth  
        }
            break;
        default:
            break;
    }
    [responseData release];
    [parser release];
}

#pragma mark
#pragma mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    NSMutableArray *arrPost = [[NSMutableArray alloc] init];
    //[arrPost addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceID forKey:@"deviceId"]];    
    [arrPost addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate doCipher :textUserId.text: kCCEncrypt] forKey:@"username"]];
    [restConnection postDataWithPathSource3:@"/rest/User/securityQuestion" andParam:arr withPostData:arrPost];
    index = 0;
     NSLog(@"repost: arr %@ and %@",arr, arrPost);
    [arr release];
    [arrPost release];
   
}
@end
