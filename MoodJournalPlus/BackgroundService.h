

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Record.h"
#import "RecordDao.h"
#import "ASIHTTPRequest.h"
#import "RestConnection.h"
#import "SBJSON.h"

@interface BackgroundService : NSObject {
    NSMutableArray *arrayRestConnection;
    RecordDao *recordDao;
    AppDelegate *appDelegate;
    NSInteger index;
    NSMutableArray *arrayIndex;
    NSMutableArray *arrayUpcomingReminder;
    NSInteger count;
    NSInteger totalCount;
}

@property (nonatomic, assign) BOOL isLoadingYourReminder;
@property (nonatomic, assign) BOOL isLoadingSetupReminder;
@property (nonatomic, assign) BOOL isLoadingUpcomingReminder;

-(void)login;
-(void)syncToServer;
-(NSDictionary*)skipReminder:(NSDictionary*)dict;
-(NSDictionary*)dissmissReminder:(NSDictionary*)dict;
-(NSDictionary*)tookAsShownReminder:(NSDictionary*)dict;
-(NSDictionary*)justTakenReminder:(NSDictionary*)dict;
-(NSDictionary*)skipReminder:(NSDictionary*)dict WithReason:(NSString*)reason;
-(void)expireReminder:(NSMutableDictionary*)dict;

-(void)getSetUpReminder;
-(void)getYourReminder;

- (void)addNotificationWithFireDate:(NSDate*)fireDate alertBody:(NSString *)alertBody withID:(NSString*)msgid; 
-(void)scheduleUpcomingReminder;
- (NSDate*)convertDate:(NSString*)floatString;

-(void)getUpcomingReminder;
-(void)getMotivationalMessage;
-(void)getMedicationList;
-(void)sortMedicationList;
-(void)registerPushNotification;
-(void)unregisterPushNotification;
-(void)verifyAccount;
//luan
-(void)getAllContacts;
-(void)addContact:(NSString*)name withPhone:(NSString*)phone andId:(NSString*)idContact;
@end
