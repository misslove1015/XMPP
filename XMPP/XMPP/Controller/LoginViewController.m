//
//  LoginViewController.m
//  XMPP
//
//  Created by miss on 2017/9/6.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPPManager.h"
#import "UIViewController+MSHUD.h"
#import "MSAlert.h"

@interface LoginViewController () <XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[XMPPManager defaultManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (IBAction)loginButtonClick:(id)sender {
    if (self.userNameTextField.text.length == 0) {
        [self showTextHUD:@"您还未输入用户名"];
        return;
    }
    if (self.passwordTextField.text.length == 0) {
        [self showTextHUD:@"您还未输入密码"];
        return;
    }
    [self showLoadingHUD];
    [[XMPPManager defaultManager] loginWithUserName:self.userNameTextField.text password:self.passwordTextField.text];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"登录成功");
    [self hideLoadingHUD];
    UIViewController *nav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"friendNav"];
    [UIApplication sharedApplication].delegate.window.rootViewController = nav;
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[UIApplication sharedApplication].delegate.window cache:NO];
    }];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    [self hideLoadingHUD];
    [MSAlert showAlertWithTitle:@"登录失败" message:@"请检查您的用户名和密码"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
