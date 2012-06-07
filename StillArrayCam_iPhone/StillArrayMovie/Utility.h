//
//  Utility.h
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface Utility : NSObject

+ (AppDelegate*)appDelegate;
+ (void)alertMessage:(NSString*)message;
+ (NSString*)cacheFolder;
@end
