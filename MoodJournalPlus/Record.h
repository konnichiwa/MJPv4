

#import <Foundation/Foundation.h>

@interface Record : NSObject {
	int index;
	NSString *content;
	NSString *status;
    NSString *msgid;
}

@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *msgid;

- (id)initWithIndex:(int)newIndex content:(NSString *)newContent status:(NSString*)newStatus msgid:(NSString*)newMsgid;
- (int)getIndex;

@end
