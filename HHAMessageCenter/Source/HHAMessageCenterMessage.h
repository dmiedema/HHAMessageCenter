//
//  HHAMessageCenterMessage.h
//  Househappy
//
//  Created by Daniel on 5/21/14.
//  Copyright (c) 2014 House Happy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHAMessageCenter.h"

@interface HHAMessageCenterMessage : NSObject

///
@property (assign, nonatomic) HHAMessageCenterMessagePriority priority;
///
@property (assign, nonatomic) NSTextAlignment textAlignment;
///
@property (copy, nonatomic) NSString *message;

/**
 *
 */
+ (instancetype)messageWithText:(NSString *)message;

/**
 *
 */
+ (instancetype)messageWithText:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority;

/**
 *
 */
+ (instancetype)messageWithText:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority textAlignment:(NSTextAlignment)alignment;

@end
