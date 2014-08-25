//
//  HHAMessageCenterMessage.m
//  Househappy
//
//  Created by Daniel on 5/21/14.
//  Copyright (c) 2014 House Happy. All rights reserved.
//

#import "HHAMessageCenterMessage.h"

@implementation HHAMessageCenterMessage
+ (instancetype)messageWithText:(NSString *)message {
    return [self messageWithText:message priority:HHAMessageCenterMessagePriorityNormal];
}
+ (instancetype)messageWithText:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority {
    return [self messageWithText:message priority:priority textAlignment:NSTextAlignmentCenter];
}
+ (instancetype)messageWithText:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority textAlignment:(NSTextAlignment)alignment {
    return [[self alloc] initWithMessageText:message priority:priority textAlignment:alignment];
}

- (instancetype)initWithMessageText:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority textAlignment:(NSTextAlignment)alignment {
    self = [super init];
    if (self) {
        _message       = message;
        _priority      = priority;
        _textAlignment = alignment;
    }
    return self;
}

@end
