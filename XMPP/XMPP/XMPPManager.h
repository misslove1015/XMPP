//
//  XMPPManager.h
//  XMPP
//
//  Created by miss on 2017/9/6.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>

@interface XMPPManager : NSObject

@property (nonatomic, strong) XMPPStream *stream;
@property (nonatomic, strong) XMPPRoster *roster;
@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;
@property (nonatomic, strong) NSManagedObjectContext *messageArchivingContext;

+ (XMPPManager *)defaultManager;

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password;

- (void)registerWithUserName:(NSString *)userName password:(NSString *)password;

- (void)logout;

@end
