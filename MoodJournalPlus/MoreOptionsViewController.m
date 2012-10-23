

#import "MoreOptionsViewController.h"
#import "AccountSettingViewController.h"
#import "SetupReminderViewController.h"
#import "TermOfUseViewController.h"
#import "SendFeedbackViewController.h"
#import "YourReminderViewController.h"
#import "MyContacts.h"
#import "AppDelegate.h"

@implementation MoreOptionsViewController

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

- (IBAction)pressMoreOptions:(UIButton *)sender{
    switch (sender.tag) {
        case 1:{
            SetupReminderViewController *viewController = [[SetupReminderViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            break;
        }
        case 2:{
            AccountSettingViewController *viewController = [[AccountSettingViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            break;
        }
        case 3:{
            SendFeedbackViewController *viewController = [[SendFeedbackViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            break;
        }
        case 5:{
            MyContacts *viewController = [[MyContacts alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
           // [viewController release];
            break;
        }
        default:{
            TermOfUseViewController *viewController = [[TermOfUseViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            break;
        } 
    }    
}

- (IBAction)pressHome:(id)sender
{
    /*YourReminderViewController *y = [[YourReminderViewController alloc] init];
    [self.navigationController pushViewController:y animated:YES];
    [y release];*/    
    NSArray *arr = [self.navigationController viewControllers];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isSecondSignUp) {
        for (int i = 0; i < [arr count]; i++) {
            if ([[arr objectAtIndex:i] isKindOfClass:[YourReminderViewController class]]) {
                [self.navigationController popToViewController:[arr objectAtIndex:i] animated:YES];
                return;
            }
        }
    }
    else {
        //[self.navigationController popToViewController:[arr objectAtIndex:1] animated:YES];
        for (int i = 0; i < [arr count]; i++) {
            if ([[arr objectAtIndex:i] isKindOfClass:[YourReminderViewController class]]) {
                [self.navigationController popToViewController:[arr objectAtIndex:i] animated:YES];
                return;
            }
        }
    }
}
@end
