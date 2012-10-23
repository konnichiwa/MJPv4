//
//  HomeViewController.m
//  MoodJournalPlus
//
//  Created by le hung on 12/27/11.
//  Copyright (c) 2011 CNCSoft. All rights reserved.
//

#import "HomeViewController.h"
#import "AccountSettingViewController.h"
#import "InstructionsViewController.h"
#import "YourReminderViewController.h"
#import "SetupReminderViewController.h"

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"MessageBox";
        [self.navigationItem setHidesBackButton:YES];
        
        //instructions button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [button addTarget:self action:@selector(showInstructions) forControlEvents:UIControlEventTouchUpInside];
        UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        [viewBg addSubview:button];
        [viewBg setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *buttonInfo = [[UIBarButtonItem alloc] initWithCustomView:viewBg];
        self.navigationItem.rightBarButtonItem = buttonInfo;
        [viewBg release];
        [buttonInfo release];
        
        //back button
        self.navigationItem.backBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                          style:UIBarButtonItemStyleBordered
                                         target:nil
                                         action:nil] autorelease];
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
    [imageViewAmoundReminderBG release];
    [labelAmountReminder release];
    [labelText release];
    [buttonShowYourReminder release];
    [super dealloc];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
    self.title = @"MessageBox";
    [self.navigationItem setHidesBackButton:YES];
    
    //instructions button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(showInstructions) forControlEvents:UIControlEventTouchUpInside];
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [viewBg addSubview:button];
    [viewBg setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *buttonInfo = [[UIBarButtonItem alloc] initWithCustomView:viewBg];
    self.navigationItem.rightBarButtonItem = buttonInfo;
    [viewBg release];
    [buttonInfo release];
    
    //back button
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
     //self.navigationController.navigationBarHidden = NO;
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
- (IBAction)showYourReminder:(id)sender {
    YourReminderViewController *yourReminderViewController = [[YourReminderViewController alloc] initWithNibName:@"YourReminderView" bundle:nil];
    [self.navigationController pushViewController:yourReminderViewController animated:YES];
    [yourReminderViewController release];
}

- (IBAction)setUpReminder:(id)sender {
    
    SetupReminderViewController *setupReminderViewController = [[SetupReminderViewController alloc] initWithNibName:@"SetupReminderView" bundle:nil];
    [self.navigationController pushViewController:setupReminderViewController animated:YES];
    [setupReminderViewController release];
}

- (IBAction)settingAccount:(id)sender {
    AccountSettingViewController *accountSettingViewController = [[AccountSettingViewController alloc] initWithNibName:@"AccountSettingView" bundle:nil];
    [self.navigationController pushViewController:accountSettingViewController animated:YES];
    [accountSettingViewController release];
}

- (void)showInstructions {
    InstructionsViewController *instructionsViewController = [[InstructionsViewController alloc] initWithNibName:@"InstructionsView" bundle:nil];
    [self.navigationController pushViewController:instructionsViewController animated:YES];
    [instructionsViewController release];
}
@end
