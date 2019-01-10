//
//  GizSiriNetworkManager.m
//  Gizwits
//
//  Created by Minus🍀 on 2018/10/16.
//  Copyright © 2018 Gizwits. All rights reserved.
//

#import "GizSiriNetworkManager.h"

@implementation GizSiriNetworkManager

+ (void)excuteManualScene:(NSString *)urlString headers:(NSDictionary *)headers completion:(void (^)(NSError * _Nonnull))completionHandler {
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    for (NSString *key in headers) {
        [request addValue:headers[key] forHTTPHeaderField:key];
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error == nil) {
            NSLog(@"excute manual scene Succeeded: HTTP %ld", ((NSHTTPURLResponse*)response).statusCode);
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
            
            NSLog(@"    response data: %@", dict);
            
            NSInteger code = 200;
            NSString *message = @"Success.";
            
            if (dict) {
                code = [dict[@"code"] integerValue];
                message = dict[@"message"];
            }
            
            error = [NSError errorWithDomain:@"com.gizwits.sirishortcut" code:code userInfo:@{NSLocalizedDescriptionKey: message}];
        } else {
            NSLog(@"excute manual scene Failed: %@", [error localizedDescription]);
        }
        
        completionHandler(error);
    }];
    
    [task resume];
}

@end
