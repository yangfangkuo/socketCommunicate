//
//  SocketManager.h
//  scoke通信
//
//  Created by Apple on 2017/4/12.
//  Copyright © 2017年 SECO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>

@interface SocketManager : NSObject
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;

+ (SocketManager *)defaultScocketManager;

@end
