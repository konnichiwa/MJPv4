//
//  ReminderMessageCell.h
//  MoodJournalPlus
//
//  Created by luan on 10/12/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderMessageCell : UITableViewCell
{
IBOutlet UILabel *tit;
IBOutlet UITextField *textMessage;

}
@property (retain, nonatomic) IBOutlet UILabel *tit;
@property (retain, nonatomic) IBOutlet UITextField *textMessage;

@end
