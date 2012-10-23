

#import "ChangePassViewController.h"
#import "RestConnection.h"
#import "ASIHTTPRequest.h"
#import "SBJSON.h"
#import "AppDelegate.h"

@implementation ChangePassViewController

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
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication ] delegate];
    indicator.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc{
    [textFieldOldPass release];
    [textFieldNewPass release];
    [textFieldConfirm release];
    [indicator release];
    [restConnection release];
    [super dealloc];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)saveChange:(id)sender{
    if (isSave == YES) {
        return;
    }
    
    //check if info is incorrect
    NSString *oldpass = [[[NSString alloc] initWithString:[textFieldOldPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] autorelease];
    NSString *newpass = [[[NSString alloc] initWithString:[textFieldNewPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] autorelease];
    NSString *retype = [[[NSString alloc] initWithString:[textFieldConfirm.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] autorelease];
    BOOL isValid = YES;
    NSString *alertString =@"";
    if ([oldpass isEqualToString:@""]||[newpass isEqualToString:@""]) {
        isValid = NO;
        alertString = @"You must enter your old password and new password";
    }
    if ([retype isEqualToString:@""]||[retype isEqualToString:newpass] == NO) {
        isValid = NO;
        alertString = @"New password didn't match";
    }     
    if (isValid == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:alertString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.view addSubview:alert];
        [alert show];
        [alert release];
        return;
    }
    //start send request to server
    
    isSave = YES;
    indicator.hidden = NO;
    [indicator startAnimating];
    restConnection = [[RestConnection alloc] init];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    [arr2 addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    if (appDelegate.deviceToken != nil) {
        [arr2 addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    }
    else {
        [arr2 addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    
    [arr addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate doCipher:oldpass :kCCEncrypt] forKey:@"existingPassword"]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:[appDelegate doCipher:newpass :kCCEncrypt] forKey:@"newPassword"]];
    restConnection = nil;
    restConnection = [[RestConnection alloc] init];
    restConnection.viewController = self;
    [restConnection postDataWithPathSource2:@"/rest/User/changePassword" andParam:arr2 withPostData:arr];
    [arr release];
    [arr2 release];
}
- (IBAction)hiddenKeyboard:(id)sender{
    [textFieldConfirm resignFirstResponder];
    [textFieldNewPass resignFirstResponder];
    [textFieldOldPass resignFirstResponder];
}
- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Restconnection Delegate
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    isSave = NO;
    indicator.hidden = YES;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"Error from respond: %@",responseData);
    [responseData release];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [self.view addSubview:alert];
    [alert show];
    [alert release];
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    indicator.hidden = YES;
    isSave = NO;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];        
    //save data     
    SBJSON *parser = [SBJSON new];

    NSDictionary *dataDict = (NSDictionary*)[parser objectWithString:responseData];
    [parser release];
    [responseData release];
    id error = [dataDict objectForKey:@"ID"];
    if (error !=nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE 
                                                        message: [dataDict objectForKey:@"Description"]
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    //if change passsword success, update data if necessary.
    if (![[appDelegate.dictSetting objectForKey:@"password"] isEqualToString:@""]) {
        //do somethingß
        [appDelegate.dictSetting setObject:
         [appDelegate doCipher:[textFieldConfirm.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]  :kCCEncrypt]
                                    forKey:@"password"];    
        
        //Cache data ---------------
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                                             NSUserDomainMask, YES); 
        
        NSString *cacheDirectory = [paths objectAtIndex:0];  
        NSString *filePath = [cacheDirectory stringByAppendingString:@"/Setting.plist"];
        [appDelegate.dictSetting writeToFile:filePath atomically:YES];
    }
    

    [self.navigationController popViewControllerAnimated:YES];
}
@end
