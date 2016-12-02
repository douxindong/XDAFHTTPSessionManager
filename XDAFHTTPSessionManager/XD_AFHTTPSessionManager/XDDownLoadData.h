//
//  XDDownLoadData.h
//  XDAFHTTPSessionManager
//
//  Created by 窦心东 on 2016/12/2.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XDDownLoadData : NSObject
singleton_interface(XDDownLoadData)
@property (nonatomic, strong) AFURLSessionManager *manager;
@property (nonatomic, retain) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSData   *resumeData;
@property (nonatomic, strong) NSString *resumeTmpPath;

@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isPause;
- (NSString *)resumeTmpPath;
// 开始下载
- (void)start;
// 继续下载
- (void)goon;
// 暂停下载
- (void)pause;
// 停止下载
- (void)stop;
- (void)downloadProgress:(NSProgress *)downloadProgress;
- (void)downloadCompletion:(NSURL *)filePath error:(NSError *)error;
@end
