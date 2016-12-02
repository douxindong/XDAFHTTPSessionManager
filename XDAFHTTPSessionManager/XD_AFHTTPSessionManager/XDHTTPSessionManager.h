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
