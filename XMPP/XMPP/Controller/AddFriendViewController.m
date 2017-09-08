//
//  AddFriendViewController.m
//  XMPP
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "AddFriendViewController.h"
#import "XMPPManager.h"
#import "UIViewController+MSHUD.h"

extern NSString * domain;

@interface AddFriendViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)addButtonClick:(id)sender {
    XMPPJID *jid = [XMPPJID jidWithUser:self.userNameTextField.text domain:domain resource:nil];
    [[XMPPManager defaultManager].roster subscribePresenceToUser:jid];
    [self showTextHUDAtWindow:@"已添加"];
    [self.navigationController popViewControllerAnimated:YES];
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
