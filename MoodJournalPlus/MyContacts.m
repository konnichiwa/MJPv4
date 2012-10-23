//
//  MyContacts.m
//  MoodJournalPlus
//
//  Created by luan on 10/9/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import "MyContacts.h"
#import "BackgroundService.h"
#import "ViewContacts.h"
@interface MyContacts ()

@end

@implementation MyContacts
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
     appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    contactType=[[NSMutableArray alloc] init];
    [contactType addObject:@"Doctors"];
    [contactType addObject:@"Pharmacies"];
    [contactType addObject:@"Other"];
    
    doctorContact=[[NSMutableArray alloc] init];
    phamacyContact=[[NSMutableArray alloc] init];
    otherContact=[[NSMutableArray alloc] init];
    [self getAllcontact];
}

- (void)viewDidUnload
{

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backMoreOption:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [contactType count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] init] autorelease];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text=[contactType objectAtIndex:indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ViewContacts *viewcontroller=[[ViewContacts alloc] initWithNibName:@"ViewContacts" bundle:nil];
    viewcontroller.tit=[contactType objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewcontroller animated:YES];
    
    
}
-(void)getAllcontact
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    if (appDelegate.deviceToken != nil) {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        NSLog(@"%@",appDelegate.deviceToken);
    }
    else {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    RestConnection *restConnection = [[RestConnection alloc] init];
    restConnection.viewController = self;
    NSString *patch=[NSString stringWithFormat:@"/rest/Contact/list"];
    [restConnection getDataWithPathSource:patch andParam:arr forService:@"getYourRemiders"];
    [arr release];

}
- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"-=-=-=%@",responseData);
    
    SBJSON *parser = [[SBJSON new] autorelease];
    id dataDict = [parser objectWithString:responseData];    
    doctorContact=[dataDict objectForKey:@"Doctor"];
    phamacyContact=[dataDict objectForKey:@"Pharmacy"];
    otherContact=[dataDict objectForKey:@"Other"];
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName =[[NSString alloc] initWithString:CONTACT_TABLE];
    [recordDao1 deleteAllData];
//    NSMutableDictionary *temp=[[NSMutableDictionary alloc] init];
    for (NSDictionary *temp in doctorContact) {
        [recordDao1 insertContactWithName:[temp objectForKey:@"contactname"] phone:[temp objectForKey:@"contactphone"] andtype:@"Doctor" andId:[temp objectForKey:@"contactid"]];
    }
    for (NSDictionary *temp in phamacyContact) {
        [recordDao1 insertContactWithName:[temp objectForKey:@"contactname"] phone:[temp objectForKey:@"contactphone"] andtype:@"Pharmacy" andId:[temp objectForKey:@"contactid"]];
    }
    for (NSDictionary *temp in otherContact) {
        [recordDao1 insertContactWithName:[temp objectForKey:@"contactname"] phone:[temp objectForKey:@"contactphone"] andtype:@"Other" andId:[temp objectForKey:@"contactid"]];
    }
    
}

- (void)dealloc {
    [super dealloc];
}
@end