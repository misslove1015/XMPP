//
//  UIViewController+MSHUD.m
//  Miss
//
//  Created by miss on 2017/4/28.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "UIViewController+MSHUD.h"
#import "MBProgressHUD.h"

@implementation UIViewController (MSHUD)

- (void)showTextHUD:(NSString *)text {
    MBProgressHUD *textHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    textHUD.mode = MBProgressHUDModeText;
    textHUD.label.text = text;
    textHUD.label.textColor = [UIColor whiteColor];
    textHUD.margin = 10;
    textHUD.userInteractionEnabled = NO;
    textHUD.bezelView.color = [UIColor blackColor];
    [textHUD showAnimated:YES];
    [textHUD hideAnimated:YES afterDelay:1];
}

- (void)showTextHUDAtWindow:(NSString *)text {
    MBProgressHUD *textHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    textHUD.mode = MBProgressHUDModeText;
    textHUD.label.text = text;
    textHUD.label.textColor = [UIColor whiteColor];
    textHUD.margin = 10;
    textHUD.bezelView.color = [UIColor blackColor];
    textHUD.userInteractionEnabled = NO;
    [textHUD showAnimated:YES];
    [textHUD hideAnimated:YES afterDelay:1];
}

- (void)showLoadingHUD {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideLoadingHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
