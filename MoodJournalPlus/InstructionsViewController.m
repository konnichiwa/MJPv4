//
//  InstructionsViewController.m
//  MoodJournalPlus
//
//  Created by le hung on 12/28/11.
//  Copyright (c) 2011 CNCSoft. All rights reserved.
//

#import "InstructionsViewController.h"
#import "YourReminderViewController.h"

@implementation InstructionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIImageView *imgViewTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
        imgViewTitle.frame = CGRectMake(0, 0, 174, 19);
        self.navigationItem.titleView = imgViewTitle;
        [imgViewTitle release];
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
@end
