//
//  ColorCell.m
//  Đèn chớp
//
//  Created by VMio69 on 8/17/16.
//  Copyright © 2016 VMio69. All rights reserved.
//

#import "ColorCell.h"
@interface ColorCell()
{
    IBOutlet UIImageView *selectedImage;
    
}
@end
@implementation ColorCell

-(void)setColor:(UIColor*)color{
    [self setBackgroundColor:color];
}

-(void)selectItem{
    [selectedImage setHidden:NO];
}

-(void)deselectItem{
    [selectedImage setHidden:YES];
}

@end
