//
//  HHAMessageCenterViewController.h
//  Househappy
//
//  Created by Daniel on 5/21/14.
//  Copyright (c) 2014 House Happy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHAMessageCenterViewController : UIViewController
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) UIBarButtonItem *rightNavButton;
@property (nonatomic) UIBarButtonItem *leftNavButton;

@property (weak, nonatomic) IBOutlet UIButton *addMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *removeMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAllMessagesButton;
@property (weak, nonatomic) IBOutlet UILabel *maxMessagesLabel;
@property (weak, nonatomic) IBOutlet UIStepper *changeMaxMessagesStepper;

- (IBAction)addMessage:(UIButton *)sender;
- (IBAction)removeTopMessage:(UIButton *)sender;
- (IBAction)removeAllMessages:(UIButton *)sender;
- (IBAction)changeMaxMessages:(UIStepper *)sender;
@end
