//
//  AlertMedication.m
//  MoodJournalPlus
//
//  Created by luan on 10/15/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import "AlertMedication.h"
#import "YourReminderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ParseJSON.h"
#import "YourReminderViewController.h"
#import "ReminderDetailViewController.h"
@interface AlertMedication ()

@end

@implementation AlertMedication
@synthesize dictReminderDetail;
@synthesize contentLabel;
@synthesize medicationNameLabel;
@synthesize iD;
@synthesize delegate;
@synthesize refillView;
@synthesize contentRefillLabel;
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
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.showDetailFirst =  NO;
    NSLog(@"%@",dictReminderDetail);
    if ([[dictReminderDetail objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"])
    {
        [refillView setHidden:YES];
        NSString *name;
        name = [appDelegate getProperty:@"Medication Name" forData:dictReminderDetail];
        NSLog(@"%@",name);
        self.medicationNameLabel.text=name;
        NSString *content;
        content = [appDelegate getProperty:@"Content" forData:dictReminderDetail];
        self.contentLabel.text=content;
        recordDao = [[RecordDao alloc] init];
        recordDao.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
    }
    if ([[dictReminderDetail objectForKey:@"reminderName"] isEqualToString:@"Refill Reminder"])
    {
        [self.view addSubview:refillView];
        NSString *content;
        content = [appDelegate getProperty:@"Content" forData:dictReminderDetail];
        self.contentRefillLabel.text=content;
        recordDao = [[RecordDao alloc] init];
        recordDao.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
    }
}

- (void)viewDidUnload
{
    [self setContentLabel:nil];
    [self setMedicationNameLabel:nil];
    [self setContentRefillLabel:nil];
    [self setRefillView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [contentLabel release];
    [medicationNameLabel release];
    [contentRefillLabel release];
    [refillView release];
    [super dealloc];
}
#pragma mark -
#pragma mark action
- (IBAction)refilledAction:(id)sender {
}

- (IBAction)calltoRefillAction:(id)sender {
}

- (IBAction)snoozeRefillAction:(id)sender {
    NSString *msgid = [NSString stringWithFormat:@"%@",[self.dictReminderDetail objectForKey:@"msgboxid"]];
    if ([msgid isEqualToString:@"0"]) {
        msgid = [NSString stringWithFormat:@"%@",[self.dictReminderDetail objectForKey:@"msgschedulerid"]];
    }
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName =[[NSString alloc] initWithString:SNOOZE_TABLE];
    NSArray *array = [self.navigationController viewControllers];
    [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
    [recordDao1 insertSnoozeWithMsgId:msgid];
    [recordDao1 release];
    [self performSelector:@selector(addNotificationwithID:) withObject:msgid afterDelay:1.0];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)action:(id)sender {
    int tag = [sender tag];
    NSArray *properties = [dictReminderDetail objectForKey:@"properties"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
 
    NSString *msgid = [NSString stringWithFormat:@"%@",[self.dictReminderDetail objectForKey:@"msgboxid"]];
    if ([msgid isEqualToString:@"0"]) {
        msgid = [NSString stringWithFormat:@"%@",[self.dictReminderDetail objectForKey:@"msgschedulerid"]];
    }
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName =[[NSString alloc] initWithString:SNOOZE_TABLE];
    switch (tag) {
        case 0:
        {
            [self removeNotificationwithID:msgid];
            [recordDao1 deleteRecordWithMsgID:msgid];
            [recordDao updateAtIndex:iD Status:@"just taken"];

            [dictReminderDetail setValue:@"COMPLETE" forKey:@"systemstatus"];
            for (int i = 0; i < [properties count]; i++) {
                if ([[[properties objectAtIndex:i] objectForKey:@"propertyName"] isEqualToString:@"Time Taken"]) {
                    [[properties objectAtIndex:i] setValue:date forKey:@"propertyValue"];
                }
            }
            [dictReminderDetail setValue:properties forKey:@"properties"];
            
            [self updateHistory:dictReminderDetail];
            NSArray *array = [self.navigationController viewControllers];
            if ([(YourReminderViewController*)[array objectAtIndex:[array count]-2] respondsToSelector:@selector(reloadTableView:)]) {
                [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }
            break;
        case 2:
        {
            NSArray *array = [self.navigationController viewControllers];
            [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
            [recordDao1 insertSnoozeWithMsgId:msgid];
            [self performSelector:@selector(addNotificationwithID:) withObject:msgid afterDelay:1.0];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 3:
        {
//            [self showDetailReminder];

            [self.navigationController popViewControllerAnimated:NO];
                        [self.delegate showView];
        }
            break;
        case 1:
        {
            [self removeNotificationwithID:msgid];
            [recordDao1 deleteRecordWithMsgID:msgid];
            UIActionSheet *skipResion=[[UIActionSheet alloc] initWithTitle:@"" delegate:(id)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I didn't need it right now.",@"I didn't have any",@"Other",nil];
            [skipResion showInView:self.view];
        }
            break;
        default:
            break;
    }
    [formatter release];
    [recordDao1 release];
}


- (NSString*)convertDateFromFloatString2:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone {
    NSString *dateString;    double deliveryDate = [floatString doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (date) {
        [formatter setDateStyle:NSDateFormatterFullStyle];   
    }
    else {
        [formatter setTimeStyle:NSDateFormatterShortStyle];   
    }
    dateString = [[NSString alloc] initWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)((double)deliveryDate/(double)1000)]]];
    [formatter release];
    return [dateString autorelease];
}

- (void)updateHistory:(NSMutableDictionary *)datadict {
    appDelegate.syned = NO;
    NSString *date = [self convertDateFromFloatString2:[datadict objectForKey:@"deliverydate"] toDateStype:YES withTimeZone:[datadict objectForKey:@"timeZone"]];
    
    NSLog(@"%@",date);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingString:[NSString stringWithFormat:@"/History/%@.txt",date]];
    
    ParseJSON *parseJson = [[ParseJSON alloc] init];
    NSMutableArray *dataList = [[NSMutableArray alloc] initWithArray:[parseJson parseDataFromTextFile:[NSString stringWithFormat:@"History/%@",date]]];
    NSLog(@"%@",dataList);
    if ([dataList count] > 0) {
        [dataList insertObject:datadict atIndex:0];
    }
    else {
        [dataList addObject:datadict];
    }
    
    NSLog(@"%@",dataList);
    //
    SBJSON *json = [SBJSON new];
    NSString *str = [json stringWithObject:dataList error:nil];
    NSLog(@"%@",str);
    //[[appDelegate doCipher:str :kCCEncrypt] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [json release];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *msgid = [NSString stringWithFormat:@"%@",[self.dictReminderDetail objectForKey:@"msgboxid"]];
    if ([msgid isEqualToString:@"0"]) {
        msgid = [NSString stringWithFormat:@"%@",[self.dictReminderDetail objectForKey:@"msgschedulerid"]];
    }
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName =[[NSString alloc] initWithString:SNOOZE_TABLE];
    
    [dictReminderDetail setValue:@"SKIPPED" forKey:@"systemstatus"];
    NSString *skipReason = @"";
    if (buttonIndex!=3) {
        [self removeNotificationwithID:msgid];
        [recordDao1 deleteRecordWithMsgID:msgid];
    }
    switch (buttonIndex) {
        case 0:
            skipReason = @"I didn't need it right now";
            break;
        case 1:
            skipReason = @"I didn't have any";
            break;
        case 2:
            skipReason = @"Other";
            break;
        case 3:
        [self.navigationController popViewControllerAnimated:YES];
            break;
    }
    
    [recordDao updateAtIndex:iD Status:skipReason];
    NSArray *properties = [dictReminderDetail objectForKey:@"properties"];
    for (int i = 0; i < [properties count]; i++) {
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyName"] isEqualToString:@"Skipped Reason"]) {
            [[properties objectAtIndex:i] setValue:skipReason forKey:@"propertyValue"];
        }
    }
    [dictReminderDetail setValue:properties forKey:@"properties"];
    [self updateHistory:dictReminderDetail];
    
    NSArray *array = [self.navigationController viewControllers];
    if ([(YourReminderViewController*)[array objectAtIndex:[array count]-2] respondsToSelector:@selector(reloadTableView:)]) {
        [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addNotificationwithID:(NSString*)msgid {
    NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];
//    NSLog(@"%@",array);
    for (int i = 0; i < [array count]; i++) {
      UILocalNotification *notification1 = [array objectAtIndex:i];
        NSLog(@"%@",notification1.userInfo);
        if ([[notification1.userInfo objectForKey:@"Key 1"] isEqualToString:msgid]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification1];
        }
    }
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now=[NSDate date];
	localNotification.fireDate = [now addTimeInterval:60*60];
	localNotification.alertBody = @"You have a reminder!";
	localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone=[NSTimeZone defaultTimeZone];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:msgid, @"Key 1", @"snooze", @"Key 2", nil];
    localNotification.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}
- (void)removeNotificationwithID:(NSString*)msgid {
    NSArray *array =  [[UIApplication sharedApplication] scheduledLocalNotifications];
    //    NSLog(@"%@",array);
    for (int i = 0; i < [array count]; i++) {
        UILocalNotification *notification = [array objectAtIndex:i];
        if ([[notification.userInfo objectForKey:@"Key 1"] isEqualToString:msgid]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }

}
@end
