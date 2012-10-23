//
//  InstructionsViewController.h
//  MoodJournalPlus
//
//  Created by le hung on 12/28/11.
//  Copyright (c) 2011 CNCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstructionsViewController : UIViewController {
    IBOutlet UIImageView *imageViewAmoundReminderBG;
    IBOutlet UILabel *labelAmountReminder;
    IBOutlet UILabel *labelText;
    IBOutlet UIButton *buttonShowYourReminder;
}

- (IBAction)showYourReminder:(id)sender;
@end
