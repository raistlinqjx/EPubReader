//
//  AppDelegate.h
//  EPubReader
//
//  Created by apple QJX on 12-6-8.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    HomeViewController *viewController;
    UINavigationController *_rootNavigation;
}

@property (strong, nonatomic) UIWindow *window;


@end
