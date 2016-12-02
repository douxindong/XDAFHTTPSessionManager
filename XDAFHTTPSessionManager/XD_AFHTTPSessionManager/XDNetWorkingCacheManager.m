//
//  XDNetWorkingCacheManager.m
//  XDAFHTTPSessionManager
//
//  Created by 窦心东 on 2016/12/2.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import "XDNetWorkingCacheManager.h"

@implementation XDNetWorkingCacheManager
static NSString *const NetworkResponseCache = @"NetworkResponseCache";
static YYCache *_dataCache;


+ (void)initialize
{
    _dataCache = [YYCache cacheWithName:NetworkResponseCache];
}

+ (void)saveResponseCache:(id)responseCache forKey:(NSString *)key
{
    //异步缓存,不会阻塞主线程
    [_dataCache setObject:responseCache forKey:key withBlock:nil];
}

+ (id)getResponseCacheForKey:(NSString *)key
{
    return [_dataCache objectForKey:key];
}
/*==========================================*/

//-(NSString*)DownloadTextFile:(NSString*)fileUrl   fileName:(NSString*)_fileName
//{
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
//    NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
//    NSString *sandboxPath = NSHomeDirectory();
//    NSString *documentPath = [sandboxPath  stringByAppendingPathComponent:@"TestDownImgZip.app"];//将Documents添加到sandbox路径上//TestDownImgZip.app
//    NSString *FileName=[documentPath stringByAppendingPathComponent:_fileName];//fileName就是保存文件的文件名
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    // Copy the database sql file from the resourcepath to the documentpath
//    if ([fileManager fileExistsAtPath:FileName])
//    {
//        return FileName;
//    }else
//    {
//        NSURL *url = [NSURL URLWithString:fileUrl];
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        [data writeToFile:FileName atomically:YES];//将NSData类型对象data写入文件，文件名为FileName
//    }
//    return FileName;
//}
//
//-(NSString*)DownloadTextFile:(NSString*)fileUrl   fileName:(NSString*)_fileName
//{
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
//    NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
//    NSString *sandboxPath = NSHomeDirectory();
//    NSString *documentPath = [sandboxPath  stringByAppendingPathComponent:@"TestDownImgZip.app"];//将Documents添加到sandbox路径上//TestDownImgZip.app
//    NSString *FileName=[documentPath stringByAppendingPathComponent:_fileName];//fileName就是保存文件的文件名
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    // Copy the database sql file from the resourcepath to the documentpath
//    if ([fileManager fileExistsAtPath:FileName])
//    {
//        return FileName;
//    }else
//    {
//        NSURL *url = [NSURL URLWithString:fileUrl];
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        [data writeToFile:FileName atomically:YES];//将NSData类型对象data写入文件，文件名为FileName
//    }
//    return FileName;
//}
//
//
//
//
//
//
//
////2.解压zip包
//
//- (void)OpenZip:(NSString*)zipPath  unzipto:(NSString*)_unzipto
//{
//    ZipArchive* zip = [[ZipArchive alloc] init];
//    if( [zip UnzipOpenFile:zipPath] )
//    {
//        BOOL ret = [zip UnzipFileTo:_unzipto overWrite:YES];
//        if( NO==ret )
//        {
//            NSLog(@"error");
//        }
//        [zip UnzipCloseFile];
//    }
//    [zip release];
//    
//}
//
//- (void)OpenZip:(NSString*)zipPath  unzipto:(NSString*)_unzipto
//{
//    ZipArchive* zip = [[ZipArchive alloc] init];
//    if( [zip UnzipOpenFile:zipPath] )
//    {
//        BOOL ret = [zip UnzipFileTo:_unzipto overWrite:YES];
//        if( NO==ret )
//        {
//            NSLog(@"error");
//        }
//        [zip UnzipCloseFile];
//    }
//    [zip release];
//    
//}
//
//
//
////3.调去函数
//
//- (IBAction)ShowImg:(id)sender {
//    NSString *filePath = [self DownloadTextFile:@"http://www.xtox.net/img.zip" fileName:@"img.zip"];
//    NSLog(filePath);
//    
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
//    NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
//    NSString *sandboxPath = NSHomeDirectory();
//    NSString *documentPath = [sandboxPath  stringByAppendingPathComponent:@"TestDownImgZip.app"];//将Documents添加到sandbox路径上//TestDownImgZip.app
//    
//    [self OpenZip:filePath unzipto:documentPath];
//    self.imgView.image = [UIImage imageNamed:@"img/1.png"];
//}
//
//- (IBAction)ShowImg:(id)sender {
//    NSString *filePath = [self DownloadTextFile:@"http://www.xtox.net/img.zip" fileName:@"img.zip"];
//    NSLog(filePath);
//    
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
//    NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
//    NSString *sandboxPath = NSHomeDirectory();
//    NSString *documentPath = [sandboxPath  stringByAppendingPathComponent:@"TestDownImgZip.app"];//将Documents添加到sandbox路径上//TestDownImgZip.app
//    
//    [self OpenZip:filePath unzipto:documentPath];
//    self.imgView.image = [UIImage imageNamed:@"img/1.png"];
//}
//
@end
