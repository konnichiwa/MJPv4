//
//  ViewContacts.m
//  MoodJournalPlus
//
//  Created by luan on 10/11/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import "ViewContacts.h"
#import "RestConnection.h"
#import "BackgroundService.h"
#import "AddAcontact.h"
@interface ViewContacts ()

@end

@implementation ViewContacts
@synthesize titl;
@synthesize table;
@synthesize bottomAction;
@synthesize progess;
@synthesize allContacts;
@synthesize tit;
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
    [progess setHidesWhenStopped:YES];
    [progess setHidden:YES];
}

- (void)viewDidUnload
{
    [self setTitl:nil];
    [self setTable:nil];
    [self setBottomAction:nil];
    [self setProgess:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)viewWillAppear:(BOOL)animated
{
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    aContact=[[NSMutableDictionary alloc] init];
    allContacts=[[NSMutableArray alloc] init];
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName =[[NSString alloc] initWithString:CONTACT_TABLE];
    self.titl.text=self.tit;
    if ([self.tit isEqualToString:@"Doctors"]) {
        [self getContactFromContactType:@"Doctor"];
       // typeContact=[NSString stringWithFormat:@"Doctor"];
    }
    if ([self.tit isEqualToString:@"Pharmacies"]) {
        [self getContactFromContactType:@"Pharmacy"];
       // typeContact=[NSString stringWithFormat:@"Pharmacy"];        
    }
    if ([self.tit isEqualToString:@"Other"]) {
        [self getContactFromContactType:@"Other"];
       // typeContact=[NSString stringWithFormat:@"Other"];  
        
    }
   // allContacts=[recordDao1 getContactsFromType:typeContact];
  //  NSLog(@"%@",allContacts);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [allContacts count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] init] autorelease];
    }
    aContact=[allContacts objectAtIndex:indexPath.section];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row==0) {
        NSLog(@"%@",[aContact objectForKey:@"contactname"]);
            cell.textLabel.text=[appDelegate doCipher:[aContact objectForKey:@"contactname"] :kCCDecrypt] ;
    }
    else {
            cell.textLabel.text=[appDelegate doCipher:[aContact objectForKey:@"contactphone"] :kCCDecrypt];
    }

    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)aTableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath 
{

 aContact=[allContacts objectAtIndex:indexPath.section];
NSString *idContact=[NSString stringWithFormat:@"%@",[aContact objectForKey:@"contactid"]];
[allContacts removeObjectAtIndex:indexPath.section];
    [table reloadData];
[self deleteContactWithId:idContact];    

}
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return isDeleteCell;
}
- (void)tableView:(UITableView *)aTableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    isDeleteCell = NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==0) {
        AddAcontact *viewcontroller=[[AddAcontact alloc] initWithNibName:@"AddAcontact" bundle:nil];
        aContact=[allContacts objectAtIndex:indexPath.section];
        viewcontroller.name=[appDelegate doCipher:[aContact objectForKey:@"contactname"] :kCCDecrypt];
        viewcontroller.phone=[appDelegate doCipher:[aContact objectForKey:@"contactphone"] :kCCDecrypt];
        viewcontroller.isEditMode=YES;
        viewcontroller.tit=self.tit;
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }
}
- (void)dealloc {
    [titl release];
    [table release];
    [bottomAction release];
    [progess release];
    [super dealloc];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)add:(id)sender {
    AddAcontact *viewcontroller=[[AddAcontact alloc] initWithNibName:@"AddAcontact" bundle:nil];
    viewcontroller.tit=self.tit;
    [self.navigationController pushViewController:viewcontroller animated:YES];
    
}

- (IBAction)delete:(id)sender {
    
    [self.table setEditing:!self.table.editing animated:YES];
	if (self.table.editing){
        isDeleteCell = YES;
        [bottomAction setTitle:@"Done" forState:UIControlStateNormal];
    }
    
	else{
        isDeleteCell = NO;
        [bottomAction setTitle:@"Delete..." forState:UIControlStateNormal];
    }
    [table reloadData];
}

-(void)getContactFromContactType:(NSString*)type
{
    index=1;
    [progess startAnimating];
            typeContact=[NSString stringWithFormat:@"%@",type];
    NSLog(@"%@",typeContact);
    [typeContact retain];
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
    NSString *patch=[NSString stringWithFormat:@"/rest/Contact/list/%@",type];
    [restConnection getDataWithPathSource:patch andParam:arr forService:@"getYourRemiders"];
    [arr release];
}
-(void)deleteContactWithId:(NSString*)idContact
{
    
    index = 2;
        [progess startAnimating];
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
    
    [restConnection deleteDataWithPathSource:[NSString stringWithFormat:@"/rest/Contact/%@",idContact] andParam:arr withReminderID:idContact];
    [arr release];
    [table reloadData];
}
- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"-=-=-=%@",responseData);
    NSLog(@"jbejf:%@",typeContact);
    
    SBJSON *parser = [[SBJSON new] autorelease];
    id dataDict = [parser objectWithString:responseData];    
    NSLog(@"%@",dataDict);
    [progess stopAnimating];
    if (index==1) {
        allContacts=[dataDict objectForKey:typeContact];
          NSLog(@"%@",allContacts);
        [allContacts retain];

        [table reloadData];
    } 
}
@end
