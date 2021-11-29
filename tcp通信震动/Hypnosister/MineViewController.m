//
//  MineViewController.m
//  Hypnosister
//
//  Created by bytedance on 2021/6/2.
//  Copyright © 2021 John Gallagher. All rights reserved.
// 11.19修改

#import "MineViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import "TCPSocketClient.h"
#import "NumberSwitchView.h"
#import "Masonry.h"
#import "NumberSwitchTableViewCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import "QiAudioPlayer.h"

//htons : 将一个无符号短整型的主机数值转换为网络字节顺序，不同cpu 是不同的顺序 (big-endian大尾顺序 , little-endian小尾顺序)
#define SocketPort htons(8040) //端口
//inet_addr是一个计算机函数，功能是将一个点分十进制的IP转换成一个长整数型数
#define SocketIP   inet_addr("127.0.0.1") // ip

@interface MineViewController ()<TCPSocketClientDelegate, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>
{
    SystemSoundID sound;
}

//属性，用于接收socket创建成功后的返回值
@property (nonatomic, assign) int clinenId;
@property (nonatomic, strong) NumberSwitchView *numberSwitchView;

@property(nonatomic, strong)NSMutableArray *cellArrray;//存cell
@property(nonatomic, strong)NSMutableArray *indexPathArray;//存indexPath
@property(nonatomic, strong)NSMutableArray *cellTextArray;//获取cell的text数据
@property(nonatomic, strong)NSMutableArray *cellBtnArray; //获取cell的btn数据

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *vibrationTimer;
@property (nonatomic, copy) NSSet *dataSet;
@property (nonatomic, assign) BOOL isShake;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @Weakify(self)
    void(^recvProcessBlock)(NSString * _Nonnull) = ^(NSString * _Nonnull serverStr){
        @Strongify(self)
        [self p_notifyIPhone:serverStr];
    };
    [TCPSocketClient sharedSocket].recvDataBlock = recvProcessBlock;
    [self p_setupUI];
    [self setupTimer];
    [self initAudioSession];
}

- (void)initAudioSession {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_timer invalidate];
    _timer = nil;
}

- (void)p_setupUI {
    [self.view addSubview:self.numberSwitchView];
    [self.numberSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)p_connection { //  开启连接
    NSString *IPStr = self.numberSwitchView.IPTextField.text;
    if (!Check_ValidString(IPStr)) {
        return;
    }
    NSString *portStr = self.numberSwitchView.portTextField.text;
    if (!Check_ValidString(portStr)) {
        return;
    }
    [TCPSocketClient sharedSocket].IPStr = IPStr;
    [TCPSocketClient sharedSocket].portStr = portStr;
    [[TCPSocketClient sharedSocket] connectServerWithDelegate:self ToHost:IPStr onPort:[portStr intValue]];
    
    [[QiAudioPlayer sharedInstance].player play];
    [QiAudioPlayer sharedInstance].needRunInBackground = YES;
    
    [self setUserDefaultFor:@"IP" value:IPStr];
    [self setUserDefaultFor:@"port" value:portStr];
}

- (void)setupTimer {
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerEvent:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

- (void)timerEvent:(id)sender {
    NSLog(@"定时器运行中");
    if ([TCPSocketClient sharedSocket].isConnection) {
        [self.numberSwitchView updateStatusLabel:@"已连接"];
    } else {
        [self.numberSwitchView updateStatusLabel:@"已断开"];
    }
}

- (void)startShakeSound {
    if (self.isShake) {
        return;
    }
    self.isShake = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SomethingJustLikeThis" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
    AudioServicesAddSystemSoundCompletion(sound, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(sound);
    _vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playSystemSound) userInfo:nil repeats:YES];
}

- (void)playSystemSound {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)stopShakeSound {
    if (!self.isShake) {
        return;
    }
    self.isShake = NO;
    [_vibrationTimer invalidate];
    AudioServicesRemoveSystemSoundCompletion(sound);
    AudioServicesDisposeSystemSoundID(sound);
}

void soundCompleteCallback(SystemSoundID sound,void * clientData) {
    AudioServicesPlaySystemSound(sound);
}

#pragma -mark TCPSocketClientDelegate
/**
 读取数据
 */
- (void)socket:(TCPSocketClient *)socket didReadData:(NSData *) data{
    NSString *serverStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接收到数据：%@",serverStr);
    [self p_notifyIPhone:serverStr];
}

/**
 监听连接状态变化
 */
- (void)socket:(TCPSocketClient *)socket SocketConnectStatus:(SocketConnectStatus) connectStatus{
    NSLog(@"连接状态：%ld",connectStatus);
}
//////////////////////////////////////
- (void)p_notifyIPhone:(NSString *)serverStr {
    if (Check_ValidString(serverStr)) {
        serverStr = [serverStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        serverStr = [serverStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        NSArray* cellDataArray = [self p_getCellData];
        for (int i = 0; i < cellDataArray.count; ++i) {
            NSString *str = (NSString *)cellDataArray[i];
            if ([serverStr isEqualToString:str]) {
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                NumberSwitchTableViewCell *cell = [self.numberSwitchView.tableView cellForRowAtIndexPath:indexPath];
//                if ([serverStr hasPrefix:@"1"]) {
//                    cell.inputText.backgroundColor = [UIColor redColor];
//                } else if ([serverStr hasPrefix:@"2"]) {
//                    cell.inputText.backgroundColor = [UIColor greenColor];
//                }
                NSMutableSet *tmpSet = [[NSMutableSet alloc] initWithSet:self.dataSet];
                [tmpSet addObject:str];
                self.dataSet = [tmpSet copy];
                [self startShakeSound];
                break;
            }
        }
    }
}

- (NSArray *) p_getCellData {
    NSMutableArray *cellTextArray = [NSMutableArray new];
    NSInteger sections = self.numberSwitchView.tableView.numberOfSections;
    for (int section = 0; section < sections; section++) {
      NSInteger rows = [self.numberSwitchView.tableView numberOfRowsInSection:section];
      for (int row = 0; row < rows; row++) {
          NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
          NumberSwitchTableViewCell *cell = [self.numberSwitchView.tableView cellForRowAtIndexPath:indexPath];
          if (Check_ValidString(cell.inputText.text) && cell.switchBtn.on) {
              NSString *str = cell.inputText.text;
              str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
              str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
              [cellTextArray addObject:str];
          }
      }
    }
    return [cellTextArray copy];
}

- (void)p_sendData {
    NSString *textStr = self.numberSwitchView.sendTextView.text;
    if (Check_ValidString(textStr)) {
        [[TCPSocketClient sharedSocket] sendData:[textStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)p_switchClick:(NumberSwitchTableViewCell *)cell {
    if (!cell.switchBtn.on) {
        NSString *str = cell.inputText.text;
        if ([self.dataSet containsObject:str]) {
            NSMutableSet *tmpSet = [[NSMutableSet alloc] initWithSet:self.dataSet];
            [tmpSet removeObject:str];
            self.dataSet = [tmpSet copy];
        }
        cell.inputText.backgroundColor = [UIColor clearColor];
    } else {
        
    }
    if (self.dataSet.count <= 0) {
        [self stopShakeSound];
    }
}

- (void)setUserDefaultFor:(NSString *)key value:(NSString *)value {
    if (value != nil && key != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    }
}

- (NSString *)getUserDefaultValueBy:(NSString *)key{
    if (key != nil) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
    return @"";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NumberSwitchTableViewCell *cell = (NumberSwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(NumberSwitchTableViewCell.class)];
    NumberSwitchTableViewCell *cell = (NumberSwitchTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [NumberSwitchTableViewCell new];
    }
    cell.switchBlock = ^(NumberSwitchTableViewCell *cell){
        [self p_switchClick:cell];
    };
    [self.indexPathArray addObject:indexPath];
    [self.cellArrray addObject:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

#pragma mark - Lazy View
- (NumberSwitchView *)numberSwitchView {
    if (!_numberSwitchView) {
        _numberSwitchView = [NumberSwitchView new];
        _numberSwitchView.tableView.delegate = self;
        _numberSwitchView.tableView.dataSource = self;
        @Weakify(self)
        _numberSwitchView.sendDataBlock = ^{
            @Strongify(self)
            [self p_sendData];
        };
        _numberSwitchView.connectionBlock = ^{
            @Strongify(self)
            [self p_connection];
        };
        _numberSwitchView.IPTextField.text = [self getUserDefaultValueBy:@"IP"];
        _numberSwitchView.portTextField.text = [self getUserDefaultValueBy:@"port"];
    }
    return _numberSwitchView;
}

- (NSSet *)dataSet {
    if (!_dataSet) {
        _dataSet = [NSSet new];
    }
    return [_dataSet copy];
}

@end
