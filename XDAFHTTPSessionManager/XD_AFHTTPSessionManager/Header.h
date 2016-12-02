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
