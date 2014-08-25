//
//  NSObject+HelperMethods.h
//  HHAMessageCenter
//
//  Created by Daniel on 8/25/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  Helper to do more empty checks
 *  Takes an object and determines if object is @c nil.
 *  If object responds to selector @c count, checks if count is < 1.
 *  If object responds to selector @c length, checks if length is < 1.
 *
 *  @param  object to check if empty
 *  @return YES if empty object, NO otherwise
 */
BOOL HHAIsEmpty(id object);

/**
 *  Helper to check to see if an object is @c nil or @c [NSNull @c null]
 *
 *  @param  object object to check
 *  @return id the object if not nil or of type `[NSNull null]`. `nil` otherwise.
 */
id HHAObjectOrNull(id object);


@interface NSObject (HHAHelperMethods)
@end
