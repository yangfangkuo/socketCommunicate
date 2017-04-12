//
//  ClientViewController.m
//  scoke通信
//
//  Created by Apple on 17/4/10.
//  Copyright © 2017年 SECO. All rights reserved.
//

#import "ClientViewController.h"
#import <GCDAsyncSocket.h>
#import "SocketManager.h"
#define IP  @"192.168.1.100"
@interface ClientViewController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *message;

@property (weak, nonatomic) IBOutlet UITextView *content;

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSTimer *heartTimer;


@end

@implementation ClientViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

// 和服务器进行链接
- (IBAction)connect:(UIButton *)sender
{
    // 1. 创建socket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.socket disconnect];

    NSLog(@"客户端socket = %@",self.socket );
    // 2. 与服务器的socket链接起来
    NSError *error = nil;
    self.addressTF.text = IP;
    BOOL result = [self.socket connectToHost:self.addressTF.text onPort:self.portTF.text.integerValue error:&error];
    
    // 3. 判断链接是否成功
    if (result) {
        [self addText:@"客户端链接服务器成功"];
    } else {
        [self addText:@"客户端链接服务器失败"];
    }
    if (error) {
        NSLog(@"客户端错误是%@",error);
    }
}

// 接收数据
- (IBAction)receiveMassage:(UIButton *)sender
{
    [self.socket readDataWithTimeout:-1 tag:0];
}

// 发送消息
- (IBAction)sendMassage:(UIButton *)sender
{
    
    [self.socket writeData:[self.message.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [self addText:@"客户端已经发送信息"];
    SocketManager *socket = [SocketManager defaultScocketManager];
    [socket.serverSocket readDataWithTimeout:-1 tag:0];

}


// textView填写内容
- (void)addText:(NSString *)text
{
    self.content.text = [self.content.text stringByAppendingFormat:@"%@\n", text];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - GCDAsyncSocketDelegate

/*
 客户端链接服务器端成功, 客户端获取地址和端口号
 我们在socket连接成功的时候去发送心跳包，在断开连接的时候去做一个断线重连,操作都在这个方法即可
 
 */
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self addText:[NSString stringWithFormat:@"链接服务器%@ port= %d", host,port]];
    //将客户端socket存到单例
    SocketManager *socket = [SocketManager defaultScocketManager];
    socket.clientSocket = sock;
    
    self.socket = sock;
    
    self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(sendHeartMessage:) userInfo:nil repeats:YES];

}
- (void)sendHeartMessage:(NSTimer *)timer
{
    //此处填写自己的一个心跳包发送,

}
/*
 断开连接
 */

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    
    NSLog(@"断开连接");
    
    [self.heartTimer invalidate];
    self.heartTimer = nil;
    
    if (err) {  //断线 或者其他原因
        [self.socket connectToHost:self.addressTF.text onPort:self.portTF.text.integerValue error:nil];
    }else{
        //手动断线  调用的        [self.socket disconnect ];

    }

    
}
// 客户端已经获取到内容
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self addText:content];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
