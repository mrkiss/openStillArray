//
//  FTPSetupViewController.h
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 16..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTPSetupViewController : UIViewController<UINavigationControllerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *addressTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *portTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *useridTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordTextField;


- (IBAction)addressEditDone:(id)sender;
- (IBAction)portEditDone:(id)sender;
- (IBAction)idEditDone:(id)sender;
- (IBAction)passwordEditDone:(id)sender;
@end
