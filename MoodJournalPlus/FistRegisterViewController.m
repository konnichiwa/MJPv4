

#import "FistRegisterViewController.h"
#import "SetupReminderViewController.h"
#import "SetupAReminderViewController.h"
#import "AppDelegate.h"

@implementation FistRegisterViewController
@synthesize appDelegate;
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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    labelGreeting.text = [NSString stringWithFormat:@"Welcome, %@",[appDelegate doCipher:[appDelegate.dictSetting objectForKey:@"userID"] :kCCDecrypt]];

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

-(IBAction)addFirstMedication:(id)sender{
    
    SetupAReminderViewController *setUpAReminderViewController = [[SetupAReminderViewController alloc] init];
    setUpAReminderViewController.firstTimeSignin = YES;
    setUpAReminderViewController.reminderType = kMedication;
    [self.navigationController pushViewController:setUpAReminderViewController animated:YES];
    [setUpAReminderViewController release];
}
@end
