//
//  NSArray+HelperMethods.m
//  HHAMessageCenter
//
//  Created by Daniel on 8/25/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import "NSArray+HHAHelperMethods.h"

@implementation NSArray (HHAHelperMethods)
- (NSArray *)hha_tail {
    if (HHAIsEmpty(self)) { return nil; }
    return [self objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.count - 1)]];
}
@end
