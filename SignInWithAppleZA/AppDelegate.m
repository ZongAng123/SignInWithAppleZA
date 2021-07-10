//
//  AppDelegate.m
//  SignInWithAppleZA
//
//  Created by 纵昂 on 2021/7/8.
//

#import "AppDelegate.h"
#pragma mark - 苹果账号登录
#import <AuthenticationServices/AuthenticationServices.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#pragma mark- 苹果账号登录配置
    [self observeAuthticationState];
    
    return YES;
}

#pragma mark - Private functions 用户注销 AppleId 或 停止使用 Apple ID 的状态处理
// 观察授权状态
- (void)observeAuthticationState {
    
    if (@available(iOS 13.0, *)) {
        
        // 注意 存储用户标识信息需要使用钥匙串来存储 这里使用NSUserDefaults 做的简单示例
        NSString *userIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:@"appleID"];
        
        if (userIdentifier) {
            
            ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
            
            [appleIDProvider getCredentialStateForUserID:userIdentifier
                                              completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
                switch (credentialState) {
                    case ASAuthorizationAppleIDProviderCredentialAuthorized:
                        // 授权状态有效
                        break;
                    case ASAuthorizationAppleIDProviderCredentialRevoked:
                        // 苹果账号登录的凭据已被移除，需解除绑定并重新引导用户使用苹果登录
                        break;
                    case ASAuthorizationAppleIDProviderCredentialNotFound:
                        // 未登录授权，直接弹出登录页面，引导用户登录
                        break;
                    case ASAuthorizationAppleIDProviderCredentialTransferred:
                        // 授权AppleID提供者凭据转移
                        break;
                }
            }];
        }
        
    }
    
}





@end
