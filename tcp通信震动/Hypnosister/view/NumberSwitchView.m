//
//  NumberSwitchView.m
//  Hypnosister
//
//  Created by chenbocheng on 2021/11/13.
//  Copyright © 2021 John Gallagher. All rights reserved.
//

#import "NumberSwitchView.h"
#import "Masonry.h"

static CGFloat tableViewPadding = 5;

@interface NumberSwitchView ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *sendTextBtn;
@property (nonatomic, strong) UISwitch *connectBtn;
@property (nonatomic, strong) UITextView *sendTextView;
@property (nonatomic, strong) UILabel *IPLabel;
@property (nonatomic, strong) UILabel *portLabel;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation NumberSwitchView

- (instancetype) init {
    self = [super init];
    if (self) {
        [self p_setupUI];
    }
    return self;
}

- (void) p_setupUI {
    [self addSubview:self.tableView];
    [self addSubview:self.sendTextBtn];
    [self addSubview:self.sendTextView];
    [self addSubview:self.IPLabel];
    [self addSubview:self.IPTextField];
    [self addSubview:self.portLabel];
    [self addSubview:self.portTextField];
    [self addSubview:self.statusLabel];
    [self addSubview:self.connectBtn];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_equalTo(20);
        make.top.equalTo(self).mas_equalTo(20);
        make.bottom.equalTo(self).offset(-40);
    }];
    
    [self.IPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(80);
        make.left.equalTo(self.tableView.mas_right);
        make.height.equalTo(@30);
        make.right.lessThanOrEqualTo(self).offset(-20);
    }];
    
    [self.IPTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.IPLabel.mas_bottom).offset(5);
        make.left.equalTo(self.IPLabel);
        make.height.equalTo(@30);
        make.right.offset(-20);
    }];
    
    [self.portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.IPTextField.mas_bottom).offset(10);
        make.left.equalTo(self.IPLabel);
        make.height.equalTo(@30);
        make.right.lessThanOrEqualTo(self).offset(-20);
    }];
    
    [self.portTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portLabel.mas_bottom).offset(5);
        make.left.equalTo(self.IPLabel);
        make.height.equalTo(@30);
        make.right.equalTo(self).offset(-20);
    }];
    
    [self.connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portTextField.mas_bottom).offset(10);
        make.right.equalTo(self).offset(-20);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.right.equalTo(self.connectBtn);
        make.left.equalTo(self.portTextField);
    }];
    
    [self.sendTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tableView.mas_right);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@100);
        make.top.equalTo(self.connectBtn.mas_bottom).offset(30);
    }];
    
    [self.sendTextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendTextView.mas_bottom).offset(20);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
        make.right.equalTo(self).offset(-20);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.frame.size.width / 2.0);
        }];
    });
    
}

- (void)p_sendDataClick {
    self.sendDataBlock();
}

- (void)p_connectionClick:(UISwitch *)sender {
    if (sender.on) {
        self.connectionBlock();
    }
    else {
//        self.disconnectionBlock();
    }
}

- (void)updateStatusLabel:(NSString *)textStr {
    self.statusLabel.text = textStr;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.contentInset = UIEdgeInsetsMake(tableViewPadding, 0, tableViewPadding, 0);
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (UIButton *)sendTextBtn {
    if (!_sendTextBtn) {
        _sendTextBtn = [UIButton new];
        [_sendTextBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendTextBtn.backgroundColor = [UIColor redColor];
        _sendTextBtn.layer.cornerRadius = 5;
        [_sendTextBtn addTarget:self action:@selector(p_sendDataClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendTextBtn;
}

- (UISwitch *)connectBtn {
    if (!_connectBtn) {
        _connectBtn = [UISwitch new];
        [_connectBtn addTarget:self action:@selector(p_connectionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _connectBtn;
}

- (UITextView *)sendTextView {
    if (!_sendTextView) {
        _sendTextView = [UITextView new];
        _sendTextView.layer.borderColor = [UIColor blackColor].CGColor;
        _sendTextView.layer.borderWidth = 1;
    }
    return _sendTextView;
}

- (UILabel *)IPLabel {
    if (!_IPLabel) {
        _IPLabel = [UILabel new];
        _IPLabel.text = @"服务器IP地址：";
    }
    return _IPLabel;
}

- (UILabel *)portLabel {
    if (!_portLabel) {
        _portLabel = [UILabel new];
        _portLabel.text = @"服务器端口号：";
    }
    return _portLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
    }
    return _statusLabel;
}

- (UITextField *)IPTextField {
    if (!_IPTextField) {
        _IPTextField = [UITextField new];
        _IPTextField.borderStyle = UITextBorderStyleLine;
        _IPTextField.text = @"192.168.1.5";
    }
    return _IPTextField;
}

- (UITextField *)portTextField {
    if (!_portTextField) {
        _portTextField = [UITextField new];
        _portTextField.borderStyle = UITextBorderStyleLine;
        _portTextField.text = @"6800";
    }
    return _portTextField;
}

@end
