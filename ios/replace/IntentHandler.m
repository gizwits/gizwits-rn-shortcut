//
//  IntentHandler.m
//  GizManualSceneIntent
//
//  Created by Minus🍀 on 2018/10/17.
//

#import "IntentHandler.h"
#import "GizManualSceneIntent.h"

#import "GizSiriNetworkManager.h"
#import "GizSiriAppGroupManager.h"

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

@interface IntentHandler () <GizManualSceneIntentHandling>

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    
    return self;
}

#pragma mark - GizManualSceneIntentHandling

- (void)handleGizManualScene:(GizManualSceneIntent *)intent completion:(void (^)(GizManualSceneIntentResponse * _Nonnull))completion {
    
    [[GizSiriAppGroupManager defaultManager] setupWithGroupId:<#Your Group ID#>];
    NSString *token = [[GizSiriAppGroupManager defaultManager] getToken];

    NSDictionary *headers = @{@"Authorization": token,
                              @"Version": intent.version
                              };
    
    [GizSiriNetworkManager excuteManualScene:intent.url headers:headers completion:^(NSError * _Nonnull error) {
        
        GizManualSceneIntentResponse *intentResponse;
        
        if (error.code != 200) {
            intentResponse = [GizManualSceneIntentResponse failureIntentResponseWithName:intent.name];
        } else {
            intentResponse = [GizManualSceneIntentResponse successIntentResponseWithName:intent.name];
        }
        
        completion(intentResponse);
    }];
}

@end
