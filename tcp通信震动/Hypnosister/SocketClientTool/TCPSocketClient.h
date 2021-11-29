//
//  TCPSocketClient.h
//  LCSocketClientDemo
//
//  Created by 刘川 on 2018/12/19.
//  Copyright © 2018 alex. All rights reserved.
#define Check_ValidString(x)  (x != nil && [x isKindOfClass:[NSString class]] && x.length > 0)

#ifndef keywordify
#if DEBUG
#define keywordify autoreleasepool {}
#else
#define keywordify try {} @catch (...) {}
#endif
#endif

#ifndef Weakify
#if __has_feature(objc_arc)

#define Weakify( object ) keywordify __weak __typeof__(object) weak_##object = object;

#else

#define Weakify( object ) keywordify __block __typeof__(object) block_##object = object;


#endif
#endif

#ifndef Strongify
#if __has_feature(objc_arc)

#define Strongify( object ) keywordify __typeof__(object) object = weak_##object;

#else

#define Strongify( object ) keywordify __typeof__(object) object = block_##object;

#endif
#endif

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

// 连接状态
typedef NS_ENUM(NSInteger, SocketConnectStatus) {
    SocketConnectStatusDisconnected = 0,   // 未连接
    SocketConnectStatusConnecting = 1,     // 连接中
    SocketConnectStatusConnected = 2       // 已连接
};


@class  TCPSocketClient;
@protocol TCPSocketClientDelegate <NSObject>

/**
 读取数据
 */
- (void)socket:(TCPSocketClient *)socket didReadData:(NSData *) data;

/**
 监听连接状态变化
 */
- (void)socket:(TCPSocketClient *)socket SocketConnectStatus:(SocketConnectStatus) connectStatus;

@end


@interface TCPSocketClient : NSObject

/**
 获取全局长连接(单例)
 */
+ (instancetype)sharedSocket;

@property (nonatomic, copy) void(^recvDataBlock)(NSString *);
@property (nonatomic, copy) NSString *IPStr;
@property (nonatomic, copy) NSString *portStr;

/**
  连接服务器
 */
- (void)connectServerWithDelegate:(id) delegate ToHost:(NSString *)host onPort:(uint16_t)port;

/**
 断开连接
 */
- (void)disConnectServer;

/**
 发送数据
 */
- (void)sendData:(NSData *)data;

/**
 是否连接
 */
- (BOOL)isConnection;

/**
 发送心跳
 */
- (void)beginSendHeartbeat;

@end


NS_ASSUME_NONNULL_END

