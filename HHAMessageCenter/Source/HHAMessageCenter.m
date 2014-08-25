//
//  HHAMessageCenter.m
//  Househappy
//
//  Created by Daniel on 5/20/14.
//  Copyright (c) 2014 House Happy. All rights reserved.
//

#import "HHAMessageCenter.h"
#import "HHAMessageCenterMessage.h"
#import "NSArray+HHAHelperMethods.h"
#import "NSNotificationCenter+HHAHelperMethods.h"

NSString * const kHHAMessageCenterPriorityHighTextColorKey         = @"kHHAMessageCenterPriorityHighTextColorKey";
NSString * const kHHAMessageCenterPriorityErrorTextColorKey        = @"kHHAMessageCenterPriorityErrorTextColorKey";
NSString * const kHHAMessageCenterPriorityNormalTextColorKey       = @"kHHAMessageCenterPriorityNormalTextColorKey";
NSString * const kHHAMessageCenterPriorityLowTextColorKey          = @"kHHAMessageCenterPriorityLowTextColorKey";
NSString * const kHHAMessageCenterPriorityHighBackgroundColorKey   = @"kHHAMessageCenterPriorityHighBackgroundColorKey";
NSString * const kHHAMessageCenterPriorityErrorBackgroundColorKey  = @"kHHAMessageCenterPriorityErrorBackgroundColorKey";
NSString * const kHHAMessageCenterPriorityNormalBackgroundColorKey = @"kHHAMessageCenterPriorityNormalBackgroundColorKey";
NSString * const kHHAMessageCenterPriorityLowBackgroundColorKey    = @"kHHAMessageCenterPriorityLowBackgroundColorKey";

NSString * const kHHAMessageCenterPriorityErrorRemoved    = @"kHHAMessageCenterPriorityErrorRemoved";
NSString * const kHHAMessageCenterPriorityHighRemoved    = @"kHHAMessageCenterPriorityHighRemoved";
NSString * const kHHAMessageCenterPriorityNormalRemoved    = @"kHHAMessageCenterPriorityNormalRemoved";
NSString * const kHHAMessageCenterPriorityLowRemoved    = @"kHHAMessageCenterPriorityLowRemoved";

@interface HHAMessageCenter()
@property (strong, nonatomic) UIView *messageCenter;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *errorPriority;
@property (strong, nonatomic) NSMutableArray *errorPriorityPending;
@property (strong, nonatomic) NSMutableArray *highPriority;
@property (strong, nonatomic) NSMutableArray *highPriorityPending;
@property (strong, nonatomic) NSMutableArray *normalPriority;
@property (strong, nonatomic) NSMutableArray *normalPriorityPending;
@property (strong, nonatomic) NSMutableArray *lowPriority;
@property (strong, nonatomic) NSMutableArray *lowPriorityPending;

@property (strong, nonatomic) NSMutableArray *timers;

@property (assign, nonatomic) CGRect displayFrame;

- (void)updateAllMessagesAnimated:(BOOL)animated;
- (void)timerExpiredForMessage:(NSTimer *)timer;

- (UIColor *)textColorForPriority:(HHAMessageCenterMessagePriority)priority;
- (UIColor *)backgroundColorForPriority:(HHAMessageCenterMessagePriority)priority;

- (BOOL)removeOneMessageWithPriority:(HHAMessageCenterMessagePriority)priority;
- (void)storeMessage:(HHAMessageCenterMessage *)message;

- (NSMutableArray *)getPriorityArray:(HHAMessageCenterMessagePriority)priority;
- (NSMutableArray *)getPriorityArrayForLabelsOfPriority:(HHAMessageCenterMessagePriority)priority;

- (void)displayNextMessageAnimated:(BOOL)animated;

+ (UIView *)mainWindowView;
@end

#if DEBUG
static dispatch_once_t *once_token_ref;
void resetOnceTokenMessageCenter(void) {
    *once_token_ref = 0;
}
#endif
@implementation HHAMessageCenter

#pragma mark - Class Methods
+ (instancetype)sharedInstance {
    static HHAMessageCenter *sharedClient = nil;
    static dispatch_once_t onceToken;
#if DEBUG
    once_token_ref = &onceToken;
#endif
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] initWithMaxFrame:[HHAMessageCenter mainWindowView].bounds messageCenterOrientation:HHAMessageCenterOrientationTop containerView:[HHAMessageCenter mainWindowView] optionsDictionary:nil];
    });
    return sharedClient;
}
#pragma mark - Initializers
#pragma mark Frame
- (instancetype)initWithMaxFrame:(CGRect)frame {
    return [self initWithMaxFrame:frame containerView:[HHAMessageCenter mainWindowView]];
}
- (instancetype)initWithMaxFrame:(CGRect)frame containerView:(UIView *)containerView {
    return [self initWithMaxFrame:frame messageCenterOrientation:HHAMessageCenterOrientationTop containerView:containerView optionsDictionary:nil];
}

- (instancetype)initWithMaxFrame:(CGRect)frame messageCenterOrientation:(HHAMessageCenterOrientation)orientation {
    return [self initWithMaxFrame:frame messageCenterOrientation:orientation containerView:[HHAMessageCenter mainWindowView] optionsDictionary:nil];
}
- (instancetype)initWithMaxFrame:(CGRect)frame messageCenterOrientation:(HHAMessageCenterOrientation)orientation containerView:(UIView *)containerView optionsDictionary:(NSDictionary *)options {
    self = [super init];
    if (self) {
        if (!containerView) {
            _containerView = [HHAMessageCenter mainWindowView];
        } else {
            _containerView = containerView;
        }
        
        _messageOrientation    = orientation;
        _displayFrame          = frame;
        _maxWidth              = frame.size.width;
        _maxHeight             = frame.size.height;
        _maxMessages           = 2;
        _animationTime         = 0.35;
        _dismissTime           = 3.0;
        _textOptionsDictionary = options;
        
        _messages       = [NSMutableArray array];
        _errorPriority  = [NSMutableArray array];
        _highPriority   = [NSMutableArray array];
        _normalPriority = [NSMutableArray array];
        _lowPriority    = [NSMutableArray array];
        
        _errorPriorityPending  = [NSMutableArray array];
        _highPriorityPending   = [NSMutableArray array];
        _normalPriorityPending = [NSMutableArray array];
        _lowPriorityPending    = [NSMutableArray array];
        
        _timers = [NSMutableArray array];
        
        _messageCenter = [[UIView alloc] initWithFrame:_displayFrame];
        _messageCenter.backgroundColor = [UIColor clearColor];
        _messageCenter.userInteractionEnabled = NO;
        [_containerView addSubview:_messageCenter];
    }
    return self;
}

#pragma mark - Width/Height
- (instancetype)initWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    return [self initWithMaxWidth:width maxHeight:height containerView:[HHAMessageCenter mainWindowView]];
}
- (instancetype)initWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height containerView:(UIView *)containerView {
    return [self initWithMaxWidth:width maxHeight:height messageCenterOrientation:HHAMessageCenterOrientationTop containerView:containerView optionsDictionary:nil];
}
- (instancetype)initWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height messageCenterOrientation:(HHAMessageCenterOrientation)orientation {
    return [self initWithMaxWidth:width maxHeight:height messageCenterOrientation:orientation containerView:[HHAMessageCenter mainWindowView] optionsDictionary:nil];
}
- (instancetype)initWithMaxWidth:(CGFloat)width maxHeight:(CGFloat)height messageCenterOrientation:(HHAMessageCenterOrientation)orientation containerView:(UIView *)containerView optionsDictionary:(NSDictionary *)options {
    self = [super init];
    if (self) {
        if (!containerView) {
            _containerView = [HHAMessageCenter mainWindowView];
        } else {
            _containerView = containerView;
        }
        
        _messageOrientation    = orientation;
        _displayFrame          = CGRectMake(0, 0, width, height);
        _maxWidth              = width;
        _maxHeight             = height;
        _maxMessages           = 2;
        _animationTime         = 0.35;
        _dismissTime           = 3.0;
        _textOptionsDictionary = options;
        
        _messages       = [NSMutableArray array];
        _errorPriority  = [NSMutableArray array];
        _highPriority   = [NSMutableArray array];
        _normalPriority = [NSMutableArray array];
        _lowPriority    = [NSMutableArray array];
        
        _errorPriorityPending  = [NSMutableArray array];
        _highPriorityPending   = [NSMutableArray array];
        _normalPriorityPending = [NSMutableArray array];
        _lowPriorityPending    = [NSMutableArray array];
        
        _timers = [NSMutableArray array];
        
        _messageCenter = [[UIView alloc] initWithFrame:_displayFrame];
        _messageCenter.backgroundColor = [UIColor clearColor];
        _messageCenter.userInteractionEnabled = NO;
        [_containerView addSubview:_messageCenter];
    }
    return self;
}

#pragma mark - Add Message
#pragma mark convience
- (void)addMessageString:(NSString *)message animated:(BOOL)animated {
    [self addMessage:[HHAMessageCenterMessage messageWithText:message] animated:animated];
}
-(void)addMessageString:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority animated:(BOOL)animated {
    [self addMessage:[HHAMessageCenterMessage messageWithText:message priority:priority] animated:animated];
}
- (void)addMessageString:(NSString *)message textAlignment:(NSTextAlignment)textAlignment animated:(BOOL)animated {
    [self addMessage:[HHAMessageCenterMessage messageWithText:message priority:HHAMessageCenterMessagePriorityNormal textAlignment:textAlignment] animated:animated];
}
- (void)addMessageString:(NSString *)message priority:(HHAMessageCenterMessagePriority)priority textAlignment:(NSTextAlignment)textAlignment animated:(BOOL)animated {
    [self addMessage:[HHAMessageCenterMessage messageWithText:message priority:priority textAlignment:textAlignment] animated:animated];
}
#pragma mark Actual Message Add
-(void)addMessage:(HHAMessageCenterMessage *)message animated:(BOOL)animated {
    [self storeMessage:message];
    [self displayNextMessageAnimated:animated];
}

#pragma mark - Displaying Next Message
- (void)displayNextMessageAnimated:(BOOL)animated {
    HHAMessageCenterMessage *nextMessage;
    if (!HHAIsEmpty(_errorPriorityPending)) {
        nextMessage = [_errorPriorityPending firstObject];
        _errorPriorityPending = [NSMutableArray arrayWithArray:[_errorPriorityPending hha_tail]];
    } else if (!HHAIsEmpty(_highPriorityPending)) {
        nextMessage = [_highPriorityPending firstObject];
        _highPriorityPending = [NSMutableArray arrayWithArray:[_highPriorityPending hha_tail]];
    } else if (!HHAIsEmpty(_normalPriorityPending)) {
        nextMessage = [_normalPriorityPending firstObject];
        _normalPriorityPending = [NSMutableArray arrayWithArray:[_normalPriorityPending hha_tail]];
    } else if (!HHAIsEmpty(_lowPriorityPending)) {
        nextMessage = [_lowPriorityPending firstObject];
        _lowPriorityPending = [NSMutableArray arrayWithArray:[_lowPriorityPending hha_tail]];
    }
    
    if (!nextMessage) { return; }
    
    BOOL madeRoom = YES;
    // If we're full up, try to make room for this message
    if (_messages.count >= _maxMessages) {
        madeRoom = [self removeOneMessageForPriority:nextMessage.priority];
    }
    
    // couldn't make space so put message back in queue
    if (!madeRoom) {
        [[self getPriorityArray:nextMessage.priority] insertObject:nextMessage atIndex:0];
        return;
    }
    
    CGFloat yOffset = [self getYOffsetForMessage:nextMessage];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, yOffset, [self messageWidth], [self messageHeight])];
    label.textColor = [self textColorForPriority:nextMessage.priority];
    label.backgroundColor = [self backgroundColorForPriority:nextMessage.priority];
    label.textAlignment = nextMessage.textAlignment;
    
    label.text = nextMessage.message;
    if (_messageTextShouldSizeToFit) { [label sizeToFit]; }

    [self shiftMessagesDownForPriority:nextMessage.priority animated:animated];
    [[self getPriorityArrayForLabelsOfPriority:nextMessage.priority] addObject:label];
    [_messages addObject:label];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((animated) ? _animationTime : 0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        label.alpha = 0.0;
        [self->_messageCenter addSubview:label];
        NSTimeInterval duration = (animated) ? self->_animationTime : 0.0;
        [UIView animateWithDuration:duration animations:^{
            label.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self->_timers addObject:[NSTimer scheduledTimerWithTimeInterval:[self dismissTime] target:self selector:@selector(timerExpiredForMessage:) userInfo:@{@"label":label, @"priority": @(nextMessage.priority)} repeats:NO]];
        }];
    });

}
//TODO: Handle bottom orientation
- (void)shiftMessagesDownForPriority:(HHAMessageCenterMessagePriority)priority animated:(BOOL)animated {
    if (priority <= HHAMessageCenterMessagePriorityLow) {
        for (UILabel *label in [self->_lowPriority reverseObjectEnumerator]) {
            CGRect newFrame = CGRectMake(label.frame.origin.x, label.frame.origin.y + ([self messageHeight]), label.frame.size.width, label.frame.size.height);
            NSTimeInterval duration = (animated) ? _animationTime : 0.0;
            [UIView animateWithDuration:duration animations:^{
                label.frame = newFrame;
            } completion:^(BOOL finished) {}];
        }
    } // end if priority == HHAMessageCenterMessagePriorityLow
    if (priority <= HHAMessageCenterMessagePriorityNormal) {
        for (UILabel *label in [self->_normalPriority reverseObjectEnumerator]) {
            CGRect newFrame = CGRectMake(label.frame.origin.x, label.frame.origin.y + ([self messageHeight]), label.frame.size.width, label.frame.size.height);
            NSTimeInterval duration = (animated) ? _animationTime : 0.0;
            [UIView animateWithDuration:duration animations:^{
                label.frame = newFrame;
            } completion:^(BOOL finished) {}];
        }
    } // end if priority == HHAMessageCenterMessagePriorityNormal
    if (priority <= HHAMessageCenterMessagePriorityHigh) {
        for (UILabel *label in [self->_highPriority reverseObjectEnumerator]) {
            CGRect newFrame = CGRectMake(label.frame.origin.x, label.frame.origin.y + ([self messageHeight]), label.frame.size.width, label.frame.size.height);
            NSTimeInterval duration = (animated) ? _animationTime : 0.0;
            [UIView animateWithDuration:duration animations:^{
                label.frame = newFrame;
            } completion:^(BOOL finished) {}];
        }
    } // end if priority == HHAMessageCenterMessagePriorityHigh
    if (priority <= HHAMessageCenterMessagePriorityError) {
        for (UILabel *label in [self->_errorPriority reverseObjectEnumerator]) {
            CGRect newFrame = CGRectMake(label.frame.origin.x, label.frame.origin.y + ([self messageHeight]), label.frame.size.width, label.frame.size.height);
            NSTimeInterval duration = (animated) ? _animationTime : 0.0;
            [UIView animateWithDuration:duration animations:^{
                label.frame = newFrame;
            } completion:^(BOOL finished) {}];
        }
    } // end if priority == HHAMessageCenterMessagePriorityHigh
}

#pragma mark - Remove Message
- (void)removeMessageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    [self removeMessageAtIndex:index priority:-1 animated:animated];
}
- (void)removeMessageAtIndex:(NSUInteger)index priority:(HHAMessageCenterMessagePriority)priority animated:(BOOL)animated {
    if (index >= _messages.count) { return; }
    __block UILabel *label = [_messages objectAtIndex:index];
    [_messages removeObjectAtIndex:index];
    if (priority >= 0) {
        [[self getPriorityArrayForLabelsOfPriority:priority] removeObject:label];
    }
    NSTimeInterval duration = (animated) ? _animationTime : 0.0;
    [UIView animateWithDuration:duration animations:^{
        label.alpha = 0.0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
        label = nil;
        [self updateAllMessagesAnimated:YES];
        [self displayNextMessageAnimated:animated];
    }];
}

- (void)removeMessage:(HHAMessageCenterMessage *)message animated:(BOOL)animated {
    NSMutableArray *array = [self getPriorityArrayForLabelsOfPriority:message.priority];
    
    UILabel *label;
    for (UILabel *l in array) {
        if ([l.text isEqualToString:message.message]) {
            label = l;
            break;
        }
    }
    
    if (!label) { return; }
    [array removeObject:label];
    [_messages removeObject:label];
}

- (void)removeAllMessagesAnimated:(BOOL)animated {
    for (NSInteger i = 0; i < _messages.count; i++) {
        UILabel *displayMesage = [_messages objectAtIndex:i];
        
        [_errorPriority removeObject:displayMesage];
        [_highPriority removeObject:displayMesage];
        [_normalPriority removeObject:displayMesage];
        [_lowPriority removeObject:displayMesage];
        
        [self removeMessageAtIndex:i animated:animated];
    }
}
- (void)removeAllMessagesWithPriority:(HHAMessageCenterMessagePriority)priority animated:(BOOL)animated {
    NSMutableArray *array = [self getPriorityArrayForLabelsOfPriority:priority];
    for (UILabel *label in array) {
        [array removeObject:label];
        [_messages removeObject:label];
        [self postNotificationOfRemovedMessageOfPriority:priority];
    }
}
- (BOOL)removeOneMessageForPriority:(HHAMessageCenterMessagePriority)priority {
    BOOL messageRemoved = NO;
    
    if (priority <= HHAMessageCenterMessagePriorityLow) {
        messageRemoved = [self removeOneMessageWithPriority:HHAMessageCenterMessagePriorityLow];
        if (messageRemoved) { return messageRemoved; }
    }
    else if (priority <= HHAMessageCenterMessagePriorityNormal) {
        messageRemoved = [self removeOneMessageWithPriority:HHAMessageCenterMessagePriorityNormal];
        if (messageRemoved) { return messageRemoved; }
    }
    else if (priority <= HHAMessageCenterMessagePriorityHigh) {
        messageRemoved = [self removeOneMessageWithPriority:HHAMessageCenterMessagePriorityHigh];
        if (messageRemoved) {return messageRemoved; }
    }
    else if (priority <= HHAMessageCenterMessagePriorityError) {
        messageRemoved = [self removeOneMessageWithPriority:HHAMessageCenterMessagePriorityError];
        if (messageRemoved) { return messageRemoved;}
    }
    
    return messageRemoved;
}

- (BOOL)removeOneMessageWithPriority:(HHAMessageCenterMessagePriority)priority {
    NSMutableArray *array = [self getPriorityArrayForLabelsOfPriority:priority];
    UILabel *label = [array firstObject];
    
    if (!label) { return NO; }
    
    [array removeObject:label];
    [_messages removeObject:label];
    [label removeFromSuperview];
    
    [self postNotificationOfRemovedMessageOfPriority:priority];
    
    return YES;
}

#pragma mark - Dismiss Message Center 
- (void)dismissMessageCenter:(BOOL)animated {
    NSTimeInterval duration = (animated) ? _animationTime : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self->_messageCenter.alpha = 0.0;
    } completion:^(BOOL finished) {
        for (NSTimer *timer in self->_timers) { [timer invalidate]; }
        [self->_timers removeAllObjects];
        [self->_messageCenter removeFromSuperview];
    }];
}

#pragma mark - Notifications
- (void)postNotificationOfRemovedMessageOfPriority:(HHAMessageCenterMessagePriority)priority {
    switch (priority) {
        case HHAMessageCenterMessagePriorityError:
            [NSNotificationCenter hha_postNotificationOnMainTheadWithName:kHHAMessageCenterPriorityErrorRemoved object:nil];
            break;
        case HHAMessageCenterMessagePriorityHigh:
            [NSNotificationCenter hha_postNotificationOnMainTheadWithName:kHHAMessageCenterPriorityHighRemoved object:nil];
            break;
        case HHAMessageCenterMessagePriorityNormal:
            [NSNotificationCenter hha_postNotificationOnMainTheadWithName:kHHAMessageCenterPriorityNormalRemoved object:nil];
            break;
        case HHAMessageCenterMessagePriorityLow:
            [NSNotificationCenter hha_postNotificationOnMainTheadWithName:kHHAMessageCenterPriorityLowRemoved object:nil];
            break;
    }
}

#pragma mark - Properties
- (NSArray *)currentMessages {
    NSMutableArray *allMessages = [NSMutableArray arrayWithCapacity:_messages.count];
    
    for (UILabel *label in _errorPriority) {
        HHAMessageCenterMessage *message = [HHAMessageCenterMessage messageWithText:label.text priority:HHAMessageCenterMessagePriorityError textAlignment:label.textAlignment];
        [allMessages addObject:message];
    }
    for (UILabel *label in _highPriority) {
        HHAMessageCenterMessage *message = [HHAMessageCenterMessage messageWithText:label.text priority:HHAMessageCenterMessagePriorityError textAlignment:label.textAlignment];
        [allMessages addObject:message];
    }
    for (UILabel *label in _normalPriority) {
        HHAMessageCenterMessage *message = [HHAMessageCenterMessage messageWithText:label.text priority:HHAMessageCenterMessagePriorityError textAlignment:label.textAlignment];
        [allMessages addObject:message];
    }
    for (UILabel *label in _lowPriority) {
        HHAMessageCenterMessage *message = [HHAMessageCenterMessage messageWithText:label.text priority:HHAMessageCenterMessagePriorityError textAlignment:label.textAlignment];
        [allMessages addObject:message];
    }
    
    return allMessages;
}
#pragma mark Getters
#pragma mark text color
- (UIColor *)highPriorityTextColor {
    return [_textOptionsDictionary valueForKey:kHHAMessageCenterPriorityHighTextColorKey] ?: [UIColor darkGrayColor];
}
- (UIColor *)errorPriorityTextColor {
    return [_textOptionsDictionary valueForKey:kHHAMessageCenterPriorityErrorTextColorKey] ?: [UIColor redColor];
}
- (UIColor *)normalPriorityTextColor {
    return [_textOptionsDictionary valueForKey:kHHAMessageCenterPriorityNormalTextColorKey] ?: [UIColor grayColor];
}
- (UIColor *)lowPriorityTextColor {
    return [_textOptionsDictionary valueForKey:kHHAMessageCenterPriorityLowTextColorKey] ?: [UIColor lightGrayColor];
}
#pragma mark background color
- (UIColor *)highPriorityBackgroundColor {
    return [_textOptionsDictionary valueForKey:kHHAMessageCenterPriorityHighBackgroundColorKey] ?: [UIColor clearColor];
}
- (UIColor *)errorPriorityBackgroundColor {
    return [_textOptionsDictionary valueForKey:kHHAMessageCenterPriorityErrorBackgroundColorKey] ?: [UIColor clearColor];
}
- (UIColor *)normalPriorityBackgroundColor {
    return [_textOptionsDictionary valueForKey:kHHAMessageCenterPriorityNormalBackgroundColorKey] ?: [UIColor clearColor];
}
- (UIColor *)lowPriorityBackgroundColor {
    return [_textOptionsDictionary valueForKey:kHHAMessageCenterPriorityLowBackgroundColorKey] ?: [UIColor clearColor];
}

- (CGFloat)messageHeight {
    return (_messageHeight <= 0) ? 21 : _messageHeight;
}
- (CGFloat)messageWidth {
    return (_messageWidth <= 0) ? _maxWidth : _messageWidth;
}
- (NSTimeInterval)dismissTime {
    return (_dismissTime <= 0.0) ? 3.0 : _dismissTime;
}
- (NSTimeInterval)animationTime {
    return (_animationTime <= 0.0) ? 0.25 : _animationTime;
}
#pragma mark Setters
- (void)setTextOptionsDictionary:(NSDictionary *)textOptionsDictionary {
    _textOptionsDictionary = textOptionsDictionary;
    [self updateAllMessagesAnimated:YES];
}

#pragma mark - Private
- (void)updateAllMessagesAnimated:(BOOL)animated {
    NSInteger index = 0;
    for (UILabel *message in [_messages reverseObjectEnumerator]) {
        CGRect frame = message.frame;
        CGFloat yOffset = index * [self messageHeight];
        CGRect newFrame = CGRectMake(frame.origin.x, yOffset, frame.size.width, frame.size.height);
        NSTimeInterval duration = (animated) ? _animationTime : 0.0;
        index++;
        [UIView animateWithDuration:duration animations:^{
            message.frame = newFrame;
        } completion:^(BOOL finished) {
            [message setNeedsDisplay];
        }];
    }
}

-(void)timerExpiredForMessage:(NSTimer *)timer {
    NSUInteger index = [_messages indexOfObject:timer.userInfo[@"label"]];
    [self removeMessageAtIndex:index priority:[timer.userInfo[@"priority"] integerValue] animated:YES];
    [timer invalidate];
    [_timers removeObject:timer];
    timer = nil;
}

- (void)storeMessage:(HHAMessageCenterMessage *)message {
    NSMutableArray *array = [self getPriorityArray:message.priority];
    [array addObject:message];
}

#pragma mark Getter / Helpers
- (CGFloat)getYOffsetForMessage:(HHAMessageCenterMessage *)message {
    CGFloat offset = 0;
    CGFloat increment = [self messageHeight];
    
    if (message.priority == HHAMessageCenterMessagePriorityError) {
        return 0;
    }
    if (message.priority > HHAMessageCenterMessagePriorityError && !HHAIsEmpty(_errorPriority)) {
        offset += _errorPriority.count * increment;
    }
    if (message.priority > HHAMessageCenterMessagePriorityHigh && !HHAIsEmpty(_highPriority)) {
        offset += _highPriority.count * increment;
    }
    if (message.priority > HHAMessageCenterMessagePriorityNormal && !HHAIsEmpty(_normalPriority)) {
        offset += _normalPriority.count * increment;
    }
    
    return offset;
}

- (NSMutableArray *)getPriorityArray:(HHAMessageCenterMessagePriority)priority {
    NSMutableArray *array;
    switch (priority) {
        case HHAMessageCenterMessagePriorityError:
            array = _errorPriorityPending;
            break;
        case HHAMessageCenterMessagePriorityHigh:
            array = _highPriorityPending;
            break;
        case HHAMessageCenterMessagePriorityNormal:
            array = _normalPriorityPending;
            break;
        case HHAMessageCenterMessagePriorityLow:
            array = _lowPriorityPending;
            break;
    }
    return array;
}

- (NSMutableArray *)getPriorityArrayForLabelsOfPriority:(HHAMessageCenterMessagePriority)priority {
    NSMutableArray *array;
    switch (priority) {
        case HHAMessageCenterMessagePriorityError:
            array = _errorPriority;
            break;
        case HHAMessageCenterMessagePriorityHigh:
            array = _highPriority;
            break;
        case HHAMessageCenterMessagePriorityNormal:
            array = _normalPriority;
            break;
        case HHAMessageCenterMessagePriorityLow:
            array = _lowPriority;
            break;
    }
    return array;
}

- (UIColor *)textColorForPriority:(HHAMessageCenterMessagePriority)priority {
    switch (priority) {
        case HHAMessageCenterMessagePriorityError:
            return [self errorPriorityTextColor];
        case HHAMessageCenterMessagePriorityHigh:
            return [self highPriorityTextColor];
        case HHAMessageCenterMessagePriorityNormal:
            return [self normalPriorityTextColor];
        case HHAMessageCenterMessagePriorityLow:
            return [self lowPriorityTextColor];
        default:
            return [UIColor darkTextColor];
    }
}

- (UIColor *)backgroundColorForPriority:(HHAMessageCenterMessagePriority)priority {
    switch (priority) {
        case HHAMessageCenterMessagePriorityError:
            return [self errorPriorityBackgroundColor];
        case HHAMessageCenterMessagePriorityHigh:
            return [self highPriorityBackgroundColor];
        case HHAMessageCenterMessagePriorityNormal:
            return [self normalPriorityBackgroundColor];
        case HHAMessageCenterMessagePriorityLow:
            return [self lowPriorityBackgroundColor];
        default:
            return [UIColor clearColor];
    }
}

#pragma mark Class
+ (UIView *)mainWindowView {
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    UIView *rootView = [mainWindow rootViewController].view;
    
    return rootView;
}
@end
