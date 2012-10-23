

#import "ReminderDetailViewController.h"
#import "YourReminderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DownloadImage.h"
#import "ASIHTTPRequest.h"
#import "RestConnection.h"
#import "SBJSON.h"
#import "BackgroundService.h"
#import "ParseJSON.h"

// Private stuff
@interface ReminderDetailViewController ()
- (void)imageFetchComplete:(ASIHTTPRequest *)request;
- (void)imageFetchFailed:(ASIHTTPRequest *)request;
@end


@implementation ReminderDetailViewController
@synthesize dictReminderDetail;
@synthesize selectIndexPath;
@synthesize iD;
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Reminder Detail";
        //back button
        
        self.navigationController.navigationBarHidden = YES;
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
    [super dealloc];
    [viewMedicationReminder release];
    [labelCallOut release];
    [labelTimeSchedule release];
    [imageViewDetail release];
    [labelCallOutMedication release];
    [labelTimeScheduleMedication release];
    
    [viewSkipReason release];
    [labelName release];
    [labelNameMedication release];
    [imageViewCallOut release];
    [imageViewCallOutMedication release];
    [imageViewTimeSchedule release];
    [imageViewTimeScheduleMedication release];
    //[downloadImage release];
    [indicator release];
    [indicatorMedication release];
    //[selectIndexPath release];
    if (btnBack) {
        [btnBack release];
    }
    if (btnBack2) {
        [btnBack2 release];
    }
    if (downloadImage) {
        [downloadImage release];
    }
    if (stringLinkImage) {
        [stringLinkImage release];
    }
    //[recordDao release];
    [webView release];
}
- (NSString *)getProperty: (NSString *)key forData: (NSDictionary *)dataList{
    NSArray *properties;
    NSString *value=@"";
    NSLog(@"Data list %@",dataList);
    properties = [dataList objectForKey:@"properties"];
    for (int i = 0; i <[properties count]; i++) {
        //NSLog(@"data %d la %@ for key %@",i,[properties objectAtIndex:i], key);
        if ([[[properties objectAtIndex:i] objectForKey:@"propertyName"] isEqualToString:key] &&[[properties objectAtIndex:i] objectForKey:@"propertyValue"]!=nil) {
            value = [NSString stringWithString:[[properties objectAtIndex:i] objectForKey:@"propertyValue"]];
            break;
        }
    }
    return value;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    indicator.hidden = YES;
    indicatorMedication.hidden = YES;
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.showDetailFirst =  NO;
    NSInteger h = 44; //height of top image
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    downloadImage = [[DownloadImage alloc] init];
    //NSLog(@"%@",dictReminderDetail);
    if ([[dictReminderDetail objectForKey:@"messagecontent"] isEqualToString:@"DATA"] || [[dictReminderDetail objectForKey:@"messagecontent"] isEqualToString:@"HTML"]) {
        if ([[dictReminderDetail objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"]) { //Medication
            downloadImage.viewController = self;
            NSString *content;
            content = [appDelegate getProperty:@"Content" forData:dictReminderDetail];
            
            NSString *image;
            BOOL isHaveImage;
            image = [NSString stringWithFormat:@"%@",[appDelegate getProperty:@"Medication Image" forData:dictReminderDetail]];
            //h: new added
            NSLog(@"image %@",image);
            if ([image rangeOfString:@"http"].location == NSNotFound) {                 if ([image  isEqualToString:@""] || [image isEqualToString:@"null"]) {
                    isHaveImage = NO;
                }
                else {
                    if (appDelegate.isHaveInternetConnection) {
                        isHaveImage = YES;
                        image = [NSString stringWithFormat:@"http://50.19.106.70/CoreServices/images/stock/%@",image];
                        [downloadImage downloadImageWithData:[NSArray arrayWithArray:[NSArray arrayWithObject:image]]];
                    }
                    else {
                        imageViewDetail.image = [UIImage imageNamed:image];
                    }
                    imageViewDetail.frame = CGRectMake(27, 72, 46, 46);
                }
            }
            else{
                [downloadImage downloadImageWithData:[NSArray arrayWithArray:[NSArray arrayWithObject:image]]];
                imageViewDetail.frame = CGRectMake(27, 72, 46, 46);
            }
            //end new added
            stringLinkImage = [[NSString alloc] initWithString:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[image componentsSeparatedByString:@"/"] lastObject]]];
            [self.view addSubview:viewMedicationReminder];
            //err from this ----------------------------------------------------abc
            float height = [content sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(200, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
            if (isHaveImage) {
                labelNameMedication.frame = CGRectMake(85, 25+h, 200, height);
            }
            else {
                labelNameMedication.frame = CGRectMake(100, 25+h, 200, height);
            }
            labelNameMedication.text = content;
            
            labelCallOutMedication.frame = CGRectMake(79, labelNameMedication.frame.origin.y  + labelNameMedication.frame.size.height , 226, 20);
            if (height>40) {
                imageViewCallOutMedication.frame = CGRectMake(9, 8+h, 304, height + 35);
            }
            
            
            imageViewCallOutMedication.image = [[UIImage imageNamed:@"callOutMedication.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:50];
            
            imageViewTimeScheduleMedication.frame = CGRectMake(11, imageViewCallOutMedication.frame.origin.y + imageViewCallOutMedication.frame.size.height + 17, 299, 58);
            
            labelTimeScheduleMedication.frame = CGRectMake(51, imageViewTimeScheduleMedication.frame.origin.y + 22, 244, 24);
            
            double deliveryDate = [[dictReminderDetail objectForKey:@"deliverydate"] doubleValue];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterFullStyle];   
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            //[formatter setTimeZone:[NSTimeZone timeZoneWithName:[dictReminderDetail objectForKey:@"timeZone"]]];
            NSString *dateString = [NSString stringWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)(deliveryDate/1000)]]];
            labelTimeScheduleMedication.text = [dateString stringByReplacingOccurrencesOfString:[[dateString componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""];
            [formatter release];
            //NSLog(@"View 1"); err-------------------------------------
            
        }
        else {
            //Refill
            
            labelCallOut.text = [self getProperty:@"Content" forData:dictReminderDetail];
            NSLog(@"call out here %@",labelCallOut.text);
            if ([[dictReminderDetail objectForKey:@"reminderName"] isEqualToString:@"System Custom Reminder"] || [[dictReminderDetail objectForKey:@"reminderName"] isEqualToString:@"System Precanned Reminder"]) {
                labelName.text = @"Message";
            }
            else {
                labelName.text = [dictReminderDetail objectForKey:@"reminderName"];
            }
            //NSString *str = [[[dictReminderDetail objectForKey:@"properties"] objectAtIndex:0] objectForKey:@"propertyValue"];
            
            float height = [labelCallOut.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(204, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
            
            labelCallOut.frame = CGRectMake(101, 40+h, 204, height);
            
            imageViewCallOut.frame = CGRectMake(63, 17+h, 250, height + 30);
            imageViewCallOut.image = [[UIImage imageNamed:@"callOut.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:50];
            
            double deliveryDate = [[dictReminderDetail objectForKey:@"deliverydate"] doubleValue];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterFullStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            
            NSString *dateString = [NSString stringWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)((double)deliveryDate/(double)1000)]]];
            
            labelTimeSchedule.text = [dateString stringByReplacingOccurrencesOfString:[[dateString componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""];
            float h2 = MAX(162, labelCallOut.frame.origin.y+labelCallOut.frame.size.height + 20);
            
            imageViewTimeSchedule.frame = CGRectMake(11, h2, 299, 58);
            labelTimeSchedule.frame = CGRectMake(50, imageViewTimeSchedule.frame.origin.y+23, 244, 21);
            [formatter release];
        }
        viewSkipReason.frame = CGRectMake(0, 460, 320, 415);
        [self.view addSubview:viewSkipReason];
        
        
        recordDao = [[RecordDao alloc] init];
        recordDao.tableName = [[NSString alloc] initWithString:YOUR_REMINDER_TABLE];
    }
    else {
        [self performSelectorOnMainThread:@selector(addWebView) withObject:nil waitUntilDone:NO];
    }
}

- (void)addWebView {
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 372)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dictReminderDetail objectForKey:@"messagecontent"]]]];
    //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
    [self.view addSubview:webView];
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

- (IBAction)skipReasonAction:(id)sender {
    if (!isRequesting) {
        NSString *msgid = [NSString stringWithFormat:@"%@",[self.dictReminderDetail objectForKey:@"msgboxid"]];
        if ([msgid isEqualToString:@"0"]) {
            msgid = [NSString stringWithFormat:@"%@",[self.dictReminderDetail objectForKey:@"msgschedulerid"]];
        }
        RecordDao *recordDao1 = [[RecordDao alloc] init];
        recordDao1.tableName =[[NSString alloc] initWithString:SNOOZE_TABLE];
        [dictReminderDetail setValue:@"SKIPPED" forKey:@"systemstatus"];
        NSString *skipReason = @"";
        if (([sender tag]==0)||([sender tag]==1)||([sender tag]==2)) {
            [self removeNotificationwithID:msgid];
            [recordDao1 deleteRecordWithMsgID:msgid];
        }
        switch ([sender tag]) {
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
                [viewSkipReason setFrame:CGRectMake(0, 142, 320, 318)];
                // set up an animation for the transition between the views
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.5];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromBottom];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
                [[viewSkipReason  layer] addAnimation:animation forKey:kCATransition];
                break;
            default:
                //[self.navigationController popViewControllerAnimated:YES];
                [self pressBack:nil];
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
}
- (IBAction)skip:(id)sender {
    if (!isRequesting) {
        isRequesting = YES;
        [recordDao updateAtIndex:iD Status:@"skip"];
        [dictReminderDetail setValue:@"SKIPPED" forKey:@"systemstatus"];
        [self updateHistory:dictReminderDetail];
        NSArray *array = [self.navigationController viewControllers];
        if ([(YourReminderViewController*)[array objectAtIndex:[array count]-2] respondsToSelector:@selector(reloadTableView:)]) {
            [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
        }
        [self.navigationController popViewControllerAnimated:YES];
        

        
    }
}
- (IBAction)dissmis:(id)sender {
    if (!isRequesting) {
        [recordDao updateAtIndex:iD Status:@"dissmis"];
        [dictReminderDetail setValue:@"COMPLETE" forKey:@"systemstatus"];
        [self updateHistory:dictReminderDetail];
        NSArray *array = [self.navigationController viewControllers];
        if ([(YourReminderViewController*)[array objectAtIndex:[array count]-2] respondsToSelector:@selector(reloadTableView:)]) {
            [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
     
    }
}
- (IBAction)action:(id)sender { //action for reminder not medication
    if (!isRequesting) {
        isRequesting = YES;
        indicatorMedication.hidden = NO;
        [indicatorMedication startAnimating];
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
            case 1:
            {
                NSArray *array = [self.navigationController viewControllers];
                [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
                [recordDao1 insertSnoozeWithMsgId:msgid];
                [self performSelector:@selector(addNotificationwithID:) withObject:msgid afterDelay:1.0];
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case 2:
            {
                isRequesting = NO;
                indicatorMedication.hidden = YES;
                [viewSkipReason setFrame:CGRectMake(0, 142, 320, 318)];
                // set up an animation for the transition between the views
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.5];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromTop];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [[viewSkipReason layer] addAnimation:animation forKey:@"SwitchToView1"];
            }
                break;
            default:
                break;
        }
        [formatter release];
        [recordDao1 release];
    }
    
}

- (IBAction)pressBack:(id)sender{
    /*YourReminderViewController *y=[[YourReminderViewController alloc] init];
     [self.navigationController pushViewController:y animated:YES];
     [y release];*/
    if (isRequesting==YES) {
        //return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressCancelReminder:(id)sender{
    [viewSkipReason setFrame:CGRectMake(0, 460, 320, 318)];
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [[viewSkipReason  layer] addAnimation:animation forKey:kCATransition];
}
- (void)hideBackBtn{
    NSLog(@"Hidden btn Back");
    //btnBack.hidden = YES;
    //btnBack2.hidden = YES;
}
#pragma mark -
#pragma mark asihttprequest 
- (void)imageFetchComplete:(ASIHTTPRequest *)request {
    NSLog(@"complete");
    imageViewDetail.image = [UIImage imageWithContentsOfFile:stringLinkImage];
}
- (void)imageFetchFailed:(ASIHTTPRequest *)request {
    NSLog(@"failed");
    //imageViewDetail.image = [UIImage imageWithContentsOfFile:stringLinkImage];
    imageViewDetail.image = [UIImage imageNamed:@"Medication Reminder"];
}

- (void)uploadFailed:(ASIHTTPRequest *)theRequest {
    isRequesting = NO;
    indicator.hidden = YES;
    indicatorMedication.hidden = YES;
    
    
    NSArray *array = [self.navigationController viewControllers];
    if ([(YourReminderViewController*)[array objectAtIndex:[array count]-2] respondsToSelector:@selector(reloadTableView:)]) {
        [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    NSLog(@"%@",[theRequest responseString]);
    isRequesting = NO;
    indicatorMedication.hidden = YES;
    indicator.hidden = YES;
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",responseData);
    if (!isSync) {
        if ([responseData rangeOfString:@"{Status: \"Status updated successfully for msgboxid"].location != NSNotFound) {
            [recordDao deleteAtIndex:iD];
            //appDelegate.theFirstShowYourReminder = YES;
            NSArray *array = [self.navigationController viewControllers];
            if ([(YourReminderViewController*)[array objectAtIndex:[array count]-2] respondsToSelector:@selector(reloadTableView:)]) {
                [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadData3];
            }
            //[(YourReminderViewController*)[array objectAtIndex:[array count]-2] requestData];
            [self.navigationController popViewControllerAnimated:YES];
            /*YourReminderViewController *y = [[YourReminderViewController alloc] init];
             [self.navigationController pushViewController:y animated:YES];
             [y release];*/
        }
    }
    else {
        [recordDao deleteAtIndex:iD];
        //appDelegate.theFirstShowYourReminder = YES;
        NSArray *array = [self.navigationController viewControllers];
        if ([(YourReminderViewController*)[array objectAtIndex:[array count]-2] respondsToSelector:@selector(reloadTableView:)]) {
            [(YourReminderViewController*)[array objectAtIndex:[array count]-2] reloadTableView:selectIndexPath];
        }
        [(YourReminderViewController*)[array objectAtIndex:[array count]-2] requestData];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [responseData release];
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
	localNotification.fireDate = [now addTimeInterval:30];
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
