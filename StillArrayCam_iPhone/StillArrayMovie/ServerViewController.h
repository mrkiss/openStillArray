//
//  ServerViewController.h
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 16..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerViewController : UIViewController<UINavigationControllerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *addressTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UIToolbar *inputToolbar;

- (IBAction)addressEditDone:(id)sender;
- (IBAction)portEditDone:(id)sender;

@end
