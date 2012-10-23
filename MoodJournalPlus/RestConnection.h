
//9/27/2012
#import <Foundation/Foundation.h>
@class ASIFormDataRequest;
@class AppDelegate;
@interface RestConnection : NSObject {
    ASIFormDataRequest *request;
    AppDelegate *appDelegate;
}
@property (retain, nonatomic) ASIFormDataRequest *request;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, assign) BOOL isBackgroudService;

- (void)getDataWithPathSource:(NSString *)pathSource andParam:(NSArray*)param forService:(NSString*)service;
- (void)postDataWithPathSource:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSString*)postData;
- (void)postDataWithPathSource2:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSArray*)postData;
- (void)postDataWithPathSource3:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSArray*)postData;
- (void)putDataWithPathSource:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSString*)postData;
- (void)deleteDataWithPathSource:(NSString *)pathSource andParam:(NSArray*)param withReminderID:(NSString*)reminderID;
- (NSString*)createSignatureWithPathSource:(NSString*)pathSource andParam:(NSArray*)arrayParam;
- (NSString *)sha1:(NSString *)str;
- (NSMutableArray*)sortArrayByAlphabet:(NSArray*)array; 
@end
