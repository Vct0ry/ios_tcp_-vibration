//
//  NumberSwitchTableViewCell.m
//  Hypnosister
//
//  Created by chenbocheng on 2021/11/13.
//  Copyright © 2021 John Gallagher. All rights reserved.
//

#import "NumberSwitchTableViewCell.h"
#import "Masonry.h"

@interface NumberSwitchTableViewCell ()

@property (nonatomic, strong)UITextField *inputText;
@property (nonatomic, strong)UISwitch *switchBtn;


@end

@implementation NumberSwitchTableViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_setupUI];
    }
    return self;
}

- (void)p_setupUI {
    [self.contentView addSubview:self.inputText];
    [self.contentView addSubview:self.switchBtn];
    
    [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self);
//        make.width.mas_equalTo(100);
        make.right.equalTo(self.switchBtn.mas_left).offset(-10);
    }];
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inputText.mas_right).offset(10);
        make.right.centerY.equalTo(self);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)p_switchClick {
    self.switchBlock(self);
}

#pragma mark-lazy view
- (UITextField *)inputText {
    if (!_inputText) {
        _inputText = [UITextField new];
        _inputText.borderStyle = UITextBorderStyleLine;
        _inputText.clearsOnBeginEditing = YES;
    }
    return _inputText;
}

- (UISwitch *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [UISwitch new];
        [_switchBtn addTarget:self action:@selector(p_switchClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

@end
