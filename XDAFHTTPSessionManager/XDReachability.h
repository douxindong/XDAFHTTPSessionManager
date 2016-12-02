//
//  XDReachability.h
//  AFN封装实时更新网络状态
//
//  Created by 窦心东 on 15/11/8.
//  Copyright © 2015年 XD. All rights reserved.
//
/*******************************************************************
  调用说明
 ViewController.m
 加上#import "XDReachability.h"
 @property (nonatomic,copy) NSString *status;
 //真机测试时在同一个页面测试不同的网络的状态
 - (void)viewDidLoad {
 [super viewDidLoad];
            
     [XDReachability XDwithSuccessBlock:^(NSString *status) {
             
                     NSLog(@"网络状态%@",status);
                     self.status = status;
                     
                     if ([status isEqualToString:@"无连接"]) {
                     //一遇到网络不好时 就走这里   显示一个刷新按钮 点击重复请求操作的
                     } else if ([status isEqualToString:@"3G/4G网络"]){
                     //一旦检测到数据网络时 就走这里  请求网络行为
                     }else if ([status isEqualToString:@"wifi状态下"]){
                     //一旦Wi-Fi状态下时 就走到这  请求网络行为
                     }else if ([status isEqualToString:@"未知网络状态"]){
                     //一旦未知网络状态下时 就走到这 提示目前网络未知 
                     }
             }] ;
 }
********************************************************************/
#import "AFNetworking.h"

//成功回调
typedef void (^successBlock)(NSString *status);

@interface XDReachability : AFNetworkReachabilityManager
/**
 *  网络状态
 */
+ (void)XDwithSuccessBlock:(successBlock)success;
@end
