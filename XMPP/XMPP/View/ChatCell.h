//
//  ChatCell.h
//  XMPP
//
//  Created by miss on 2017/9/7.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
