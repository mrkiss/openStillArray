//
//  FTPSetupViewController.m
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 16..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import "FTPSetupViewController.h"
#import "Common.h"

@interface FTPSetupViewController ()

@end

@implementation FTPSetupViewController
@synthesize mainScrollView;
@synthesize contentView;
@synthesize addressTextField;
@synthesize portTextField;
@synthesize useridTextField;
@synthesize passwordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)keyboardWillShow:(NSNotification *)note {  
    // create custom button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(portEditDone:) forControlEvents:UIControlEventTouchUpInside];
    
    // locate keyboard view
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        // keyboard view found; add the custom button to it
        if([[keyboard description] hasPrefix:@"UIKeyboard"] == YES)
            [keyboard addSubview:doneButton];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"FTP설정";
    
    addressTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFKEY_FTPADDRESS];
    useridTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFKEY_FTPUSER];
    passwordTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFKEY_FTPPASSWORD];
    [mainScrollView addSubview:contentView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.delegate = self;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setMainScrollView:nil];
    [self setContentView:nil];
    [self setAddressTextField:nil];
    [self setPortTextField:nil];
    [self setUseridTextField:nil];
    [self setPasswordTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - action method
- (IBAction)addressEditDone:(id)sender {
    UITextField *inputField = (UITextField*)sender;
    NSString *value = [inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:USERDEFKEY_FTPADDRESS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)portEditDone:(id)sender {
    UITextField *inputField = portTextField;
    NSString *value = [inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setInteger:[value integerValue] forKey:USERDEFKEY_FTPPORT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)idEditDone:(id)sender {
    UITextField *inputField = (UITextField*)sender;
    NSString *value = [inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:USERDEFKEY_FTPUSER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)passwordEditDone:(id)sender {
    UITextField *inputField = (UITextField*)sender;
    NSString *value = [inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:USERDEFKEY_FTPPASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if( viewController != self ){
        NSString *address = [addressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *port = [portTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *user = [useridTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = [passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [[NSUserDefaults standardUserDefaults] setObject:address forKey:USERDEFKEY_FTPADDRESS];
        [[NSUserDefaults standardUserDefaults] setInteger:[port integerValue] forKey:USERDEFKEY_FTPPORT];
        [[NSUserDefaults standardUserDefaults] setObject:user forKey:USERDEFKEY_FTPUSER];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:USERDEFKEY_FTPPASSWORD];
        [[NSUserDefaults standardUserDefaults] synchronize];
        navigationController.delegate = nil;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
}

@end
