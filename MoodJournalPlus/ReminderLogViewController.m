

#import "ReminderLogViewController.h"
//#import "DownloadImage.h"
#import "ASIHTTPRequest.h"
#import "TermOfUseViewController.h"
#import "MoreOptionsViewController.h"
#import "AppDelegate.h"
// Private stuff
/*
@interface ReminderLogViewController ()
- (void)imageFetchComplete:(ASIHTTPRequest *)request;
- (void)imageFetchFailed:(ASIHTTPRequest *)request;
@end*/

@implementation ReminderLogViewController
@synthesize dictReminderDetail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Reminder Log";
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc { //NSLog(@"Call Dealloc For Reminder log");
    [super dealloc];
    [imageViewCallOut release];
    [imageViewScheduleTime release];
    [imageViewStatus release];
    //[labelContent release];
    [labelName release];
    [labelScheduleTime release];
    [labelStatus release];
    [dictReminderDetail release];
    [viewMedication release];
    [imageViewCallOutMedication release];
    [imageViewScheduleMedication release];
    [imageViewStatusMedication release];
    //[labelAmountMedication release];
    [labelContentMedication release];
    [labelScheduleMedication release];
    [labelStatusMedication release];
    [imageViewReminderPhoto release];
    //s[downloadImage release];
    [stringLinkImage release];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@ reminder detail",dictReminderDetail);
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%@",dictReminderDetail);
    //downloadImage = [[DownloadImage alloc] init];
    if ([[dictReminderDetail objectForKey:@"reminderName"] isEqualToString:@"Medication Reminder"]) { //Medication Reminder
        [self.view addSubview:viewMedication];
        //NSArray *properties = [dictReminderDetail objectForKey:@"properties"];
        NSString *content;
        NSLog(@"%@",[NSString stringWithFormat:@"%@.png",[dictReminderDetail objectForKey:@"reminderName"]]);
        
        NSString *image;
        image = [appDelegate getProperty:@"Medication Image" forData:dictReminderDetail];
        if (imageViewReminderPhoto != nil) {
            //imageViewReminderPhoto.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[dictReminderDetail objectForKey:@"reminderName"]]];
            if (![[image stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
                imageViewReminderPhoto.image = [UIImage imageNamed:image];
                imageViewReminderPhoto.frame = CGRectMake(25, 66, 45, 45);
            }
        }
        
        NSString *takenTime;
        
        takenTime = [appDelegate getProperty:@"Time Taken" forData:dictReminderDetail];
        content = [appDelegate getProperty:@"Content" forData:dictReminderDetail];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        labelContentMedication.text = content;
        if ([[dictReminderDetail objectForKey:@"systemstatus"] isEqualToString:@"SKIPPED"]) {
            imageViewStatusMedication.image = [UIImage imageNamed:@"skippedBG.png"];
            labelStatusMedication.text = [appDelegate getProperty:@"Skipped Reason" forData:dictReminderDetail];
        }
        else {
            imageViewStatusMedication.image = [UIImage imageNamed:@"takenBG.png"];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
            NSDate *date = [formatter dateFromString:takenTime];
            [formatter setDateStyle:NSDateFormatterLongStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            labelStatusMedication.text = [formatter stringFromDate:date];
        }
        
        NSString *delivery = [dictReminderDetail objectForKey:@"deliverydate"];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        NSString *dateStr = [NSString stringWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)([delivery doubleValue]/(double)1000)]]];
        labelScheduleMedication.text = [NSString stringWithFormat:@"Scheduled time was %@",[dateStr stringByReplacingOccurrencesOfString:[[dateStr componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""]];
        [formatter release];
        
        //only need to show medication name.
        labelName.text = [appDelegate getProperty:@"Medication Name" forData:dictReminderDetail];
    }
    else { //refill Reminder type
        if ([[dictReminderDetail objectForKey:@"reminderName"] isEqualToString:@"System Custom Reminder"] || [[dictReminderDetail objectForKey:@"reminderName"] isEqualToString:@"System Precanned Reminder"]) {
            labelNameRefil.text = @"Message";
        }
        else {
            labelNameRefil.text = [dictReminderDetail objectForKey:@"reminderName"];
        }
        
        double deliveryDate = [[dictReminderDetail objectForKey:@"deliverydate"] doubleValue];
        NSLog(@"%@",[dictReminderDetail objectForKey:@"deliverydate"]);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        //[formatter setTimeZone:[NSTimeZone timeZoneWithName:[dictReminderDetail objectForKey:@"timeZone"]]];
        NSString *dateString = [NSString stringWithString:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)(deliveryDate/1000)]]];
    
        [formatter release];
        labelContent.text = [appDelegate getProperty:@"Content" forData:dictReminderDetail];
        labelScheduleTime.text = [dateString stringByReplacingOccurrencesOfString:[[dateString componentsSeparatedByString:@" "] objectAtIndex:0] withString:@""];
        labelStatus.text = [dictReminderDetail objectForKey:@"systemstatus"];
        float h = 44;
        NSString *str = labelContent.text;
        float height = [str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(205, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
        labelContent.frame = CGRectMake(98, 33+h, 204, height);
        imageViewCallOut.frame = CGRectMake(63, 10+h, 248, height + 32);
        imageViewCallOut.image = [[UIImage imageNamed:@"callOut.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:50];
    }
    
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

- (IBAction)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressTermOfUse:(id)sender{
    if(!appDelegate.isAirplaneModeSet)
    {
        TermOfUseViewController *t = [[TermOfUseViewController alloc] init];
        [self.navigationController pushViewController:t animated:YES];
        [t release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:NOT_AVAIL_OFFLINE_MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }    
}

- (IBAction)pressMoreOptions:(id)sender{
    if(!appDelegate.isAirplaneModeSet)
    {
        MoreOptionsViewController *m = [[MoreOptionsViewController alloc] init];
        [self.navigationController pushViewController:m animated:YES];
        [m release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:POPUP_TITLE message:NOT_AVAIL_OFFLINE_MSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
/*
#pragma mark -
#pragma mark asihttprequest 
- (void)imageFetchComplete:(ASIHTTPRequest *)request {
    NSLog(@"complete");
    imageViewReminderPhoto.image = [UIImage imageWithContentsOfFile:stringLinkImage];
}
- (void)imageFetchFailed:(ASIHTTPRequest *)request {
    NSLog(@"failed");
    imageViewReminderPhoto.image = [UIImage imageWithContentsOfFile:stringLinkImage];
}*/
@end
