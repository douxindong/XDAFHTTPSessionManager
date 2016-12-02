# XDAFHTTPSessionManager
对AFHTTPSessionManager的二次封装，紧贴AFNetworking的思想，先判断在请求，严谨全面，基本满足需求
```objc
//
//  XDHTTPSessionManager.h
//  XDAFHTTPSessionManager
//
//  Created by 窦心东 on 2016/12/2.
//  Copyright © 2016年 窦心东. All rights reserved.
//  iOS - HTTPS
//  http://www.jianshu.com/p/4b5d2d47833d
//  QQ网络请求讨论群【iOS开发帝国Https群】：581443677
//  http://www.cnblogs.com/QianChia/p/5768428.html#autoid-7-0-0

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger,RequestMethod) {
    POST = 0,
    GET,
    PUT,
    PATCH,
    DELETE,
    HEAD
};
typedef NS_ENUM(NSInteger, AFNetworkErrorType) {
    AFNetworkErrorType_TimedOut = NSURLErrorTimedOut,                //-1001 请求超时
    AFNetworkErrorType_UnURL = NSURLErrorUnsupportedURL,             //-1002 不支持的URL
    AFNetworkErrorType_NoNetWork = NSURLErrorNotConnectedToInternet, //-1009 断网
    AFNetworkErrorType_404Failed = NSURLErrorBadServerResponse,      //-1011 404 错误
    
    AFNetworkErrorType_3840Failed = 3840,                        //3840 请求或者返回不是纯json格式
};
typedef NS_ENUM(NSUInteger, XDNetworkStatus) {
    /** 未知网络*/
    XDNetworkStatusUnknown,
    /** 无网络*/
    XDNetworkStatusNotReachable,
    /** 手机网络*/
    XDNetworkStatusReachableViaWWAN,
    /** WIFI网络*/
    XDNetworkStatusReachableViaWiFi
};

/** 请求成功的Block */
typedef void(^HttpRequestSuccess)(id responseObject);

/** 请求失败的Block */
typedef void(^HttpRequestFailed)(NSError *error);

/** 缓存的Block */
typedef void(^HttpRequestCache)(id responseCache);

/** 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小*/
typedef void (^HttpProgress)(NSProgress *progress);

/** 网络状态的Block*/
typedef void(^NetworkStatus)(XDNetworkStatus status);

/** 请求任务 */
typedef NSURLSessionTask XDURLSessionTask;

#pragma mark - 网络数据请求类

@interface XDHTTPSessionManager : NSObject

/**
 *  声明单例方法
 */
+(instancetype)shareManager;
/**
 *  开始监听网络状态
 */
- (void)startMonitoringNetwork;

/**
 *  实时获取网络状态回调
 */
- (void)networkStatusWithBlock:(NetworkStatus)status;

/**
 *  GET请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param progress   进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancle方法
 */
- (XDURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure;

/**
 *  GET请求,自动缓存
 *
 *  @param URL           请求地址
 *  @param parameters    请求参数
 *  @param responseCache 缓存数据的回调
 *  @param progress      进度信息
 *  @param success       请求成功的回调
 *  @param failure       请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancle方法
 */
- (XDURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters responseCache:(HttpRequestCache)responseCache progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure;

/**
 *  POST请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param progress   进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancle方法
 */
- (XDURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure;

/**
 *  POST请求,自动缓存
 *
 *  @param URL           请求地址
 *  @param parameters    请求参数
 *  @param responseCache 缓存数据的回调
 *  @param progress      进度信息
 *  @param success       请求成功的回调
 *  @param failure       请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancle方法
 */
- (XDURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters responseCache:(HttpRequestCache)responseCache progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure;

/**
 *  上传图片文件
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param images     图片数组
 *  @param name       文件对应服务器上的字段
 *  @param fileName   文件名
 *  @param mimeType   图片文件的类型,例:png、jpeg(默认类型)....
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancle方法
 */
- (XDURLSessionTask *)uploadWithURL:(NSString *)URL parameters:(NSDictionary *)parameters images:(NSArray<UIImage *> *)images name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure;

/**
 *  下载文件
 *
 *  @param URL      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
- (XDURLSessionTask *)downloadWithURL:(NSString *)URL fileDir:(NSString *)fileDir progress:(HttpProgress)progress success:(void(^)(NSString *filePath))success failure:(HttpRequestFailed)failure;



@end

```
```objc
//
//  XDHTTPSessionManager.m
//  XDAFHTTPSessionManager
//
//  Created by 窦心东 on 2016/12/2.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import "XDHTTPSessionManager.h"
#import "XDNetWorkingCacheManager.h"
#ifdef DEBUG
#define XDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define XDLog(...)
#endif
static XDHTTPSessionManager *XDSessionManager= nil;
static NetworkStatus _status;
@implementation XDHTTPSessionManager

#pragma mark - 实现声明单例方法 GCD
+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        XDSessionManager = [[XDHTTPSessionManager alloc]init];
    });
    return XDSessionManager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        XDSessionManager = [super allocWithZone:zone];
    });
    return XDSessionManager;
}
+ (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        XDSessionManager = [super init];
        [XDSessionManager startMonitoringNetwork];
    });
    return XDSessionManager;
}

#pragma mark - 开始监听网络
- (void)startMonitoringNetwork
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                _status(XDNetworkStatusUnknown);
                XDLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                _status(XDNetworkStatusNotReachable);
                XDLog(@"无网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                _status(XDNetworkStatusReachableViaWWAN);
                XDLog(@"手机自带网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                _status(XDNetworkStatusReachableViaWiFi);
                XDLog(@"WIFI");
                break;
        }
    }];
    [manager startMonitoring];
    
}
- (void)networkStatusWithBlock:(NetworkStatus)status
{
    _status = status;
}

#pragma mark - GET请求无缓存
- (XDURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    return [manager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        success?success(responseObject):nil;
        XDLog(@"responseObject = %@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        failure ? failure(error) : nil;
        XDLog(@"error = %@",error);
    }];
}

#pragma mark - GET请求自动缓存
- (XDURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters responseCache:(HttpRequestCache)responseCache progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //读取缓存
    responseCache?responseCache([XDNetWorkingCacheManager getResponseCacheForKey:URL]):nil;
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    return [manager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        success?success(responseObject):nil;
        //对数据进行异步缓存
        [XDNetWorkingCacheManager saveResponseCache:responseObject forKey:URL];
        XDLog(@"responseObject = %@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        failure ? failure(error) : nil;
        XDLog(@"error = %@",error);
        
    }];
}

#pragma mark - POST请求无缓存
- (XDURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    return [manager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        success?success(responseObject):nil;
        XDLog(@"responseObject = %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        failure ? failure(error) : nil;
        XDLog(@"error = %@",error);
    }];
    
}

#pragma mark - POST请求自动缓存
- (XDURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters responseCache:(HttpRequestCache)responseCache progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //读取缓存
    responseCache?responseCache([XDNetWorkingCacheManager getResponseCacheForKey:URL]):nil;
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    return [manager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        success?success(responseObject): nil;
        //对数据进行异步缓存
        [XDNetWorkingCacheManager saveResponseCache:responseObject forKey:URL];
        XDLog(@"responseObject = %@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        failure ? failure(error) : nil;
        XDLog(@"error = %@",error);
    }];
    
}

#pragma mark - 上传图片文件
- (XDURLSessionTask *)uploadWithURL:(NSString *)URL parameters:(NSDictionary *)parameters images:(NSArray<UIImage *> *)images name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    return [manager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //压缩-添加-上传图片
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *imageData = [NSData data];
            if (UIImagePNGRepresentation(image) == nil) {
                imageData = UIImageJPEGRepresentation(image, 1);
            } else {
                imageData = UIImagePNGRepresentation(image);
            }
            
            [formData appendPartWithFileData:imageData name:name fileName:[NSString stringWithFormat:@"%@%ld.%@",fileName,idx,mimeType?mimeType:@"jpeg"] mimeType:[NSString stringWithFormat:@"image/%@",mimeType?mimeType:@"jpeg"]];
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        progress ? progress(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        success?success(responseObject): nil;
        XDLog(@"responseObject = %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        failure ? failure(error) : nil;
        XDLog(@"error = %@",error);
    }];
}

#pragma mark - 下载文件
- (XDURLSessionTask *)downloadWithURL:(NSString *)URL fileDir:(NSString *)fileDir progress:(HttpProgress)progress success:(void(^)(NSString *))success failure:(HttpRequestFailed)failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        progress ? progress(downloadProgress) : nil;
        XDLog(@"下载进度:%.2f%%",100.0*downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        
        XDLog(@"downloadDir = %@",downloadDir);
        
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
        failure && error ? failure(error) : nil;
        
    }];
    
    //开始下载
    [downloadTask resume];
    
    return downloadTask;
    
}
#pragma mark -- POST/GET网络请求 --
- (XDURLSessionTask *)requestWithURLString:(NSString *)URLString
                                parameters:(id)parameters
                             requestMethod:(RequestMethod)method
                                   success:(void (^)(id))success
                                   failure:(void (^)(NSError *))failure {
    
    
    switch (method) {
        case GET:
        {
            AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
            return [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
        case POST:
        {
            AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
            return [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
        case PUT:
        {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:
                                                                                URLString]];
            request.HTTPMethod = @"PUT";
            
            //            [request setValue:[@"admin:adminpasswd" q_basic64AuthEncode] forHTTPHeaderField:@"Authorization"];
            
            NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"HQ_0005.jpg" withExtension:nil];
            
            AFURLSessionManager *manager = [[AFURLSessionManager alloc]
                                            initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSURLSessionUploadTask * UploadTask = [manager uploadTaskWithRequest:request fromFile:fileURL progress:^(NSProgress * _Nonnull uploadProgress) {
                
                //                float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
                //                dispatch_async(dispatch_get_main_queue(), ^{
                //                    [self.progressBtn q_setButtonWithProgress:progress lineWidth:10 lineColor:nil backgroundColor:[UIColor yellowColor]];
                //                });
                
            } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                if (error == nil && responseObject != nil) {
                    NSLog(@"success: %@ --- %@", responseObject, [responseObject class]);
                } else {
                    NSLog(@"failure: %@", error);
                }
            }];
            [UploadTask resume];
            return UploadTask;
            
        }
        case PATCH:
        {
            return nil;
        }
        case DELETE:
        {
            return nil;
        }
        case HEAD:
        {
            AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
            return [manager HEAD:URLString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task) {
                
                NSLog(@"success: %@ --- %lld", task.response.suggestedFilename, task.response.expectedContentLength);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                NSLog(@"failure: %@", error);
            }];
        }
            break;
    }
}


#pragma mark - 设置AFHTTPSessionManager相关属性

- (AFHTTPSessionManager *)createAFHTTPSessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求参数的类型:HTTP (AFJSONRequestSerializer,AFHTTPRequestSerializer)
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //设置请求的超时时间
    manager.requestSerializer.timeoutInterval = 30.f;
    //设置服务器返回结果的类型:JSON (AFJSONResponseSerializer,AFHTTPResponseSerializer)
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    /**
     *  请求队列的最大并发数
     */
//    manager.operationQueue.maxConcurrentOperationCount = 5;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    return manager;
}

@end

```
```objc
//
//  XDNetWorkingCacheManager.h
//  XDAFHTTPSessionManager
//
//  Created by 窦心东 on 2016/12/2.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark - 网络数据缓存类
@interface XDNetWorkingCacheManager : NSObject

/**
 *  缓存网络数据
 *
 *  @param responseCache 服务器返回的数据
 *  @param key           缓存数据对应的key值,推荐填入请求的URL
 */
+ (void)saveResponseCache:(id)responseCache forKey:(NSString *)key;

/**
 *  取出缓存的数据
 *
 *  @param key 根据存入时候填入的key值来取出对应的数据
 *
 *  @return 缓存的数据
 */
+ (id)getResponseCacheForKey:(NSString *)key;
@end

```
```objc
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

```
```objc
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

```
```objc
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

```

```objc
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

```
```objc
//
//  Header.h
//  XDAFHTTPSessionManager
//
//  Created by 窦心东 on 2016/12/2.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#ifndef Header_h
#define Header_h


#ifdef __OBJC__
        #import <UIKit/UIKit.h>
        #import <Foundation/Foundation.h>


        #import "AFNetworking.h"
        #import "UIKit+AFNetworking.h"
        #import <YYModel/YYModel.h>
        #import <YYCache.h>
        #import "QExtension.h"
        #import "Singleton.h"


#ifdef DEBUG // 开发阶段-DEBUG阶段:使用Log
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else // 发布阶段-上线阶段:移除Log
#define NSLog(FORMAT, ...) nil
#endif
#endif


#endif /* Header_h */

```
```objc
//单例宏
// .h
#define singleton_interface(class) + (instancetype)shared##class;

// .m
#define singleton_implementation(class) \
static class *_instance; \
\
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance = [super allocWithZone:zone]; \
    }); \
\
    return _instance; \
} \
\
+ (instancetype)shared##class \
{ \
    if (_instance == nil) { \
        _instance = [[class alloc] init]; \
    } \
\
    return _instance; \
}


```
```objc
```
