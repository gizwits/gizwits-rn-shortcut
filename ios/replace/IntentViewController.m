//
//  IntentViewController.m
//  GizSiriShortcutUI
//
//  Created by Minus🍀 on 2018/10/24.
//

#import "IntentViewController.h"

#import "GizManualSceneIntent.h"

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

@interface IntentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation IntentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - INUIHostedViewControlling

// Prepare your view controller for the interaction to handle.
- (void)configureViewForParameters:(NSSet <INParameter *> *)parameters ofInteraction:(INInteraction *)interaction interactiveBehavior:(INUIInteractiveBehavior)interactiveBehavior context:(INUIHostedViewContext)context completion:(void (^)(BOOL success, NSSet <INParameter *> *configuredParameters, CGSize desiredSize))completion {
    // Do configuration here, including preparing views and calculating a desired size for presentation.
    
    if ([interaction.intent isKindOfClass:[GizManualSceneIntent class]]) {
        GizManualSceneIntent *sceneIntent = (GizManualSceneIntent *)interaction.intent;
        
        self.imageView.image = [UIImage imageNamed:sceneIntent.image];
        
        if (interaction.intentHandlingStatus == INIntentHandlingStatusSuccess) {
            self.messageLabel.text = [NSString stringWithFormat:@"%@运行成功", sceneIntent.name];
        } else if (interaction.intentHandlingStatus == INIntentHandlingStatusFailure) {
            self.messageLabel.text = [NSString stringWithFormat:@"%@运行失败", sceneIntent.name];
        } else {
            self.messageLabel.text = [NSString stringWithFormat:@"正在运行%@...", sceneIntent.name];
        }
    }
    
    if (completion) {
        completion(YES, parameters, [self desiredSize]);
    }
}

- (CGSize)desiredSize {
    CGSize size = [self extensionContext].hostedViewMaximumAllowedSize;
    size.height = 100;
    return size;
}

@end
