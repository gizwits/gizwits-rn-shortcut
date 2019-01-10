//
//  GizSiriAppGroupManager.m
//  Gizwits
//
//  Created by Minus🍀 on 2018/10/29.
//  Copyright © 2018 Gizwits. All rights reserved.
//

#import "GizSiriAppGroupManager.h"


NSString * const kUserToken = @"kSiriAppGroupUserToken";


@interface GizSiriAppGroupManager ()

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation GizSiriAppGroupManager

+ (instancetype)defaultManager {
    static GizSiriAppGroupManager *_defaultManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[GizSiriAppGroupManager alloc] init];
    });
    
    return _defaultManager;
}

- (void)setupWithGroupId:(NSString *)groupId {

    NSAssert([groupId length] > 0, @"App Group ID 不能为空...");

    self.groupId = groupId;
    self.userDefaults = [[NSUserDefaults alloc] initWithSuiteName:groupId];
}

- (void)archiveToken:(NSString *)token {
    
    if (!self.userDefaults) {
        NSLog(@"请先调用初始化方法 setupWithGroupId: ");
        return;
    }
    
    [self.userDefaults setObject:token forKey:kUserToken];
    [self.userDefaults synchronize];
}

- (NSString *)getToken {
    return [self.userDefaults stringForKey:kUserToken];
}

@end
