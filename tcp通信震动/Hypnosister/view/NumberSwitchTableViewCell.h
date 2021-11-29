//
//  NumberSwitchTableViewCell.h
//  Hypnosister
//
//  Created by chenbocheng on 2021/11/13.
//  Copyright © 2021 John Gallagher. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NumberSwitchTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly)UITextField *inputText;
@property (nonatomic, strong, readonly)UISwitch *switchBtn;
@property (nonatomic, copy) void(^switchBlock)(NumberSwitchTableViewCell *cell);

@end

NS_ASSUME_NONNULL_END
