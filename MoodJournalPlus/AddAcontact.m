//
//  AddAcontact.m
//  MoodJournalPlus
//
//  Created by luan on 10/11/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import "AddAcontact.h"
#import "ViewContacts.h"
#import "RestConnection.h"
#import "BackgroundService.h"
#import "AddAcontact.h"
@interface AddAcontact ()
{AppDelegate *appDelegate;
    NSInteger index;
}
@end

@implementation AddAcontact
@synthesize progess;
@synthesize nameText;
@synthesize phonetext1;
@synthesize phonetext2;
@synthesize phonetext3;
@synthesize doneButton;
@synthesize curTextField;
@synthesize currentKBType;
@synthesize doneButtonDisplayed;
@synthesize tit;
@synthesize phone;
@synthesize name;
@synthesize isEditMode;
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
 [progess setHidden:YES];
}

- (void)viewDidUnload
{
    [self setNameText:nil];
    [self setPhonetext1:nil];
    [self setPhonetext2:nil];
    [self setPhonetext3:nil];

    [self setProgess:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardDidShow:) 
                                                     name:UIKeyboardDidShowNotification 
                                                   object:nil];     
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
    }
    for(UIButton *button in [self.view subviews]) {
        if(button.tag==100 ){
            [button removeFromSuperview];
            
        }
    }
    if (isEditMode) {
        self.nameText.text=self.name;
        NSLog(@"%@",phone);
        
        self.phonetext1.text=[self.phone substringWithRange: NSMakeRange (0, 3)];
        self.phonetext2.text=[self.phone substringWithRange: NSMakeRange (3, 3)];
        self.phonetext3.text=[self.phone substringFromIndex:6];
    }
        if ([self.tit isEqualToString:@"Doctors"]) {
            typecontact=[NSString stringWithFormat:@"Doctor"];
        }
        if ([self.tit isEqualToString:@"Pharmacies"]) {
            typecontact=[NSString stringWithFormat:@"Pharmacy"];                        
        }
        if ([self.tit isEqualToString:@"Other"]) {
            typecontact=[NSString stringWithFormat:@"Other"];  
        }
        [typecontact retain];
    

}
-(void)viewWillDisappear:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIKeyboardDidShowNotification 
                                                      object:nil];     
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self                                                 
                                                        name:UIKeyboardWillShowNotification 
                                                      object:nil];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveContact:(id)sender {
    NSString *phone1=[NSString stringWithFormat:@"%@",phonetext1.text];
    phone1=[phone1 stringByAppendingFormat:@"%@",phonetext2.text];
    phone1=[phone1 stringByAppendingFormat:@"%@",phonetext3.text];
    [self.nameText.text retain];
    NSLog(@"%@",typecontact);
    [progess setHidden:NO];
    [progess setHidesWhenStopped:YES];
    [progess startAnimating];
    if (isEditMode) {
        RecordDao *recordDao1 = [[RecordDao alloc] init];
        NSLog(@"%@",name);
        NSLog(@"%@",[appDelegate doCipher:name :kCCEncrypt]);
        recordDao1.tableName =[[NSString alloc] initWithString:CONTACT_TABLE];
        [self editContactWith:self.nameText.text andPhone:phone1 andIdContact:[recordDao1 searchIdfromContactWithName:[appDelegate doCipher:name :kCCEncrypt]]];
            } 
    else {
         [self addContactWith:self.nameText.text andPhone:phone1 andtype:typecontact];
            }
    

}
- (void)dealloc {
    [nameText release];
    [phonetext1 release];
    [phonetext2 release];
    [phonetext3 release];
    [progess release];
    [super dealloc];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField; 
{
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
    if (self.currentKBType == 4 || self.currentKBType == 5) {
        if (!doneButtonDisplayed) {
            [self addButtonToKeyboard];
        }
    } else {
        if (doneButtonDisplayed) {
            [self removeButtonFromKeyboard];
        }
    }
}

- (void)keyboardDidShow:(NSNotification *)note {
    NSLog(@"%d",self.currentKBType);
    if (self.currentKBType == 4 || self.currentKBType == 5) {
        if (!doneButtonDisplayed) {
            [self addButtonToKeyboard];
        }
    } else {
        if (doneButtonDisplayed) {
            [self removeButtonFromKeyboard];
        }
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.currentKBType = textField.keyboardType;
    if (textField.keyboardType == 4 || textField.keyboardType == 5) {
        if (!doneButtonDisplayed) {
            [self addButtonToKeyboard];
        }
    } else {
        if (doneButtonDisplayed) {
            [self removeButtonFromKeyboard];
        }
    }
    
    self.curTextField = textField;
    return YES;
}

- (void)addButtonToKeyboard {
    
    // create custom button
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    
    [doneButton setImage:[UIImage imageNamed:@"doneup.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"donedown.png"] forState:UIControlStateHighlighted];
    doneButton.tag=100;
    [doneButton addTarget:self action:@selector(resignKeyboard) forControlEvents:UIControlEventTouchUpInside];
    // locate keyboard view
    if ([[[UIApplication sharedApplication] windows] count] > 1) {
        UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        UIView* keyboard;
        for(int i=0; i<[tempWindow.subviews count]; i++) {
            keyboard = [tempWindow.subviews objectAtIndex:i];
            // keyboard found, add the button
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES) {
                [keyboard addSubview:doneButton];
                self.doneButtonDisplayed = YES;
            }
        }
        
    }
}

- (void)removeButtonFromKeyboard {  
    [doneButton removeFromSuperview];
    self.doneButtonDisplayed = NO;
}
-(void)resignKeyboard {
    [self.curTextField resignFirstResponder];
    self.doneButtonDisplayed = NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (textField==phonetext1&&([string length]!=0)) {
    if ([textField.text length]>2) {
        if ([phonetext2.text length]>2) {
            [phonetext3 becomeFirstResponder];
        }
        else {
            [phonetext2 becomeFirstResponder];
        }
        
    }  
    }
    if (textField==phonetext2&&([string length]!=0)) {
        if ([textField.text length]>2) {
            [phonetext3 becomeFirstResponder];
        }
    }
    return YES; 
}

-(void)addContactWith:(NSString*)name1 andPhone:(NSString*)phone1 andtype:(NSString*)type
{
        NSMutableDictionary *dat=[[NSMutableDictionary alloc] init];
        [dat setObject:[appDelegate doCipher:name1 :kCCEncrypt]  forKey:@"contactname"];
        [dat setObject:[appDelegate doCipher:phone1 :kCCEncrypt]  forKey:@"contactphone"];
        //[dat setObject:@"6344671" forKey:@"contactid"];
        SBJSON *json = [SBJSON new];
        NSString *postData = [json stringWithObject:dat];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
        if (appDelegate.deviceToken != nil) {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
        }
        else {
            [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
        }
        
        RestConnection *restConnection = [[RestConnection alloc] init];
        restConnection.viewController=self;
        [restConnection postDataWithPathSource:[NSString stringWithFormat:@"/rest/Contact/type/%@",type] andParam:arr withPostData:postData];
        [arr release];
}
-(void)editContactWith:(NSString*)name1 andPhone:(NSString*)phone1 andIdContact:(NSString*)idContact
{
    NSMutableDictionary *dat=[[NSMutableDictionary alloc] init];
    [dat setObject:[appDelegate doCipher:name1 :kCCEncrypt]  forKey:@"contactname"];
    [dat setObject:[appDelegate doCipher:phone1 :kCCEncrypt]  forKey:@"contactphone"];
    SBJSON *json = [SBJSON new];
    NSString *postData = [json stringWithObject:dat];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:application_key forKey:@"application_token"]];
    if (appDelegate.deviceToken != nil) {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:appDelegate.deviceToken forKey:@"token"]];
    }
    else {
        [arr addObject:[NSMutableDictionary dictionaryWithObject:@"" forKey:@"token"]];
    }
    
    RestConnection *restConnection = [[RestConnection alloc] init];
    restConnection.viewController=self;
    [restConnection putDataWithPathSource:[NSString stringWithFormat:@"/rest/Contact/%@",idContact] andParam:arr withPostData:postData];
    [arr release];
}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest {
    NSString *responseData = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"-=-=-=%@",responseData);
    
    SBJSON *parser = [[SBJSON new] autorelease];
    id dataDict = [parser objectWithString:responseData];    
    NSLog(@"%@",dataDict);  
    RecordDao *recordDao1 = [[RecordDao alloc] init];
    recordDao1.tableName =[[NSString alloc] initWithString:CONTACT_TABLE];
    [recordDao1 insertContactWithName:[dataDict objectForKey:@"contactname"] phone:[dataDict objectForKey:@"contactphone"] andtype:typecontact andId:[dataDict objectForKey:@"contactid"]];
    [recordDao1 release];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
