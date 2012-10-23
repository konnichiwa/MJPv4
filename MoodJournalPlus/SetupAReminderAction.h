
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Record.h"
#import "RecordDao.h"
#import "ASIHTTPRequest.h"
#import "RestConnection.h"
#import "SBJSON.h"

@interface SetupAReminderAction : NSObject {
    NSMutableArray *arrayRestConnection;
    RecordDao *recordDao;
    AppDelegate *appDelegate;
    NSInteger index;
}

-(void)syncToServer;
-(void)activeReminder:(NSDictionary*)dict;
-(void)inactiveReminder:(NSDictionary*)dict;
-(void)deleteReminder:(NSDictionary*)dict;
-(void)updateReminder:(NSDictionary*)dict;
@end
