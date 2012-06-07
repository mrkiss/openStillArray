//
//  ServerViewController.m
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 16..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import "ServerViewController.h"
#import "Common.h"

@interface ServerViewController ()

@end

@implementation ServerViewController
@synthesize addressTextField;
@synthesize portTextField;
@synthesize inputToolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"컨트롤서버설정";
    
    addressTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFKEY_CONTROLADDRESS];
    portTextField.text = [NSString stringWithFormat:@"%d",[[NSUserDefaults standardUserDefaults] integerForKey:USERDEFKEY_CONTROLPORT]];
    portTextField.inputAccessoryView = inputToolbar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.delegate = self;
}

- (void)viewDidUnload
{
    [self setAddressTextField:nil];
    [self setPortTextField:nil];
    [self setInputToolbar:nil];
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
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:USERDEFKEY_CONTROLADDRESS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)portEditDone:(id)sender {
    [portTextField resignFirstResponder];
    UITextField *inputField = portTextField;
    NSString *value = [inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setInteger:[value integerValue] forKey:USERDEFKEY_CONTROLPORT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if( viewController != self ){
        NSString *address = [addressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *port = [portTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[NSUserDefaults standardUserDefaults] setObject:address forKey:USERDEFKEY_CONTROLADDRESS];
        [[NSUserDefaults standardUserDefaults] setInteger:[port integerValue] forKey:USERDEFKEY_CONTROLPORT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        navigationController.delegate = nil;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
}

@end
