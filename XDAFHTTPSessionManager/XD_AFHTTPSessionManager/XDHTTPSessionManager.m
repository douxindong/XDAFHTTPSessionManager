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
static NSMutableArray *tasks;
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
        [self startMonitoringNetwork];
        
        
    });
    return XDSessionManager;
}
#pragma mark - 设置AFHTTPSessionManager相关属性

+ (AFHTTPSessionManager *)createAFHTTPSessionManager
{
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
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
        
        
        
        /*! 打开状态栏的等待菊花 */
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        /*! 设置相应的缓存策略：此处选择不用加载也可以使用自动缓存【注：只有get方法才能用此缓存策略，NSURLRequestReturnCacheDataDontLoad】 */
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        /*! 设置返回数据类型为 json, 分别设置请求以及相应的序列化器 */
        /*!
         根据服务器的设定不同还可以设置：
         json：[AFJSONResponseSerializer serializer](常用)
         http：[AFHTTPResponseSerializer serializer]
         */
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        /*! 这里是去掉了键值对里空对象的键值 */
        response.removesKeysWithNullValues = YES;
        manager.responseSerializer = response;
        
        /* 设置请求服务器数类型式为 json */
        /*! 根据服务器的设定不同还可以设置 [AFJSONRequestSerializer serializer](常用) */
        AFJSONRequestSerializer *request = [AFJSONRequestSerializer serializer];
        manager.requestSerializer = request;
        
        /*! 设置apikey ------类似于自己应用中的tokken---此处仅仅作为测试使用*/
        //        [manager.requestSerializer setValue:apikey forHTTPHeaderField:@"apikey"];
        
        /*! 复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        //        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        /*! 设置响应数据的基本类型 */
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/xml",@"text/plain", @"application/javascript", @"image/*", nil];
        
        /*! https 参数配置 */
        /*!
         采用默认的defaultPolicy就可以了. AFN默认的securityPolicy就是它, 不必另写代码. AFSecurityPolicy类中会调用苹果security.framework的机制去自行验证本次请求服务端放回的证书是否是经过正规签名.
         */
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        manager.securityPolicy = securityPolicy;
        
        /*! 自定义的CA证书配置如下： */
        /*! 自定义security policy, 先前确保你的自定义CA证书已放入工程Bundle */
        /*!
         https://api.github.com网址的证书实际上是正规CADigiCert签发的, 这里把Charles的CA根证书导入系统并设为信任后, 把Charles设为该网址的SSL Proxy (相当于"中间人"), 这样通过代理访问服务器返回将是由Charles伪CA签发的证书.
         */
        //        NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        //        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
        //        policy.allowInvalidCertificates = YES;
        //        manager.securityPolicy = policy;
        
        /*! 如果服务端使用的是正规CA签发的证书, 那么以下几行就可去掉: */
        //        NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        //        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
        //        policy.allowInvalidCertificates = YES;
        //        manager.securityPolicy = policy;
    });
    return manager;
}
#pragma mark - 开始监听网络
+ (void)startMonitoringNetwork
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
+ (void)networkStatusWithBlock:(NetworkStatus)status
{
    _status = status;
}

#pragma mark - GET请求无缓存
+ (XDURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
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
+ (XDURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters responseCache:(HttpRequestCache)responseCache progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
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
+ (XDURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
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
+ (XDURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters responseCache:(HttpRequestCache)responseCache progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
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
#pragma mark - 网络请求的类方法 --- get / post / put / delete
/*!
 *  网络请求的实例方法
 *
 *  @param type         get / post / put / delete
 *  @param urlString    请求的地址
 *  @param parameters    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 *  @param progress 进度
 */
+ (XDURLSessionTask *)ba_requestWithType:(XDHttpRequestType)type UrlString:(NSString *)urlString Parameters:(NSDictionary *)parameters progress:(HttpProgress)progress SuccessBlock:(HttpRequestSuccess)successBlock FailureBlock:(HttpRequestFailed)failureBlock
{
    if (urlString == nil)
    {
        return nil;
    }
    
    XDWeak;
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    
    NSString *requestType;
    switch (type) {
        case 0:
            requestType = @"Get";
            break;
        case 1:
            requestType = @"Post";
            break;
        case 2:
            requestType = @"Put";
            break;
        case 3:
            requestType = @"Delete";
            break;
            
        default:
            break;
    }
    
    NSLog(@"******************** 请求参数 ***************************");
    NSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",[self createAFHTTPSessionManager].requestSerializer.HTTPRequestHeaders, requestType, URLString, parameters);
    NSLog(@"********************************************************");
    
    XDURLSessionTask *sessionTask = nil;
    
    if (type == XDHttpRequestTypeGet)
    {
        
        
        sessionTask = [[self createAFHTTPSessionManager] GET:URLString parameters:parameters  progress:^(NSProgress * _Nonnull downloadProgress) {
            progress?progress(downloadProgress):nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            /****************************************************/
            // 如果请求成功 , 回调请求到的数据 , 同时 在这里 做本地缓存
            NSString *path = [NSString stringWithFormat:@"%ld.plist", [URLString hash]];
            // 存储的沙盒路径
            NSString *path_doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSLog(@"如果请求成功 , 回调请求到的数据 , 同时 在这里 做本地缓存,存储的沙盒路径:%@",path_doc);
            // 归档
            [NSKeyedArchiver archiveRootObject:responseObject toFile:[path_doc stringByAppendingPathComponent:path]];
            
            successBlock?successBlock(responseObject):nil;
            
            [[weakSelf tasks] removeObject:sessionTask];
            
            //[self writeInfoWithDict:(NSDictionary *)responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failureBlock?failureBlock(error):nil;
            NSLog(@"错误信息：%@",error);
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
        
    }
    else if (type == XDHttpRequestTypePost)
    {
        sessionTask = [[self createAFHTTPSessionManager] POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
             progress?progress(uploadProgress):nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            /* ************************************************** */
            // 如果请求成功 , 回调请求到的数据 , 同时 在这里 做本地缓存
            NSString *path = [NSString stringWithFormat:@"%ld.plist", [URLString hash]];
            // 存储的沙盒路径
            NSString *path_doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSLog(@"如果请求成功 , 回调请求到的数据 , 同时 在这里 做本地缓存,存储的沙盒路径:%@",path_doc);
            // 归档
            [NSKeyedArchiver archiveRootObject:responseObject toFile:[path_doc stringByAppendingPathComponent:path]];
            
            successBlock?successBlock(responseObject):nil;
            
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failureBlock?failureBlock(error):nil;
                NSLog(@"错误信息：%@",error);
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
    }
    else if (type == XDHttpRequestTypePut)
    {
        sessionTask = [[self createAFHTTPSessionManager] PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (successBlock)
            {
                successBlock(responseObject);
            }
            
            [[weakSelf tasks] removeObject:sessionTask];
            
            //[self writeInfoWithDict:(NSDictionary *)responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
    }
    else if (type == XDHttpRequestTypeDelete)
    {
        sessionTask = [[self createAFHTTPSessionManager] DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (successBlock)
            {
                successBlock(responseObject);
            }
            
            [[weakSelf tasks] removeObject:sessionTask];
            
//            [self writeInfoWithDict:(NSDictionary *)responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
    }
    
    if (sessionTask)
    {
        [[weakSelf tasks] addObject:sessionTask];
    }
    
    return sessionTask;
}


#pragma mark - 上传图片文件
+ (XDURLSessionTask *)uploadWithURL:(NSString *)URL parameters:(NSDictionary *)parameters images:(NSArray<UIImage *> *)images name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(HttpProgress)progress success:(HttpRequestSuccess)success failure:(HttpRequestFailed)failure
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
+ (XDURLSessionTask *)downloadWithURL:(NSString *)URL fileDir:(NSString *)fileDir progress:(HttpProgress)progress success:(void(^)(NSString *))success failure:(HttpRequestFailed)failure
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
        
        XDLog(@"下载文件所在文件夹downloadDir = %@",downloadDir);
        
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
+ (XDURLSessionTask *)requestWithURLString:(NSString *)URLString
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



#pragma mark - url 中文格式化
+ (NSString *)strUTF8Encoding:(NSString *)str
{
    /*! ios9适配的话 打开第一个 */
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0)
    {
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    }
    else
    {
        return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}
+ (NSMutableArray *)tasks
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"创建任务数组");
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

@end
