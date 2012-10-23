//
//  ChooseStrength.m
//  MoodJournalPlus
//
//  Created by luan on 10/20/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import "ChooseStrength.h"
#import "BackgroundService.h"
@interface ChooseStrength ()

@end

@implementation ChooseStrength
@synthesize medicationName;
@synthesize strengthList;
@synthesize backPress;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",self.medicationName);
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
        [self getDetailFromMedication:self.medicationName];
}
-(void)viewWillAppear:(BOOL)animated
{

}
- (void)viewDidUnload
{
    [self setBackPress:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [backPress release];
    [super dealloc];
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getDetailFromMedication:(NSString*)nameMedication
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    if (appDelegate.deviceToken != nil) {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    }
    else {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    RestConnection   *restConnection = [[RestConnection alloc] init];
    restConnection.viewController = self;
    
    [restConnection getDataWithPathSource:@"/rest/Medication/drugs_list/OCTREOTIDE+ACETATE+(PRESERVATIVE+FREE) (OCTREOTIDE+ACETATE)" andParam:arr forService:nil];
    [arr release];
    
}
- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"-=-=-=%@",responseData);
    SBJSON *parser = [[SBJSON new] autorelease];
    id dataDict = [parser objectWithString:responseData];
    NSLog(@"%@",dataDict);    
}
- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseData);
    [responseData release];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mood Jounal" message:@"Connection failed! Please check connection and try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

@end
