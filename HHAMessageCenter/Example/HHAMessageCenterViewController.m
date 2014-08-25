//
//  HHAMessageCenterViewController.m
//  Househappy
//
//  Created by Daniel on 5/21/14.
//  Copyright (c) 2014 House Happy. All rights reserved.
//

#import "HHAMessageCenterViewController.h"
#import "HHAMessageCenter.h"
@interface HHAMessageCenterViewController ()
@property (nonatomic, strong) HHAMessageCenter *messageCenter;
@end

@implementation HHAMessageCenterViewController
#pragma mark - View Life Cylce
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height);
    _messageCenter = [[HHAMessageCenter alloc] initWithMaxFrame:frame messageCenterOrientation:HHAMessageCenterOrientationTop containerView:self.view optionsDictionary:nil];
    [self updateCountLabel];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCountLabel) name:kHHAMessageCenterMessageRemoved object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}
#pragma mark - IBActions
- (IBAction)addMessage:(UIButton *)sender {
    NSInteger priority = arc4random_uniform(4);
    NSString *message;
    switch (priority) {
        case 0:
            message = @"EURR";
            break;
        case 1:
            message = @"HIigh";
            break;
        case 2:
            message = @"norm ee ale";
            break;
        default:
            message = @"low low low ow";
            break;
    }
    
    [_messageCenter addMessageString:message priority:priority animated:YES];
    [self updateCountLabel];
}

- (IBAction)removeTopMessage:(UIButton *)sender {
//    [_messageCenter removeMessageAtIndex:0 animated:YES];
    [_messageCenter removeAllMessagesWithPriority:HHAMessageCenterMessagePriorityNormal animated:YES];
}

- (IBAction)removeAllMessages:(UIButton *)sender {
    [_messageCenter removeAllMessagesAnimated:YES];
}

- (IBAction)changeMaxMessages:(UIStepper *)sender {
    [_messageCenter setMaxMessages:sender.value];
    _maxMessagesLabel.text = [NSString stringWithFormat:@"%f", sender.value];
}

- (void)updateCountLabel {
    _currentNumberOfMessagesLabel.text = [NSString stringWithFormat:@"%li", (long)[_messageCenter.allMessagesInQueue count]];
}
@end
