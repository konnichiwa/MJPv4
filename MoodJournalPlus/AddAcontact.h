//
//  AddAcontact.h
//  MoodJournalPlus
//
//  Created by luan on 10/11/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@interface AddAcontact : UIViewController<UITextFieldDelegate>
{
    NSString *typecontact;
}
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *progess;
@property (retain, nonatomic) IBOutlet UITextField *nameText;
@property (retain, nonatomic) IBOutlet UITextField *phonetext1;
@property (retain, nonatomic) IBOutlet UITextField *phonetext2;
@property (retain, nonatomic) IBOutlet UITextField *phonetext3;
@property (nonatomic) UIKeyboardType currentKBType;
@property(nonatomic,strong) UITextField *curTextField;
@property(nonatomic,strong) UIButton *doneButton;
@property(nonatomic) BOOL doneButtonDisplayed;
@property(nonatomic,retain) NSString *tit;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *phone;
@property(nonatomic) BOOL isEditMode;
- (IBAction)back:(id)sender;
- (IBAction)saveContact:(id)sender;
@end
