//
//  XDDownLoadData.m
//  XDAFHTTPSessionManager
//
//  Created by 窦心东 on 2016/12/2.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import "XDDownLoadData.h"

@implementation XDDownLoadData

singleton_implementation(XDDownLoadData)
- (AFURLSessionManager *)manager {
    if (_manager == nil) {
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}

- (NSString *)resumeTmpPath {
    if (_resumeTmpPath == nil) {
        _resumeTmpPath = [@"resumeTmpData.tmp" q_appendCachePath];
    }
    return _resumeTmpPath;
}

// 开始下载

- (void)start {
    
    if (self.isDownloading) {
        NSLog(@"已经开始下载");
        return;
    }
    
    if (self.isPause) {
        
        NSLog(@"继续下载");
        
        [self.downloadTask resume];
        
        self.isPause = NO;
        self.isDownloading = YES;
        return;
    }
    //如果内存中 这个路径的文件不在或者没有大小， 就进行开始 ；  反之有的话，继续下载
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.resumeTmpPath]) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"]];
        
        self.downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
            [self downloadProgress:downloadProgress];
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:[response.suggestedFilename q_appendDocumentPath]];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            [self downloadCompletion:filePath error:error];
        }];
        
        [self.downloadTask resume];
        
        self.isPause = NO;
        self.isDownloading = YES;
        
    } else {
        [self goon];
    }
}

// 继续下载

- (void)goon {
    
    if (self.isDownloading) {
        NSLog(@"已经开始下载");
        return;
    }
    
    if (self.isPause) {
        
        [self.downloadTask resume];
        NSLog(@"继续下载");
        
    } else {
        
        self.resumeData = [NSData dataWithContentsOfFile:self.resumeTmpPath];
        
        self.downloadTask = [self.manager downloadTaskWithResumeData:self.resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            
            [self downloadProgress:downloadProgress];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:[response.suggestedFilename q_appendDocumentPath]];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            [self downloadCompletion:filePath error:error];
        }];
        
        [self.downloadTask resume];
        
        NSLog(@"继续下载");
    }
    
    self.isPause = NO;
    self.isDownloading = YES;
}

// 暂停下载

- (void)pause {
    
    if (!self.isDownloading) {
        NSLog(@"已经停止下载");
        return;
    }
    
    [self.downloadTask suspend];
    
    NSLog(@"暂停下载");
    
    self.isPause = YES;
    self.isDownloading = NO;
}

// 停止下载

- (void)stop {
    
    if (!self.isDownloading) {
        NSLog(@"已经停止下载");
        return;
    }
    
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
        if (resumeData) {
            
            self.resumeData = resumeData;
            
            [self.resumeData writeToFile:self.resumeTmpPath atomically:YES];
        }
        
        self.downloadTask = nil;
        
        NSLog(@"停止下载");
    }];
    
    self.isDownloading = NO;
}

- (void)downloadProgress:(NSProgress *)downloadProgress {
    
    float progress = (1.0 *downloadProgress.completedUnitCount / downloadProgress.totalUnitCount)*100;
    
    dispatch_async(dispatch_get_main_queue(), ^{
//                [self.progressBtn q_setButtonWithProgress:progress lineWidth:10 lineColor:nil backgroundColor:[UIColor yellowColor]];
        NSLog(@"进度%.0f%%",progress);
    });
}

- (void)downloadCompletion:(NSURL *)filePath error:(NSError *)error {
    
    self.isDownloading = NO;
    
    if (error == nil) {
        
        NSLog(@"success: %@", filePath.path);
        
        [[NSFileManager defaultManager] removeItemAtPath:self.resumeTmpPath error:nil];
        
    } else {
        
        NSLog(@"%@", error);
        
        if (error) {
            NSLog(@"failure: %@", error.userInfo[NSLocalizedDescriptionKey]);
            
            self.resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
        }
        
        if ([error.localizedFailureReason isEqualToString:@"No such file or directory"]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:self.resumeTmpPath error:nil];
            
            [self start];
        }
    }
}
@end
