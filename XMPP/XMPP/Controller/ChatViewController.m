//
//  ChatViewController.m
//  XMPP
//
//  Created by miss on 2017/9/7.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCell.h"
#import "MyChatCell.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldViewBottomSpace;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.chatToJid.user) {
        self.title = self.chatToJid.user;
    }
    
    [self setUpTableView];
    self.messageTextField.delegate = self;
    
    [[XMPPManager defaultManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self reloadMessage];
}

- (void)setUpTableView {
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-45);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ChatCell class]) bundle:nil] forCellReuseIdentifier:@"otherCell"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MyChatCell class]) bundle:nil] forCellReuseIdentifier:@"myCell"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatToJid];
    [message addBody:textField.text];
    [[XMPPManager defaultManager].stream sendElement:message];
    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"消息发送成功");
    self.messageTextField.text = @"";
    
    // 延迟的原因是有时候如果立即刷新消息不会出来
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadMessage];
    });
    
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"消息发送失败");

}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"收到新消息");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadMessage];
    });
}

- (void)reloadMessage {
    NSManagedObjectContext *context = [XMPPManager defaultManager].messageArchivingContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //这里面要填的是XMPPARChiver的coreData实例类型
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //对取到的数据进行过滤,传入过滤条件.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@", [XMPPManager defaultManager].stream.myJID.bare,self.chatToJid.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
    //设置排序的关键字
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    [self.messageArray removeAllObjects];
    [self.messageArray addObjectsFromArray:fetchedObjects];
    XMPPMessageArchiving_Message_CoreDataObject *message = [self.messageArray lastObject];

    if (message.body.length == 0) {
        return;
    }
    [self.tableView reloadData];
    
    // 伪延迟
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.messageArray.count > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });

}

- (void)keyboardChangeFrameNotification:(NSNotification *)noti {
    NSInteger curve = [[noti.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endFrame = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (endFrame.origin.y >= SCREEN_HEIGHT) {
        self.textFieldViewBottomSpace.constant = 0;
        self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-45);

    }else {
        self.textFieldViewBottomSpace.constant = SCREEN_HEIGHT-endFrame.origin.y;
        self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, endFrame.origin.y-45);

    }
    
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        [self.view layoutIfNeeded];

    }];
    
    if (self.messageArray.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];

    if (message.isOutgoing) {
        MyChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
        cell.messageLabel.text = message.body;
        if (message.bareJid.user.length > 0) {
            cell.nameLabel.text = @"我";
        }
        return cell;
    }else {
        ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
        cell.messageLabel.text = message.body;
        if (message.bareJid.user.length > 0) {
            cell.nameLabel.text = [message.bareJid.user substringWithRange:NSMakeRange(0, 1)];
        }
        return cell;
    }
}

- (NSMutableArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [[NSMutableArray alloc]init];
    }
    return _messageArray;
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
