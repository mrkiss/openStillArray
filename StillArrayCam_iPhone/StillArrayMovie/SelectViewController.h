//
//  SelectViewController.h
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource,UINavigationControllerDelegate>


@property (unsafe_unretained, nonatomic) IBOutlet UIPickerView *seatPicker;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *seatLabel;

- (void)updateSeatNumber:(NSInteger)number;
@end
