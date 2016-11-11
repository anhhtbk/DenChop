//
//  ViewController.m
//  TestOrientation
//
//  Created by VMio69 on 8/11/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <ImageIO/ImageIO.h>
@import GoogleMobileAds;
#import "SettingViewController.h"

#define kAccelerometerFrequency        10.0 //Hz

@interface ViewController ()//<GADInterstitialDelegate>
{
    UIInterfaceOrientation orientationLast, orientationAfterProcess;
    CMMotionManager *motionManager;

    NSTimer *timer;
    
    IBOutlet GADBannerView *_bannerView;
    float speed;
    NSMutableArray *colorsArray;
    NSArray *itemSelecteds;

    TYPE_COLOR typeColor;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadAds];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSetting:) name:@"saveSetting" object:nil];
    
    NSData *dataSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"dataSetting"];
    NSDictionary *dataSetting = [NSKeyedUnarchiver unarchiveObjectWithData:dataSaved];
    
    if (dataSetting) {
        speed = [[dataSetting objectForKey:@"speedValue"] floatValue];
        itemSelecteds = [dataSetting objectForKey:@"itemSelecteds"];
        typeColor = [[dataSetting objectForKey:@"typeColor"] intValue];
        colorsArray = [self colorArrayFromItemSelected:itemSelecteds];
        [[UIScreen mainScreen] setBrightness:[[dataSetting objectForKey:@"brightnessValue"] floatValue]];
    }
    else{
        typeColor = TYPE_COLOR_RANDOM;
        speed = 0.5;
    }
    
}

-(void)changeSetting:(NSNotification *)noti{
    NSDictionary *userInfo = [noti userInfo];
    speed = [[userInfo objectForKey:@"speedValue"] floatValue];
    itemSelecteds = [userInfo objectForKey:@"itemSelecteds"];
    typeColor = [[userInfo objectForKey:@"typeColor"] intValue];
    
    colorsArray = [self colorArrayFromItemSelected:itemSelecteds];
}

-(void)loadAds{
    _bannerView.adUnitID = @"ca-app-pub-8374623097346952/1273566423";
    _bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
//    request.testDevices = @[ @"2ab5d6b443a035002ebddb537f878baf" ];
    [_bannerView loadRequest:request];
}

-(void)viewWillAppear:(BOOL)animated{
    timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(changeColor) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [timer invalidate];
    timer = nil;
}

-(void)changeColor{
    switch (typeColor) {
        case TYPE_COLOR_CUSTOM:
        {
            int i = arc4random()%colorsArray.count;
            [self.view setBackgroundColor:[colorsArray objectAtIndex:i]];
        }
            break;
        case TYPE_COLOR_BINARY:
            if (arc4random()%2 == 0) {
                [self.view setBackgroundColor:[UIColor whiteColor]];
            }
            else{
                [self.view setBackgroundColor:[UIColor blackColor]];
            }
            break;
        case TYPE_COLOR_RANDOM:
        {
            CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
            CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
            CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
            UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
            [self.view setBackgroundColor:color];
        }
            break;
        default:
            break;
    }
}

- (void)dealloc{
    [motionManager stopAccelerometerUpdates];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"settingSegue"]) {
        SettingViewController *viewController = [segue destinationViewController];
        viewController.speed = speed;
        viewController.typeColor = typeColor;
        viewController.itemSelecteds = itemSelecteds;
    }
}

-(NSMutableArray *)colorArrayFromItemSelected:(NSArray *)items{
    NSMutableArray *arr = [NSMutableArray new];
    for (NSIndexPath *indexPath in items) {
        [arr addObject:[UIColor colorWithHue:indexPath.item*0.033 saturation:1. brightness:1. alpha:1.]];
    }
    return arr;
}

//-(BOOL)shouldAutorotate{
//    return NO;
//}
//
//- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
//    // Return a bitmask of supported orientations. If you need more,
//    // use bitwise or (see the commented return).
//    return UIInterfaceOrientationMaskPortrait;
//    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
//}
//
//- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
//    // Return the orientation you'd prefer - this is what it launches to. The
//    // user can still rotate. You don't have to implement this method, in which
//    // case it launches in the current orientation
//    return UIInterfaceOrientationPortrait;
//}


@end
