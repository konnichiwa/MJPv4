//
//  ChooseStrength.h
//  MoodJournalPlus
//
//  Created by luan on 10/20/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ChooseStrength : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
NSMutableArray *strengthList;
AppDelegate *appDelegate;
}
@property(nonatomic,retain) NSString* medicationName;
@property(nonatomic,retain) NSMutableArray *strengthList;
@property (retain, nonatomic) IBOutlet UIButton *backPress;
- (IBAction)backAction:(id)sender;
@end
