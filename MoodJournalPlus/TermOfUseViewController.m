

#import "TermOfUseViewController.h"
#import "AppDelegate.h"

@implementation TermOfUseViewController
@synthesize termID;
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
    //labelLoading.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [indicator startAnimating];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)loadDetail:(NSInteger) tID{
    NSURL *url;  
    NSString *text = @"";
    switch (tID) {
        case 1:{
            url = [NSURL URLWithString:kLINKPOLICY];  
            text =@"Policy";
        }
            break;
        case 2:{
            url = [NSURL URLWithString:kLINKLEGAL];  
            text =@"Legal Notice";
        }
            
            break;
        case 3:{
            url = [NSURL URLWithString:kLINKCOPYRIGHT];  
            text =@"Copyright";
        }
            
            break;
        case 4:
        {
            url = [NSURL URLWithString:kLINKCONTACT];  
            text =@"Contact";
        }
            break;
        default:{
            url = [NSURL URLWithString:kLINKABOUT];  
            text =@"About";
        }
            break;
       /* default:{
            url = [NSURL URLWithString:kLINKTERMOFUSE];  
            text =@"Terms Of Use";
        }
            break;
        */
    }
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    viewCommon.hidden = NO;    
    [self.view addSubview:viewCommon];
    [labelHeader setText:text];
	[webView loadRequest:requestObj];
   
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc{
    [webView release];
    [viewCommon release];
    [labelHeader release];
    //[labelLoading release];
    [indicator release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)pressDetail:(UIButton *)sender{
    TermOfUseViewController *t = [[TermOfUseViewController alloc] init];
    [t loadDetail:sender.tag];
    [self.navigationController pushViewController:t animated:YES];
    [t release];
}


#pragma mark ---
#pragma UIWebview delegate ------
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    indicator.hidden = YES;
    /*
    [activityIndicator stopAnimating];
    myLabel.hidden = TRUE;
     */
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    indicator.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:@"Limited or no connection detected. Try again later or use WIFI." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end
