
#import <Foundation/Foundation.h>
#import "BaseDao.h"


@interface RecordDao : BaseDao {
    
}
@property (nonatomic, retain) NSString *tableName;

-(NSMutableArray *)resultSet;
-(NSMutableArray*)resultSetWithStatus:(NSString*)status;
-(NSMutableArray*)resultSetWithoutStatus:(NSString*)status;
-(NSMutableArray*)resultSetWithoutNormalStatus;
-(NSMutableArray*)getFiveLastReminder;
-(NSInteger)getIndexOfARecordWithMsgid:(NSString*)msgid;
-(void)insertWithContent:(NSString *)content;
-(void)insertWithContent:(NSString *)content WithStatus:(NSString*)status WithMsgid:(NSString*)msgid;
-(void)insertSnoozeWithMsgId:(NSString *)Msgid;
-(BOOL)hadMsgIdInSnoozeTable:(NSString*)msgid;
-(BOOL)updateAtIndex:(int)index Content:(NSString *)content;
-(BOOL)updateAtIndex:(int)index Status:(NSString *)status;
-(BOOL)updateAtIndex:(int)index Content:(NSString *)content Status:(NSString*)status;
-(BOOL)updateStatus:(NSString*)status ForMsg:(NSString*)msgid;
-(BOOL)deleteAtIndex:(int)index;
-(BOOL)deleteNormalRecord;
-(BOOL)deleteAllData;
-(BOOL)deleteRecordWithMsgID:(NSString*)msgid;

-(void)insertContactWithName:(NSString *)name phone:(NSString*)phone andtype:(NSString*)type andId:(NSString*)idContact;

-(NSMutableArray *)getContactsFromType:(NSString*)type;
-(BOOL)updateSnoozeAtMgsid:(NSString*)mgs withValue:(NSInteger)value;

-(NSString*)searchIdfromContactWithName:(NSString*)name;
@end
