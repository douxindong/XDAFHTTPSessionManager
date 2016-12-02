//
//  ViewController.m
//  XDAFHTTPSessionManager
//
//  Created by 窦心东 on 2016/12/2.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import "ViewController.h"
#import "XDDownLoadData.h"
#import "XDHTTPSessionManager.h"
#define XDSessionManager [XDHTTPSessionManager shareManager]
#define DownLoadData [XDDownLoadData sharedXDDownLoadData]
@interface ViewController (){
    UIButton *button;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [button setTitle:@"开始" forState:UIControlStateNormal];
    //    [button setBackgroundColor:[UIColor redColor]];
    //    button.frame = CGRectMake(100, 100, 100, 100);
    //    [self.view addSubview:button];
    //    [button addTarget:self action:@selector(buttonclick) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)buttonclick{
    //封装好了，展示需要自己写，这仅仅是显示一下更高深的 需要自行使用API
    if ([button.titleLabel.text isEqualToString:@"开始"]) {
        [button setTitle:@"暂停" forState:UIControlStateNormal];
        [DownLoadData start];
    } else {
        [button setTitle:@"开始" forState:UIControlStateNormal];
        [DownLoadData pause];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   
    //当前只示例两个 其他方式一样的形式
    //进行数据下载
    [self download];
    //进行post请求
    [self postData];
    
    
    
    
    
}

- (void)download{
    [XDSessionManager downloadWithURL:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4" fileDir:@"video" progress:^(NSProgress *progress) {
        [DownLoadData downloadProgress:progress];
    } success:^(NSString *filePath) {
        NSLog(@"全路径是filePath.absoluteString ======%@",filePath);
    } failure:^(NSError *error) {
        NSLog(@"error == %@",error);
    }];

}
- (void)postData{
    NSDictionary *parameters = @{
                                 @"pageNo":@1,
                                 @"pageSize":@"20"
                                 };
    [XDSessionManager POST:@"http://115.28.11.62:8080/heal/api/heal/plan/list" parameters:parameters progress:^(NSProgress *progress) {
        [DownLoadData downloadProgress:progress];
    } success:^(id responseObject) {
        
        NSLog(@"responseObject%@",[responseObject yy_modelDescription]);
    } failure:^(NSError *error) {
        NSLog(@"error==%@",error);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
