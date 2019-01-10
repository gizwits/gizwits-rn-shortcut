#import "RNGizwitsShortcut.h"
#import "GizSiriAppGroupManager.h"

#import "GizManualSceneIntent.h"
#import <Intents/Intents.h>
#import <IntentsUI/IntentsUI.h>


typedef NS_ENUM(NSInteger, GizSiriAuthorizationStatus) {
  GizSiriAuthorizationStatusNotDetermined = 0,
  GizSiriAuthorizationStatusRestricted,
  GizSiriAuthorizationStatusDenied,
  GizSiriAuthorizationStatusAuthorized,
  GizSiriAuthorizationStatusUnknown,
};


GizSiriAuthorizationStatus SiriToGiz(INSiriAuthorizationStatus status) {
  GizSiriAuthorizationStatus gizStatus = GizSiriAuthorizationStatusUnknown;
  
  switch (status) {
    case INSiriAuthorizationStatusNotDetermined:
      gizStatus = GizSiriAuthorizationStatusNotDetermined;
      break;
      
    case INSiriAuthorizationStatusRestricted:
      gizStatus = GizSiriAuthorizationStatusRestricted;
      break;
      
    case INSiriAuthorizationStatusDenied:
      gizStatus = GizSiriAuthorizationStatusDenied;
      break;
      
    case INSiriAuthorizationStatusAuthorized:
      gizStatus = GizSiriAuthorizationStatusAuthorized;
      break;
  }
  
  return gizStatus;
}
@interface RNGizwitsShortcut () <INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate>
@property (nonatomic, strong) RCTResponseSenderBlock addCallbackResult;
@property (nonatomic, strong) RCTResponseSenderBlock editCallbackResult;
@end

@implementation RNGizwitsShortcut

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents{
  return @[];
}

- (UIViewController*) getRootVC {
  UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  while (root.presentedViewController != nil) {
    root = root.presentedViewController;
  }
  return root;
}

- (instancetype)init{
  self = [super init];
  if (self) {
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    NSDictionary *params = dict[@"GizSiriShortcut"];
    
    NSAssert(params, @"缺少初始化 App Group 所需参数...");
    
    [[GizSiriAppGroupManager defaultManager] setupWithGroupId:params[@"GroupId"]];
  }
  return self;
}

RCT_EXPORT_METHOD(addSiriShortcut:(NSDictionary *)info result:(RCTResponseSenderBlock)result) {
  if (@available(iOS 12.0, *)) {
    INSiriAuthorizationStatus status = [INPreferences siriAuthorizationStatus];
    
    if (status == INSiriAuthorizationStatusDenied || status == INSiriAuthorizationStatusRestricted) {
      result(@[@"Can't access Siri!"]);
      return;
    }
    
    if (status == INSiriAuthorizationStatusNotDetermined) {
      [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
        if (status == INSiriAuthorizationStatusAuthorized) {
          [self addSiriShortcut:info result:result];
        } else {
          result(@[@"Can't access Siri!"]);
        }
      }];
      return;
    }
    
    NSDictionary *params = info;
    
    GizManualSceneIntent *intent = [[GizManualSceneIntent alloc] init];
    intent.url = params[@"url"];
    intent.suggestedInvocationPhrase = params[@"suggestedInvocationPhrase"];
    intent.token = params[@"token"];
    intent.version = params[@"version"];
    intent.name = params[@"sceneName"] ?: @"回家模式";
    intent.sceneId = params[@"sceneId"] ?: @"";
    
    NSString *imagePath = [@"SceneIcon.bundle" stringByAppendingPathComponent:params[@"icon"]];
    
    intent.image = imagePath;
    
    UIImage *image = [UIImage imageNamed:imagePath];
    NSData *imageData = UIImagePNGRepresentation(image);
    INImage *nameImage = [INImage imageWithImageData:imageData];
    
    [intent setImage:nameImage forParameterNamed:@"image"];
    
    INShortcut *shortcut = [[INShortcut alloc] initWithIntent:intent];
    
    self.addCallbackResult = result;
    
    INUIAddVoiceShortcutViewController *viewController = [[INUIAddVoiceShortcutViewController alloc] initWithShortcut:shortcut];
    viewController.delegate = self;
    [[self getRootVC] presentViewController:viewController animated:YES completion:nil];
  } else {
    result(@[@"Not supported!"]);
  }
}

RCT_EXPORT_METHOD(editSiriShortcut:(NSDictionary *)info result:(RCTResponseSenderBlock)result) {
  if (@available(iOS 12.0, *)) {
    NSDictionary *params = info;
    
    NSString *uuidString = params[@"UUID"];
    
    if (!uuidString || uuidString.length <= 0) {
      result(@[@"Invalid parameters!"]);
      return;
    }
    
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    
    [[INVoiceShortcutCenter sharedCenter] getVoiceShortcutWithIdentifier:UUID completion:^(INVoiceShortcut * _Nullable voiceShortcut, NSError * _Nullable error) {
      
      if (error) {
        result(@[error.localizedDescription]);
        return;
      }
      
      self.editCallbackResult = result;
      
      INUIEditVoiceShortcutViewController *viewController = [[INUIEditVoiceShortcutViewController alloc] initWithVoiceShortcut:voiceShortcut];
      viewController.delegate = self;
      [[self getRootVC] presentViewController:viewController animated:YES completion:nil];
    }];
    
    
  } else {
    result(@[@"Not supported!"]);
  }
}

RCT_EXPORT_METHOD(getSiriShortcut:(NSString *)sceneId result:(RCTResponseSenderBlock)result) {
  if (@available(iOS 12.0, *)) {
    
    NSLog(@"getSiriShortcut sceneId => %@", sceneId);
    
    [[INVoiceShortcutCenter sharedCenter] getAllVoiceShortcutsWithCompletion:^(NSArray<INVoiceShortcut *> * _Nullable voiceShortcuts, NSError * _Nullable error) {
      
      if (error) {
        NSLog(@"getSiriShortcut error => %@", error);
        result(@[error.localizedDescription]);
        return;
      }
      
      NSDictionary *targetScene = nil;
      
      for (INVoiceShortcut *shortcut in voiceShortcuts) {
        NSDictionary<NSString *, NSString *> *dict = [self getSiriShortcutInfo:shortcut];
        
        if ([dict[@"sceneId"] isEqualToString:sceneId]) {
          targetScene = dict;
          break;
        }
      }
      
      if (!targetScene) {
        targetScene = @{};
      }
      
      NSLog(@"getSiriShortcut targetScene => %@", targetScene);
      
      result(@[[NSNull null], targetScene]);
    }];
  } else {
    result(@[@"Not supported!"]);
  }
}

RCT_EXPORT_METHOD(getAllSiriShortcut:(RCTResponseSenderBlock)result){
  if (@available(iOS 12.0, *)) {
    [[INVoiceShortcutCenter sharedCenter] getAllVoiceShortcutsWithCompletion:^(NSArray<INVoiceShortcut *> * _Nullable voiceShortcuts, NSError * _Nullable error) {
      
      if (error) {
        NSLog(@"getAllSiriShortcut error => %@", error);
        result(@[error.localizedDescription]);
        return;
      }
      
      NSMutableArray<NSDictionary *> *sceneArray = [[NSMutableArray alloc] init];;
      
      for (INVoiceShortcut *shortcut in voiceShortcuts) {
        NSDictionary<NSString *, NSString *> *dict = [self getSiriShortcutInfo:shortcut];
        
        [sceneArray addObject:dict];
      }
      
      NSLog(@"getAllSiriShortcut sceneArray => %@", sceneArray);
      result(@[[NSNull null], sceneArray]);
    }];
  } else {
    result(@[@"Not supported!"]);
  }
}

- (NSDictionary<NSString *, NSString *> *)getSiriShortcutInfo:(INVoiceShortcut *)voiceShortcut API_AVAILABLE(ios(12.0)) {
  
  NSMutableDictionary<NSString *, NSString *> *dict = [[NSMutableDictionary alloc] init];
  
  [dict setObject:voiceShortcut.identifier.UUIDString forKey:@"UUID"];
  
  if ([voiceShortcut.shortcut.intent isKindOfClass:[GizManualSceneIntent class]]) {
    GizManualSceneIntent *manualSceneIntent = (GizManualSceneIntent *)voiceShortcut.shortcut.intent;
    [dict setObject:manualSceneIntent.sceneId?:@"" forKey:@"sceneId"];
  }
  
  return dict;
}

RCT_EXPORT_METHOD(isSiriShortcutEnabled:(RCTResponseSenderBlock)result) {
  BOOL flag = NO;
  
  if (@available(iOS 12.0, *)) {
    flag = YES;
  }
  
  result(@[[NSNull null], @(flag)]);
}

RCT_EXPORT_METHOD(siriAuthorizationStatus:(RCTResponseSenderBlock)result){
  
  if (@available(iOS 10.0, *)) {
    INSiriAuthorizationStatus status = [INPreferences siriAuthorizationStatus];
    [self sendAuthorizationStatus:SiriToGiz(status) withCallbackResult:result];
  } else {
    [self sendNotSupport:@"siri" withCallbackResult:result];
  }
}

RCT_EXPORT_METHOD(requestSiriAuthorizationStatus:(RCTResponseSenderBlock)result){
  
  if (@available(iOS 10.0, *)) {
    [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
      [self sendAuthorizationStatus:SiriToGiz(status) withCallbackResult:result];
    }];
  } else {
    [self sendNotSupport:@"siri" withCallbackResult:result];
  }
}

RCT_EXPORT_METHOD(setupWithGroupId:(NSString *)groupId result:(RCTResponseSenderBlock)result) {
  
  [[GizSiriAppGroupManager defaultManager] setupWithGroupId:groupId];
  result(@[[NSNull null], @"success"]);
}

RCT_EXPORT_METHOD(setToken:(NSString *)token result:(RCTResponseSenderBlock)result) {
  [[GizSiriAppGroupManager defaultManager] archiveToken:token];
  
  result(@[[NSNull null], @"success"]);
}

RCT_EXPORT_METHOD(getToken:(RCTResponseSenderBlock)result) {
  NSString *token = [[GizSiriAppGroupManager defaultManager] getToken];
  result(@[[NSNull null], token]);
}

- (void)sendNotSupport:(NSString *)typeStr withCallbackResult:(RCTResponseSenderBlock)result {
  NSString *message = [NSString stringWithFormat:@"Not supported type: %@", typeStr];
  result(@[message]);
}

- (void)sendAuthorizationStatus:(GizSiriAuthorizationStatus)status withCallbackResult:(RCTResponseSenderBlock)result {
  result(@[[NSNull null], @(status)]);
}

#pragma mark - INUIAddVoiceShortcutViewControllerDelegate

- (void)addVoiceShortcutViewController:(INUIAddVoiceShortcutViewController *)controller didFinishWithVoiceShortcut:(INVoiceShortcut *)voiceShortcut error:(NSError *)error API_AVAILABLE(ios(12.0)) {
  [controller dismissViewControllerAnimated:YES completion:nil];
  self.addCallbackResult(@[[NSNull null], @"success"]);
}

- (void)addVoiceShortcutViewControllerDidCancel:(INUIAddVoiceShortcutViewController *)controller API_AVAILABLE(ios(12.0)) {
  [controller dismissViewControllerAnimated:YES completion:nil];
  self.addCallbackResult(@[@"Cancelled!"]);
}

#pragma mark - INUIEditVoiceShortcutViewControllerDelegate

- (void)editVoiceShortcutViewController:(INUIEditVoiceShortcutViewController *)controller didUpdateVoiceShortcut:(INVoiceShortcut *)voiceShortcut error:(NSError *)error API_AVAILABLE(ios(12.0)) {
  [controller dismissViewControllerAnimated:YES completion:nil];
  self.editCallbackResult(@[[NSNull null], @"success"]);
}

- (void)editVoiceShortcutViewController:(INUIEditVoiceShortcutViewController *)controller didDeleteVoiceShortcutWithIdentifier:(NSUUID *)deletedVoiceShortcutIdentifier API_AVAILABLE(ios(12.0)) {
  [controller dismissViewControllerAnimated:YES completion:nil];
  self.editCallbackResult(@[[NSNull null], @"success"]);
}

- (void)editVoiceShortcutViewControllerDidCancel:(INUIEditVoiceShortcutViewController *)controller API_AVAILABLE(ios(12.0)) {
  [controller dismissViewControllerAnimated:YES completion:nil];
  self.editCallbackResult(@[@"Cancelled!"]);
}

@end
