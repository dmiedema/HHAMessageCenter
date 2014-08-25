//
//  NSNotificationCenter+HelperMethods.h
//  HHAMessageCenter
//
//  Created by Daniel on 8/25/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (HHAHelperMethods)
/**
 *  Post an NSNotification to the default center on the main thread
 *  Purely a helper do avoid wrapping in @c dispatch_async
 *
 *  @param Notifcation Name to post
 *  @param object to post with notification
 */
+ (void)hha_postNotificationOnMainTheadWithName:(NSString *)aName object:(id)anObject;
@end
