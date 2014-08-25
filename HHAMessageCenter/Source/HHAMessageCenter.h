//
//  HHAMessageCenter.h
//  Househappy
//
//  Created by Daniel on 5/20/14.
//  Copyright (c) 2014 House Happy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

#if DEBUG
void resetOnceTokenMessageCenter(void);
#endif

@class HHAMessageCenterMessage;

/**
 *  Enum defining the priority of a message.
 *  Higher priority take more precedence and will be favored
 *  over lower priority messages. In fact, equal or lower 
 *  priority messages will be removed if a new message comes in 
 *  of higher or equal priority.
 *
 *  Default priority of messages is normal
 */
typedef NS_ENUM(NSInteger, HHAMessageCenterMessagePriority) {
    HHAMessageCenterMessagePriorityError  = 0,
    HHAMessageCenterMessagePriorityHigh   = 1,
    HHAMessageCenterMessagePriorityNormal = 2,
    HHAMessageCenterMessagePriorityLow    = 3
};

/**
 *  Basic orientation of message center.
 *  Top means all messages orientate from the top
 *      going down in priority as you go down the screen
 *  Bottom means all messages orientate from the bottom
 *      going down in priority as you go up the screen
 */
typedef NS_ENUM(NSInteger, HHAMessageCenterOrientation) {
    HHAMessageCenterOrientationTop    = 0,
    HHAMessageCenterOrientationBottom = 1
};

/// Options dictionary key for error priority text color
extern NSString * const kHHAMessageCenterPriorityErrorTextColorKey;
/// Options dictionary key for high priority text color
extern NSString * const kHHAMessageCenterPriorityHighTextColorKey;
/// Options dictionary key for normal priority text color
extern NSString * const kHHAMessageCenterPriorityNormalTextColorKey;
/// Options dictionary key for low priority text color
extern NSString * const kHHAMessageCenterPriorityLowTextColorKey;

/// Options dictionary key for error priority background color
extern NSString * const kHHAMessageCenterPriorityErrorBackgroundColorKey;
/// Options dictionary key for high priority background color
extern NSString * const kHHAMessageCenterPriorityHighBackgroundColorKey;
/// Options dictionary key for normal priority background color
extern NSString * const kHHAMessageCenterPriorityNormalBackgroundColorKey;
/// Options dictionary key for low priority background color
extern NSString * const kHHAMessageCenterPriorityLowBackgroundColorKey;

/// NSNotification Name for when a message with priority error is removed by either being pushed out or timing out
extern NSString * const kHHAMessageCenterPriorityErrorRemoved;
/// NSNotification Name for when a message with priority high is removed by either being pushed out or timing out
extern NSString * const kHHAMessageCenterPriorityHighRemoved;
/// NSNotification Name for when a message with priority normal is removed by either being pushed out or timing out
extern NSString * const kHHAMessageCenterPriorityNormalRemoved;
/// NSNotification Name for when a message with priority low is removed by either being pushed out or timing out
extern NSString * const kHHAMessageCenterPriorityLowRemoved;

/**
 *  Message Center for displaying a set number of alerts/information
 *  to the user with the messages varying in priority.
 *
 *  The messages them selves are designed to be one line, sort
 *  informative labels. This is not designed for displaying long,
 *  complex updates to the user.
 */
@interface HHAMessageCenter : NSObject

/// Time the message will be displayed on screen before being automatically dismissed. Default value is 3.0
@property (assign, nonatomic) NSTimeInterval dismissTime;
/// Time for all animations to take. Default value is 0.25
@property (assign, nonatomic) NSTimeInterval animationTime;
/// Maximum width of message center. Default is containerView bounds
@property (assign, nonatomic) CGFloat maxWidth;
/// Maximum height of message center. Default is containerView bounds
@property (assign, nonatomic) CGFloat maxHeight;
/// Height of each message. Default is 21.
@property (assign, nonatomic) CGFloat messageHeight;
/// Width of each message. Default is maxWidth
@property (assign, nonatomic) CGFloat messageWidth;
/// Maximum number of messages to display on screen at once. Default is 2.
@property (assign, nonatomic) NSUInteger maxMessages;
/// Determines if each message should be told [label sizeToFit]
@property (assign, nonatomic) BOOL messageTextShouldSizeToFit;
/// Orientation of message center. Determines if new messges should come in from top or bottom. Default value is HHAMessageCenterOrientationTop
@property (assign, nonatomic) HHAMessageCenterOrientation messageOrientation;
/**
 *  Text options dictionary for configuring various properties of messages.
 *  Options such as text color and background color can be configured
 *  via the specified string const's defined in this file.
 */
@property (strong, nonatomic) NSDictionary *textOptionsDictionary;
/**
 *  This is the view that message center adds itself into. 
 *  Message center does not allow for user interaction so any items
 *  that are sitting 'under' the message center's view will not
 *  be obstructed from user interaction.
 *
 *  By default this value is the currently active windows root
 *  view controller's view.
 */
@property (strong, nonatomic) UIView *containerView;
/** 
 *  Array of HHAMessageCenterMessage objects that are currently being displayed.
 *  This property is read only because it should not be manipulated nor
 *  should any side effects be able to be triggered mearly by accessing
 *  this property. 
 *
 *  To add/remove messages see the various add & remove methods.
 */
@property (readonly, nonatomic) NSArray *currentMessages;

#pragma mark - Shared Instance
/**
 *  Create a message center with a max frame of current windows bounds,
 *  a top based orientation and the default containerView.
 *
 *  @return HHAMessageCenter with all the defaults. Mmm. Defaults.
 */
+ (instancetype)sharedInstance;

#pragma mark - Initialize
#pragma mark Max Frame
/**
 *  Create a message center with a specified maximum frame
 *  All other values will be defaults
 *
 *  @param frame maximum frame message center can use to display messages.
 *  @return HHAMessageCenter with almost all the defaults. Mmm. Defaults.
 */
- (instancetype)initWithMaxFrame:(CGRect)frame;

/**
 *  Create a message center with specified maximum frame and
 *  container view. All other values will be defaults
 *
 *  @param frame maximum frame message center can use to display messages.
 *  @param containerView that will hold message center
 *  @return HHAMessageCenter with specified frame and containerView.
 */
- (instancetype)initWithMaxFrame:(CGRect)frame containerView:(UIView *)containerView;

/**
 *  Create a message center with specified maximum frame and 
 *  orientation for all messages.
 *
 *  @see HHAMessageCenterOrientation
 *
 *  @param frame maximum frame message center can use to display messages.
 *  @param orientation for new/higher priority messages
 *  @return HHAMessageCenter with specified frame and orientation
 */
- (instancetype)initWithMaxFrame:(CGRect)frame messageCenterOrientation:(HHAMessageCenterOrientation)orientation;

/**
 *  Create a message center with specified maximum frame, orientation
 *  container view and options dictionary.
 *  
 *  @see HHAMessageCenterOrientation
 *  @see textOptionsDictionary for explanation of what the options dictionary can be and its format.
 *
 *  @param frame maximum frame message center can use to display messages.
 *  @param orientation for new/higher priority messages
 *  @param containerView that will hold message center
 *  @param options specially formatted NSDictionary for configuring various properties of the different messages based on their priority. Options include text color and background color
 *  @return HHAMessageCenter with specified properties
 */
- (instancetype)initWithMaxFrame:(CGRect)frame messageCenterOrientation:(HHAMessageCenterOrientation)orientation containerView:(UIView *)containerView optionsDictionary:(NSDictionary *)options;

#pragma mark Max Width/Height
/**
 *  Create a message center with specified maximum height, width
 *
 *  @param width maximum width message center can use to display messages.
 *  @param height maximum height message center can use to display messages.
 *  @return HHAMessageCetner with specified properties
 */
- (instancetype)initWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;

/**
 *  Create a message center with specified maximum height, width
 *  and container view
 *
 *  @param width maximum width message center can use to display messages.
 *  @param height maximum height message center can use to display messages.
 *  @param containerView that will hold message center
 *  @return HHAMessageCetner with specified properties
 */
- (instancetype)initWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height containerView:(UIView *)containerView;

/**
 *  Create a message center with specified maximum height, width, orientation
 *
 *  @see HHAMessageCenterOrientation
 *
 *  @param width maximum width message center can use to display messages.
 *  @param height maximum height message center can use to display messages.
 *  @param containerView that will hold message center
 *  @return HHAMessageCenter with specified properties
 */
- (instancetype)initWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height messageCenterOrientation:(HHAMessageCenterOrientation)orientation;

/**
 *  Create a message center with specified maximum height, width, orientation
 *  container view and options dictionary.
 *
 *  @see HHAMessageCenterOrientation
 *  @see textOptionsDictionary for explanation of what the options dictionary can be and its format.
 *
 *  @param width maximum width message center can use to display messages.
 *  @param height maximum height message center can use to display messages.
 *  @param orientation for new/higher priority messages
 *  @param containerView that will hold message center
 *  @param options specially formatted NSDictionary for configuring various properties of the different messages based on their priority. Options include text color and background color
 *  @return HHAMessageCenter with specified properties
 */
- (instancetype)initWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height messageCenterOrientation:(HHAMessageCenterOrientation)orientation containerView:(UIView *)containerView optionsDictionary:(NSDictionary *)options;

#pragma mark - Adding Messages
/**
 *  Add an HHAMessageCenterMessage to the queue of messages to display.
 *  If message's priority is the same or higher than any currently
 *  displayed messages, it will replace one of the current messages.
 *  Otherwise it will be added into a queue to be displayed when it can.
 *
 *  @see HHAMessageCenterMessage
 *
 *  @param message HHAMessageCenterMessage to display
 *  @param animated whether or not it should diplay the message in an animated way
 */
- (void)addMessage:(HHAMessageCenterMessage *)message animated:(BOOL)animated;
#pragma mark Without using HHAMessageCenterMessage object
/**
 *  Add a message to the queue of messages with default priority
 *  and text alignment.
 *  Default priority is Normal
 *  Default text alignment is Center
 *
 *  @param message to dispaly
 *  @param show animated or not
 */
- (void)addMessageString:(NSString *)message animated:(BOOL)animated;

/**
 *  Add a message to the queue of messages with priority
 *  and default text alignment.
 *
 *  Default text alignment is Center
 *
 *  @see HHAMessageCenterMessagePriority
 *
 *  @param message to dispaly
 *  @param priority of the message
 *  @param show animated or not
 */
- (void)addMessageString:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority animated:(BOOL)animated;

/**
 *  Add a message to the queue of messages with set text alignment
 *  and default priority
 *
 *  Default priority is HHAMessageCenterMessagePriorityNormal
 *
 *  @param message to dispaly
 *  @param textAlignment of the message
 *  @param show animated or not
 */
- (void)addMessageString:(NSString *)message textAlignment:(NSTextAlignment)textAlignment animated:(BOOL)animated;

/**
 *  Add a message to the queue of messages with set text alignment
 *  and set priority
 *
 *  @see HHAMessageCenterMessagePriority
 *
 *  @param message to dispaly
 *  @param priority of the message
 *  @param textAlignment of the message
 *  @param show animated or not
 */
- (void)addMessageString:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority textAlignment:(NSTextAlignment)textAlignment animated:(BOOL)animated;

#pragma mark - Remove Message(s)

/**
 *  Currently a NOOP. Needs something
 */
- (void)removeMessage:(HHAMessageCenterMessage *)message animated:(BOOL)animated;

/**
 *  Remove a specific message at a display index.
 *
 *  @discussion messages are ordered with index 0 being the lowest/least
 *              priority message on display. So to remove the lowest/oldest
 *              message an index of 0 may be passed
 *
 *  @param index of message to remove
 *  @param animated fade the message out or not
 */
- (void)removeMessageAtIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 *  Remove all messages displayed
 *
 *  @param Give it the pretties?
 */
- (void)removeAllMessagesAnimated:(BOOL)animated;

/**
 *  Remove all messages with a given priority
 *
 *  @see HHAMessageCenterMessagePriority
 *
 *  @param priority of messages to remove. If none of the given priority are currently displayed, nothing happens.
 *  @param animate removal
 */
- (void)removeAllMessagesWithPriority:(HHAMessageCenterMessagePriority)priority animated:(BOOL)animated;

#pragma mark - Dismiss Message Center

/**
 *  Remove MessageCenter from its current container view.
 *
 *  This also invalidates all of its timers and removes all messages
 *  From the display.
 *
 *  @param animated optionally animate a fade out of the message center
 */
- (void)dismissMessageCenter:(BOOL)animated;
@end
