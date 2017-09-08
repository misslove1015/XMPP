//
//  FriendsViewController.m
//  XMPP
//
//  Created by miss on 2017/9/6.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "FriendsViewController.h"
#import "ChatViewController.h"
#import "AddFriendViewController.h"
#import "MSAlert.h"

extern NSString * domain;

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource, XMPPRosterDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *friendArray;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;   
    
    [[XMPPManager defaultManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [[XMPPManager defaultManager].roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[XMPPManager defaultManager].roster fetchRoster];
    
}

- (IBAction)addFriend:(id)sender {
    AddFriendViewController *addFriend = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addFriendViewController"];
    [self.navigationController pushViewController:addFriend animated:YES];
}

- (IBAction)logout:(id)sender {
    [MSAlert showAlertWithTitle:@"确定退出吗？" message:nil confirmButtonAction:^{
        [[XMPPManager defaultManager] logout];
        UIViewController *nav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginNavController"];
        [UIApplication sharedApplication].delegate.window.rootViewController = nav;
        [UIView animateWithDuration:0.5 animations:^{
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[UIApplication sharedApplication].delegate.window cache:NO];
        }];

    }];
    
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.friendArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    XMPPJID *jid = self.friendArray[indexPath.row];
    cell.textLabel.text = jid.user;
    return cell;
}

- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version{
    NSLog(@"开始检索好友列表");
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
    NSLog(@"每一个好友都会走一次这个方法");
    // 获得item的属性里的jid字符串，再通过它获得jid对象
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    // 是否已经添加
    if ([self.friendArray containsObject:jid]) {
        return;
    }
    [self.friendArray addObject:jid];
    [self.tableView reloadData];
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"好友列表检索完毕");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 删除有延迟
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPJID *jid = self.friendArray[indexPath.row];
        [self.friendArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        // 从服务器删除
        [[XMPPManager defaultManager].roster removeUser:jid];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XMPPJID *jid = self.friendArray[indexPath.row];
    ChatViewController *chat = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"chatViewController"];
    chat.chatToJid = jid;
    [self.navigationController pushViewController:chat animated:YES];
}

- (NSMutableArray *)friendArray {
    if (!_friendArray) {
        _friendArray = [[NSMutableArray alloc]init];
    }
    return _friendArray;
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
