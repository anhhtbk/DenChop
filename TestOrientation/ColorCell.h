//
//  ColorCell.h
//  Đèn chớp
//
//  Created by VMio69 on 8/17/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorCell : UICollectionViewCell
-(void)setColor:(UIColor*)color;
-(void)selectItem;
-(void)deselectItem;
@end
