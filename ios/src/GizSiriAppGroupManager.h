//
//  GizSiriAppGroupManager.h
//  Gizwits
//
//  Created by Minus🍀 on 2018/10/29.
//  Copyright © 2018 Gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GizSiriAppGroupManager : NSObject

+ (instancetype)defaultManager;

- (void)setupWithGroupId:(NSString *)groupId;

- (void)archiveToken:(nullable NSString *)token;
- (nullable NSString *)getToken;

@end

NS_ASSUME_NONNULL_END
