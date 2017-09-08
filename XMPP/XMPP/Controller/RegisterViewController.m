//
//  RegisterViewController.m
//  XMPP
//
//  Created by miss on 2017/9/6.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPManager.h"
#import "UIViewController+MSHUD.h"

@interface RegisterViewController () <XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[XMPPManager defaultManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (IBAction)registerButtonClick:(id)sender {
    [[XMPPManager defaultManager] registerWithUserName:self.userNameTextField.text password:self.passwordTextField.text];
    [self showLoadingHUD];
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"注册成功");
    [self hideLoadingHUD];
    [self showTextHUDAtWindow:@"注册成功"];
    [self.navigationController popViewControllerAnimated:YES];
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
