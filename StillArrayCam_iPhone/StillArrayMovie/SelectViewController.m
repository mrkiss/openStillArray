//
//  SelectViewController.m
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import "SelectViewController.h"
#import "Utility.h"
#import "Common.h"

@interface SelectViewController ()

@end

@implementation SelectViewController
@synthesize seatPicker;
@synthesize seatLabel;

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
    self.navigationItem.title = @"자리설정";
    
    NSInteger seatNumber = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFKEY_SEATNUMBER];
    [self updateSeatNumber:seatNumber];
    if( seatNumber > 0 )
        [seatPicker selectRow:seatNumber-1 inComponent:0 animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.delegate = self;
}

- (void)viewDidUnload
{
    [self setSeatPicker:nil];
    [self setSeatLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - control method
- (void)updateSeatNumber:(NSInteger)number
{
    if( number < 1 )
        seatLabel.text = @"";
    else
        seatLabel.text = [NSString stringWithFormat:@"%d",number];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d",row+1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self updateSeatNumber:row+1];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if( viewController != self ){
        
        [[NSUserDefaults standardUserDefaults] setInteger:[seatPicker selectedRowInComponent:0]+1 forKey:USERDEFKEY_SEATNUMBER];
        [[NSUserDefaults standardUserDefaults] synchronize];
        navigationController.delegate = nil;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}


@end
