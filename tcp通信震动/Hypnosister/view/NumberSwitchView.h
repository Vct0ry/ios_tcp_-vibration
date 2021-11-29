//
//  NumberSwitchView.h
//  Hypnosister
//
//  Created by chenbocheng on 2021/11/13.
//  Copyright © 2021 John Gallagher. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NumberSwitchView : UIView

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly)UITextView *sendTextView;
@property (nonatomic, strong) UITextField *IPTextField;
@property (nonatomic, strong) UITextField *portTextField;

@property (nonatomic, copy) void(^sendDataBlock)(void);
@property (nonatomic, copy) void(^connectionBlock)(void);

- (void)updateStatusLabel:(NSString *)textStr;

@end

NS_ASSUME_NONNULL_END
