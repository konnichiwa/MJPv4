

#import "SendFeedbackViewController.h"
#import "YourReminderViewController.h"
#import "AppDelegate.h"

@implementation SendFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        chooseID = 1;
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
    /*http://50.19.213.37/feedback.msg?forward=http:// 107.21.219.185/CoreServices/
     rest/Journal/MoodJournal+-+Feedback?
     application_token=999&sk=1342213392058&token=1342213349990303030161721281618&a
     pi_sig=2d5a89336fc6d04af642bb394025c46073e2cf29*/
    
    /*NSString *sk = [NSString stringWithFormat:@"%13.0f",[[NSDate date] timeIntervalSince1970]*1000];
     //NSString *sk = @"1329187360190";
     [arr addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",sk] forKey:@"sk"]];
     arr = [self sortArrayByAlphabet:arr];
     NSString *api_signture = [self createSignatureWithPathSource:pathSource andParam:arr];
     [arr addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
     
     for (int i = 0; i < [arr count]; i++) {
     if (i < [arr count]-1) {
     NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
     linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr objectAtIndex:i] objectForKey:key]];
     }
     else {
     NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
     linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr objectAtIndex:i] objectForKey:key]];
     }
     }*/
    
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *sk = [NSString stringWithFormat:@"%13.0f",[[NSDate date] timeIntervalSince1970]*1000];
    NSString *pathSource = [NSString stringWithString:@"http://50.19.213.37/feedback.msg?forward=http://107.21.219.185/CoreServices/rest/Journal/App+-+Feedback?"];
    NSString *linkRequest = [NSString stringWithFormat:@"%@",pathSource];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    [arr addObject:[NSDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    if (appDelegate.deviceToken != nil) {
         [arr addObject:[NSDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    }   
    else {
         [arr addObject:[NSDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    [arr addObject:[NSDictionary dictionaryWithObject:sk forKey:@"sk"]];
    
    arr = [self sortArrayByAlphabet:arr];
    NSString *api_signture = [self createSignatureWithPathSource:@"/rest/Journal/App+-+Feedback" andParam:arr];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
    
    for (int i = 0; i < [arr count]; i++) {
        if (i < [arr count]-1) {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
        else {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
    }
    
    NSURL *url = [NSURL URLWithString:linkRequest];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];
    indicator.hidden = NO;
    [indicator startAnimating];
    [super viewDidLoad];
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

- (void) dealloc{
    [btnOpt1 release];
    [btnOpt2 release];
    [btnOpt3 release];
    [webView release];
    [labelLoading release];
    [super dealloc];
}
- (IBAction)pressSendFeedback:(id)sender{
    /*YourReminderViewController *y = [[YourReminderViewController alloc] initWithNibName:@"YourReminderView" bundle:nil];
    [self.navigationController pushViewController:y animated:YES];
    [y release];*/
    //[self.navigationController popViewControllerAnimated:YES];
    
    NSArray *arr = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[arr objectAtIndex:1] animated:YES];
}

- (IBAction)pressCheckBox:(UIButton *)sender {
    UIButton *b;
    if (sender.tag != chooseID) {
        //uncheck old radio button
        switch (chooseID) {
            case 1:
                b = btnOpt1;
                break;
            case 2:
                b = btnOpt2;
                break;
            default:
                b = btnOpt3;
                break;
        }
        chooseID = sender.tag;
        [b setImage:[UIImage imageNamed:@"radio.png"] forState:UIControlStateNormal];
        //check to new radio button
        [sender setImage:[UIImage imageNamed:@"radioChecked.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)pressBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---
#pragma UIWebview delegate ------
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    indicator.hidden = YES;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    indicator.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


- (NSString *)sha1:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    
    return [s lowercaseString];
}

- (NSString*)createSignatureWithPathSource:(NSString*)pathSource andParam:(NSArray*)arrayParam {
    BOOL hasToken = NO;
    NSString *token;
    for (int i = 0; i < [arrayParam count]; i++) {
        if ([[arrayParam objectAtIndex:i] objectForKey:@"token"] != nil) {
            hasToken = YES;
            token = [[arrayParam objectAtIndex:i] objectForKey:@"token"];
            break;
        }
    }
    NSString *salt = @"1234567890123456";
    if (hasToken) {
        salt = [token stringByAppendingString:salt];
    }
    
    
    NSString *string = [salt stringByAppendingString:pathSource];
    for (int i = 0; i < [arrayParam count]; i++) {
        NSString *key = [[[arrayParam objectAtIndex:i] allKeys] objectAtIndex:0];
        string = [string stringByAppendingString:key];
        string = [string stringByAppendingString:[[arrayParam objectAtIndex:i] objectForKey:key]];
    }
    return [self sha1:string];
}

- (NSMutableArray*)sortArrayByAlphabet:(NSArray*)array {
    NSArray *sortedArray = [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        NSString *char1 = [[obj1 allKeys] objectAtIndex:0];
        NSString *char2 = [[obj2 allKeys] objectAtIndex:0];
        NSComparisonResult comparison = [char1 localizedCaseInsensitiveCompare:char2];
        return comparison;
    }];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:sortedArray];
    return [arr autorelease];
}
@end
