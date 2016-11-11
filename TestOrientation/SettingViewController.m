//
//  SettingViewController.m
//  Đèn chớp
//
//  Created by VMio69 on 8/17/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "SettingViewController.h"
#import "ColorCell.h"

#define WIDTH_SCREEN  [UIScreen mainScreen].bounds.size.width

@import GoogleMobileAds;

@interface SettingViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    IBOutlet UISlider *brightnessSlider;
    IBOutlet UISlider *speedSlider;
    IBOutlet GADBannerView *_bannerView;
    IBOutlet UISwitch *randomColorSwitch;
    IBOutlet UISegmentedControl *blackWhiteSegmented;
    
    float _brightness;
    
    IBOutlet UICollectionView *colorCollectionView;
    NSMutableArray *itemSelectedArray;
    
    IBOutlet NSLayoutConstraint *leftConstraint;
    IBOutlet NSLayoutConstraint *rightConstraint;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAds];
    
    leftConstraint.constant = 12+(int)WIDTH_SCREEN%6/2;
    rightConstraint.constant = 12+(int)WIDTH_SCREEN%6/2;
    
    [brightnessSlider addTarget:self action:@selector(brightnessChangeValue) forControlEvents:UIControlEventValueChanged];
    [speedSlider addTarget:self action:@selector(speedChangeValue) forControlEvents:UIControlEventValueChanged];
    [brightnessSlider setValue:[UIScreen mainScreen].brightness];
    [speedSlider setValue:(1.-_speed)];
    _brightness = [UIScreen mainScreen].brightness;
    [colorCollectionView registerNib:[UINib nibWithNibName:@"ColorCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"colorCellId"];
    colorCollectionView.allowsMultipleSelection = YES;
    if (!_itemSelecteds) {
        itemSelectedArray = [NSMutableArray new];
    }
    else{
        itemSelectedArray = [_itemSelecteds mutableCopy];
    }
    
    [randomColorSwitch addTarget:self action:@selector(changeSwitch) forControlEvents:UIControlEventValueChanged];
    
    [blackWhiteSegmented addTarget:self
                         action:@selector(segmentedChangeValue)
               forControlEvents:UIControlEventValueChanged];
    
    switch (_typeColor) {
        case TYPE_COLOR_RANDOM:
            [randomColorSwitch setOn:YES animated:NO];
            [blackWhiteSegmented setSelectedSegmentIndex:1];
            break;
        case TYPE_COLOR_BINARY:
            [randomColorSwitch setOn:NO animated:NO];
            [blackWhiteSegmented setSelectedSegmentIndex:0];
            break;
        case TYPE_COLOR_CUSTOM:
            [randomColorSwitch setOn:NO animated:NO];
            [blackWhiteSegmented setSelectedSegmentIndex:1];
            break;
        default:
            break;
    }
}
-(void)loadAds{
    _bannerView.adUnitID = @"ca-app-pub-8374623097346952/1273566423";
    _bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
//    request.testDevices = @[ @"2ab5d6b443a035002ebddb537f878baf" ];
    [_bannerView loadRequest:request];
}

-(void)changeSwitch{
    if ([randomColorSwitch isOn]) {
        [itemSelectedArray removeAllObjects];
        [colorCollectionView reloadData];
        [blackWhiteSegmented setSelectedSegmentIndex:1];
    }
    else{
        if (itemSelectedArray.count == 0) {
            [blackWhiteSegmented setSelectedSegmentIndex:0];
        }
    }
}

-(void)segmentedChangeValue{
    switch (blackWhiteSegmented.selectedSegmentIndex) {
        case 0:
            [itemSelectedArray removeAllObjects];
            [colorCollectionView reloadData];
            [randomColorSwitch setOn:NO animated:YES];
            break;
        case 1:
            if (itemSelectedArray.count == 0) {
                [randomColorSwitch setOn:YES animated:YES];
            }
            break;
        default:
            break;
    }
}

-(void)brightnessChangeValue{
    [[UIScreen mainScreen] setBrightness:brightnessSlider.value];
}

-(void)speedChangeValue{
    _speed = 1. - speedSlider.value;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)cancelSetting:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[UIScreen mainScreen] setBrightness:_brightness];
}

- (IBAction)saveSetting:(id)sender {
    if ([randomColorSwitch isOn]) {
        _typeColor = TYPE_COLOR_RANDOM;
    }
    else{
        switch ([blackWhiteSegmented selectedSegmentIndex]) {
            case 0:
                _typeColor = TYPE_COLOR_BINARY;
                break;
            case 1:
                _typeColor = TYPE_COLOR_CUSTOM;
                break;
            default:
                break;
        }
    }
    NSDictionary *data = @{@"brightnessValue":[NSNumber numberWithFloat:brightnessSlider.value]
                           ,@"speedValue":[NSNumber numberWithFloat:_speed]
                           ,@"itemSelecteds":itemSelectedArray
                           ,@"typeColor":[NSString stringWithFormat:@"%d",_typeColor]
                           };
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:data];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"saveSetting" object:nil userInfo:data];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:@"dataSetting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   [self.navigationController popViewControllerAnimated:YES];
}

-(int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 30;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ColorCell *cell = [colorCollectionView dequeueReusableCellWithReuseIdentifier:@"colorCellId" forIndexPath:indexPath];
    if ([itemSelectedArray containsObject:indexPath]) {
        [cell selectItem];
    }
    else{
        [cell deselectItem];
    }
    
    [cell setColor:[UIColor colorWithHue:indexPath.item*0.033 saturation:1. brightness:1. alpha:1.]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width/6, collectionView.bounds.size.height/5);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [blackWhiteSegmented setSelectedSegmentIndex:1];
    
    ColorCell *cell = (ColorCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([itemSelectedArray containsObject:indexPath]) {
        [cell deselectItem];
        [itemSelectedArray removeObject:indexPath];
    }
    else{
        [cell selectItem];
        [itemSelectedArray addObject:indexPath];
    }
    [colorCollectionView reloadData];
    if (itemSelectedArray.count == 0) {
        [randomColorSwitch setOn:YES animated:YES];
    }
    else{
        [randomColorSwitch setOn:NO animated:YES];
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

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
