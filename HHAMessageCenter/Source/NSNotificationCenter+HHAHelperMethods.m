//
//  NSNotificationCenter+HelperMethods.m
//  HHAMessageCenter
//
//  Created by Daniel on 8/25/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import "NSNotificationCenter+HHAHelperMethods.h"

@implementation NSNotificationCenter (HHAHelperMethods)
+ (void)hha_postNotificationOnMainTheadWithName:(NSString *)aName object:(id)anObject {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject];
    });
}
@end
