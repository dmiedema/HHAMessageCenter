//
//  NSObject+HelperMethods.m
//  HHAMessageCenter
//
//  Created by Daniel on 8/25/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import "NSObject+HHAHelperMethods.h"

#pragma mark - C helpers
BOOL HHAIsEmpty(id object) {
    if(!(HHAObjectOrNull(object)) ) {
        return YES;
    }
    if ([object respondsToSelector:@selector(count)]) {
        return [object count] < 1;
    }
    if ([object respondsToSelector:@selector(length)]) {
        return [object length] < 1;
    }
    
    return NO;
}

id HHAObjectOrNull(id object) {
    if ([object isEqual:[NSNull null]] || !object) {
        return nil;
    }
    return object;
}

@implementation NSObject (HHAHelperMethods)
@end
