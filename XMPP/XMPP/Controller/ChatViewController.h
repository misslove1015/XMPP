//
//  ChatViewController.h
//  XMPP
//
//  Created by miss on 2017/9/7.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"

@interface ChatViewController : UIViewController

@property (nonatomic, strong) XMPPJID *chatToJid;

@end
