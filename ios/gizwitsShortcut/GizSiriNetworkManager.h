//
//  GizSiriNetworkManager.h
//  Gizwits
//
//  Created by Minus🍀 on 2018/10/16.
//  Copyright © 2018 Gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GizSiriNetworkManager : NSObject

+ (void)excuteManualScene:(NSString *)urlString headers:(NSDictionary *)headers completion:(void (^)(NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
