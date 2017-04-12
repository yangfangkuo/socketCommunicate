//
//  ServeViewController.m
//  scoke通信
//
//  Created by Apple on 17/4/10.
//  Copyright © 2017年 SECO. All rights reserved.
//

#import "ServeViewController.h"
#import "SocketManager.h"
#define IP  @"127.0.0.1"

#import <GCDAsyncSocket.h>

@interface ServeViewController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *message;

@property (weak, nonatomic) IBOutlet UITextView *content;

@property (nonatomic, strong) GCDAsyncSocket *socket;


@end

@implementation ServeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

/*
            ***************注意***********************
 此处创建的socket监听端口,但是以后通信并不是使用的当前的这个socket,而是使用
 - (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
 方法中返回的newSocket

 
 */
- (IBAction)connect:(UIButton *)sender
{
    // 1. 创建socket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 2. 端口监听
    NSError *error = nil;
    BOOL result = [self.socket acceptOnPort:self.portTF.text.integerValue error:&error];
    
    // 3. 判断链接是否成功
    if (result) {
        [self addText:@"端口开放成功"];
    } else {
        [self addText:@"端口开放失败"];
    }
    NSLog(@"服务器端错误是%@",error);

}

// 接收数据
- (IBAction)receiveMassage:(UIButton *)sender
{
    
    [self.socket readDataWithTimeout:-1 tag:0];
    
}

// 发送消息
- (IBAction)sendMassage:(UIButton *)sender
{
    [self addText:@"发送信息成功"];
    [self.socket writeData:[self.message.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    //默认发出的socket信息,客户端并不会直接就调用socketDidRead,而是需要主动去目标栈里面去读取,此处使用单利manger主动去获取
    SocketManager *socket = [SocketManager defaultScocketManager];
    [socket.clientSocket readDataWithTimeout:-1 tag:0];
}


// textView填写内容
- (void)addText:(NSString *)text
{
    self.content.text = [self.content.text stringByAppendingFormat:@"%@\n", text];
}



#pragma mark - GCDAsyncSocketDelegate
/*
 在这个方法中打印socket 可以发现和初始化socket区别
 */
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [self addText:@"链接成功"];
    //IP: newSocket.connectedHost
    
    [self addText:[NSString stringWithFormat:@"sock 链接地址:%@", sock.connectedHost]];
    [self addText:[NSString stringWithFormat:@"sock 端口号:%hu", sock.connectedPort]];

    //端口号: newSocket.connectedPort
    [self addText:[NSString stringWithFormat:@"new链接地址:%@", newSocket.connectedHost]];
    [self addText:[NSString stringWithFormat:@"new端口号:%hu", newSocket.connectedPort]];
    // short: %hd
    // unsigned short: %hu
    
    //将服务器端通信socket存到单例,
    SocketManager *socket = [SocketManager defaultScocketManager];
    socket.serverSocket = newSocket;
    
    // 建立链接后生成的新的socket 存储新的端口号
    self.socket = newSocket;

    
}
// 服务器端已经获取到内容
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self addText:content];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
