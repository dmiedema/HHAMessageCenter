//
//  NSArray+HelperMethods.h
//  HHAMessageCenter
//
//  Created by Daniel on 8/25/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+HHAHelperMethods.h"

@interface NSArray (HHAHelperMethods)
/**
 *  Return all but the first object of an array
 *
 *  @abstract I like functional programming so this method implements the functional @c tail call for a list
 *
 *  @return nil if array contains less than 2 items. Returns an array with all other items except first if array contains more than 2.
 */
- (NSArray *)hha_tail;
@end
