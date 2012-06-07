//
//  Utility.m
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (AppDelegate*)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (void)alertMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alertView show];
}

+ (NSString*)cacheFolder
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDirectory, YES) objectAtIndex:0];
}

@end
