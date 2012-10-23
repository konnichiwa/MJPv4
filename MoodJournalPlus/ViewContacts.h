//
//  ViewContacts.h
//  MoodJournalPlus
//
//  Created by luan on 10/11/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ViewContacts : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
NSMutableArray *allContacts;
NSMutableDictionary *aContact;
AppDelegate *appDelegate;
        NSInteger index;
    NSString *typeContact;
    BOOL isDeleteCell;
}

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *progess;
@property(nonatomic,retain) NSMutableArray *allContacts;
@property(nonatomic,retain) NSString *tit;
@property (retain, nonatomic) IBOutlet UILabel *titl;
@property (retain, nonatomic) IBOutlet UITableView *table;
@property (retain, nonatomic) IBOutlet UIButton *bottomAction;


- (IBAction)back:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)delete:(id)sender;
@end
