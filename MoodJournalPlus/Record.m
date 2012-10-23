
#import "Record.h"

@implementation Record

@synthesize content,status,msgid;

- (id)initWithIndex:(int)newIndex content:(NSString *)newContent status:(NSString*)newStatus msgid:(NSString*)newMsgid {
	if(self = [super init]){
		index = newIndex;
		self.content = newContent;
        self.status = newStatus;
        self.msgid = newMsgid;
	}
	
	return self;
}

- (int)getIndex{
	return index;
}

- (void)dealloc {
	[content release];
    [status release];
    [msgid release];
	[super dealloc];
}

@end