//
//  SocketManager.m
//  scoke通信
//
//  Created by Apple on 2017/4/12.
//  Copyright © 2017年 SECO. All rights reserved.
//

#import "SocketManager.h"

@implementation SocketManager

+(SocketManager *)defaultScocketManager
{
    static SocketManager *socket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [[SocketManager alloc] init];
    });
    return socket;
}

@end
