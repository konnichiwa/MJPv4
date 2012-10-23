//
//  AddReminderTypeView.h
//  MoodJournalPlus
//
//  Created by Java-Dive on 1/1/12.
//  Copyright (c) Java-Dive Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol AddReminderTypeViewDelegate <NSObject>
@required 
-(void)selectRemiderType:(ReminderType)reminderType;

@end

@interface AddReminderTypeView : UIView {
    
}
@property (nonatomic, assign) id <AddReminderTypeViewDelegate> delegate;

- (IBAction)selectReminderType:(id)sender;
@end
