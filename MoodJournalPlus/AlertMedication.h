//
//  AlertMedication.h
//  MoodJournalPlus
//
//  Created by luan on 10/15/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//
@protocol AlertMedicationDelegate <NSObject>

- (void)showDetailReminder;

@end
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BackgroundService.h"
@interface AlertMedication : UIViewController<UIActionSheetDelegate>
{
    AppDelegate *appDelegate;
    
    RestConnection *restConnection;
    NSMutableDictionary *dictReminderDetail;
        RecordDao *recordDao;
}
@property (nonatomic, retain) NSMutableDictionary *dictReminderDetail;
@property (retain, nonatomic) IBOutlet UILabel *contentLabel;
@property (retain, nonatomic) IBOutlet UILabel *medicationNameLabel;
@property (nonatomic, assign) NSInteger iD;
@property (nonatomic, assign) id delegate;

@property (retain, nonatomic) IBOutlet UIView *refillView;

@property (retain, nonatomic) IBOutlet UILabel *contentRefillLabel;

- (IBAction)refilledAction:(id)sender;
- (IBAction)calltoRefillAction:(id)sender;
- (IBAction)snoozeRefillAction:(id)sender;

- (IBAction)action:(id)sender;
- (void)addNotificationwithID:(NSString*)msgid;
@end
