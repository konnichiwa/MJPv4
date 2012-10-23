//
//  MedicationDetailViewController.m
//  MoodJournalPlus
//
//  Created by Java-Dive on 1/13/12.
//  Copyright (c) Java-Dive Inc. 2009. All rights reserved.
//

#import "MedicationDetailViewController.h"
#import "SetupAReminderViewController.h"
#import "DownloadImage.h"
#import "ASIHTTPRequest.h"

// Private stuff
@interface MedicationDetailViewController ()
- (void)imageFetchComplete:(ASIHTTPRequest *)request;
- (void)imageFetchFailed:(ASIHTTPRequest *)request;
@end


@implementation MedicationDetailViewController
@synthesize dictMedicationDetail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Medication Detail";
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
    [dictMedicationDetail release];
    [labelName release];
    [labelIngredient release];
    [labelSize release];
    [labelInactiveIngredient release];
    [labelImprint release];
    [labelColor release];
    [labelAuthor release];
    [labelShape release];
    [imageView release];
    [stringLinkImage release];
    [imageViewBG release];
    [labelAuthorText release];
    
    //[downloadImage release];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    labelName.text = [dictMedicationDetail objectForKey:@"drug_name"];
    labelImprint.text = [dictMedicationDetail objectForKey:@"imprint"];
    labelShape.text = [dictMedicationDetail objectForKey:@"shape"];
    labelColor.text = [dictMedicationDetail objectForKey:@"color"];
    labelSize.text = [dictMedicationDetail objectForKey:@"size"];
    labelIngredient.text = [dictMedicationDetail objectForKey:@"ingredients"];
    
    NSString *inactiveIngredient = [dictMedicationDetail objectForKey:@"inactive_ingredients"];
    float height = [inactiveIngredient sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(280, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
    labelInactiveIngredient.frame = CGRectMake(67, 76, 280, height);
    labelInactiveIngredient.text = inactiveIngredient;
    
    labelAuthorText.frame = CGRectMake(67, labelInactiveIngredient.frame.size.height + labelInactiveIngredient.frame.origin.y + 5, 200, 21);
    labelAuthor.frame = CGRectMake(67, labelAuthorText.frame.size.height + labelAuthorText.frame.origin.y + 5, 200, 21);
    labelAuthor.text = [dictMedicationDetail objectForKey:@"author"];
    
    imageViewBG.frame = CGRectMake(52, 3, 304, labelAuthor.frame.size.height + labelAuthor.frame.origin.y);
    imageViewBG.image = [[UIImage imageNamed:@"detailMedicationBG.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:50];
    
    downloadImage = [[DownloadImage alloc] init];
    NSString *image = [dictMedicationDetail objectForKey:@"image_url"];
    stringLinkImage = [[NSString alloc] initWithString:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[image componentsSeparatedByString:@"/"] lastObject]]];
    downloadImage.viewController = self;
    [downloadImage downloadImageWithData:[NSArray arrayWithArray:[NSArray arrayWithObject:image]]];
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
#pragma mark -
#pragma mark asihttprequest 
- (void)imageFetchComplete:(ASIHTTPRequest *)request {
    NSLog(@"complete");
    imageView.image = [UIImage imageWithContentsOfFile:stringLinkImage];
}
- (void)imageFetchFailed:(ASIHTTPRequest *)request {
    NSLog(@"failed");
    imageView.image = [UIImage imageWithContentsOfFile:stringLinkImage];
}

#pragma mark -
#pragma mark action
- (void)done {
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] dictParamValueReminder] setObject:[dictMedicationDetail objectForKey:@"drug_name"] forKey:@"Med"];
    
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] dictParamValueReminder] setObject:stringLinkImage forKey:@"Image"];
    [[(SetupAReminderViewController*)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3] tableView] reloadData];
    
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count]-3]  animated:YES]; 
}
@end
