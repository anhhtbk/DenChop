//
//  SettingViewController.h
//  Đèn chớp
//
//  Created by VMio69 on 8/17/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, TYPE_COLOR){
    TYPE_COLOR_BINARY,
    TYPE_COLOR_RANDOM,
    TYPE_COLOR_CUSTOM
};

@interface SettingViewController : UIViewController

@property float speed;
@property NSArray *itemSelecteds;
@property TYPE_COLOR typeColor;

@end
