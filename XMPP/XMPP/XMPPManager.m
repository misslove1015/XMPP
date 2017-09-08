//
//  XMPPManager.m
//  XMPP
//
//  Created by miss on 2017/9/6.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "XMPPManager.h"
#import "MSAlert.h"

NSString * const hostName = @"192.168.0.237";
NSString * const domain = @"misss-mac.local";
NSInteger const hostPort = 5222;

typedef NS_ENUM(NSUInteger, connectServerPurposeType) {
    ConnectServerPurposeLogin,
    ConnectServerPurposeRegister,
};

@interface XMPPManager () <XMPPStreamDelegate, XMPPRosterDelegate>

@property (nonatomic, copy)   NSString *password;
@property (nonatomic, strong) XMPPJID  *fromJid;
@property (nonatomic, assign) connectServerPurposeType connectServerPurposeType;

@end

@implementation XMPPManager

+ (XMPPManager *)defaultManager {
    static dispatch_once_t onceToken;
    static XMPPManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc]init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]){
        self.stream = [[XMPPStream alloc]init];
        self.stream.hostName = hostName;
        self.stream.hostPort = hostPort;
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // 好友列表
        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        self.roster = [[XMPPRoster alloc]initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        [self.roster activate:self.stream];
        self.roster.autoFetchRoster = NO; // 关闭自动获取好友列表
        [self.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];

        // 消息
        XMPPMessageArchivingCoreDataStorage *messageStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.messageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:messageStorage dispatchQueue:dispatch_get_main_queue()];
        [self.messageArchiving activate:self.stream];
        self.messageArchivingContext = messageStorage.mainThreadManagedObjectContext;
        
    }
    return self;
}

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password {
    self.connectServerPurposeType = ConnectServerPurposeLogin;
    self.password = password;
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:domain resource:nil];
    self.stream.myJID = jid;
    [self connectToServer];
}

- (void)connectToServer{
    // 如果已经存在一个连接，需要将当前的连接断开，然后再开始新的连接
    if ([self.stream isConnected]) {
        [self logout];
    }
    NSError *error = nil;
    [self.stream connectWithTimeout:30.0f error:&error];
    if (error) {
        NSLog(@"error = %@",error);
    }
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"连接服务器失败");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"连接服务器成功");
    if (self.connectServerPurposeType == ConnectServerPurposeLogin) { // 登录
        [sender authenticateWithPassword:self.password error:nil];
    }else{ // 注册
        [sender registerWithPassword:self.password error:nil];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"验证成功");
    /**
     * unavailable 离线
     * available 上线
     * away 离开
     * do not disturb 忙碌
     */
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.stream sendElement:presence];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"验证失败,请检查你的用户名或密码是否正确 %@",error);
}

- (void)registerWithUserName:(NSString *)userName password:(NSString *)password {
    self.connectServerPurposeType = ConnectServerPurposeRegister;
    self.password = password;
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:domain resource:nil];
    self.stream.myJID = jid;
    [self connectToServer];
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    NSLog(@"注册失败 %@",error);
}

- (void)logout{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.stream sendElement:presence];
    [self.stream disconnect];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"收到好友请求");
    self.fromJid = presence.from;
    [MSAlert showAlertWithTitle:@"好友添加请求"
                        message:[NSString stringWithFormat:@"%@想要添加你",presence.from.user]
             confirmButtonTitle:@"同意"
              cancelButtonTitle:@"拒绝"
            confirmButtonAction:^{
                [self.roster acceptPresenceSubscriptionRequestFrom:self.fromJid andAddToRoster:YES];

    }
             cancelButtonAction:^{
                [self.roster rejectPresenceSubscriptionRequestFrom:self.fromJid];
                [self.roster removeUser:self.fromJid];

    }];
    
}


@end
