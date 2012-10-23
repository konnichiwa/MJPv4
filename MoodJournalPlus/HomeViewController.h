//
//  HomeViewController.h
//  MoodJournalPlus
//
//  Created by le hung on 12/27/11.
//  Copyright (c) 2011 CNCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController {
    IBOutlet UIImageView *imageViewAmoundReminderBG;
    IBOutlet UILabel *labelAmountReminder;
    IBOutlet UILabel *labelText;
    IBOutlet UIButton *buttonShowYourReminder;
}

- (IBAction)showYourReminder:(id)sender;
- (IBAction)setUpReminder:(id)sender;
- (IBAction)settingAccount:(id)sender;

@end
