//
//  MyContacts.h
//  MoodJournalPlus
//
//  Created by luan on 10/9/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@interface MyContacts : UIViewController
{    
AppDelegate *appDelegate;
    NSMutableArray *contactType;
    NSMutableArray *doctorContact;
    NSMutableArray *phamacyContact;
    NSMutableArray *otherContact;
}
- (IBAction)backMoreOption:(id)sender;

@end
