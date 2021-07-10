//
//  ViewController.m
//  SignInWithAppleZA
//
//  Created by 纵昂 on 2021/7/8.
//

#import "ViewController.h"
//iOS Sign In with Apple流程
#import <AuthenticationServices/AuthenticationServices.h>
@interface ViewController ()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#pragma mark - 注册通知
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    } else {
        // Fallback on earlier versions
    }
    
    
#pragma mark -  iOS13 才支持 系统提供的 登录按钮 要做下判断
        if (@available(iOS 13.0, *)){
//             Sign In With Apple 按钮
            ASAuthorizationAppleIDButton *appleIDBtn3 = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeDefault style:ASAuthorizationAppleIDButtonStyleWhiteOutline];
            appleIDBtn3.frame = CGRectMake(30, 560, self.view.bounds.size.width - 60, 40);
            
            [appleIDBtn3 addTarget:self action:@selector(didAppleIDBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:appleIDBtn3];
            
        }
    
}

#pragma mark - 苹果登录  发起授权登录请求   Begin    ================== https://www.jianshu.com/p/483b998f2370
-(void)didAppleIDBtnClicked{
    
    if (@available(iOS 13.0, *)) {
//        Authorization 发起授权登录请求
/*
 ASAuthorizationAppleIDProvider 这个类比较简单，头文件中可以看出，主要用于创建一个 ASAuthorizationAppleIDRequest 以及获取对应 userID 的用户授权状态。
 */
        ASAuthorizationAppleIDProvider * appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest * authAppleIDRequest = [appleIDProvider createRequest];
//        ASAuthorizationPasswordRequest * passwordRequest = [[[ASAuthorizationPasswordProvider alloc] init] createRequest];

        NSMutableArray <ASAuthorizationRequest *> * array = [NSMutableArray arrayWithCapacity:2];
        if (authAppleIDRequest) {
            [array addObject:authAppleIDRequest];
        }
        NSArray <ASAuthorizationRequest *> * requests = [array copy];
        
        ASAuthorizationController * authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:requests];
        authorizationController.delegate = self;
        authorizationController.presentationContextProvider = self;
        [authorizationController performRequests];
        
    } else {
        // 处理不支持系统版本
        NSLog(@"系统不支持Apple登录");
    }
    
}
#pragma mark- ASAuthorizationControllerDelegate
// 授权成功
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        
        ASAuthorizationAppleIDCredential * credential = authorization.credential;
        
//         苹果用户唯一标识符，该值在同一个开发者账号下的所有 App 下是一样的，开发者可以用该唯一标识符与自己后台系统的账号体系绑定起来。
        NSString * userID = credential.user;
//         苹果用户信息 如果授权过，可能无法再次获取该信息
        NSPersonNameComponents * fullName = credential.fullName;
        NSString * email = credential.email;
        
//         服务器验证需要使用的参数
        NSString * authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding];
        NSString * identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding];
        
//         用于判断当前登录的苹果账号是否是一个真实用户，取值有：unsupported、unknown、likelyReal
        ASUserDetectionStatus realUserStatus = credential.realUserStatus;
        
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"appleID"];
        
        NSLog(@"userID: %@", userID);
        NSLog(@"fullName: %@", fullName);
        NSLog(@"email: %@", email);
        NSLog(@"authorizationCode: %@", authorizationCode);
        NSLog(@"identityToken: %@", identityToken);
        NSLog(@"realUserStatus: %@", @(realUserStatus));
        
        NSString * loging = [NSString stringWithFormat:@"userID参数为:%@email参数为:%@identityToken参数为:%@",userID,email,identityToken];
        NSLog(@"Sign in with Apple++++++++++%@",loging);
        
        
        
    }
    else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        
        // 用户登录使用现有的密码凭证
        ASPasswordCredential * passwordCredential = authorization.credential;
        // 密码凭证对象的用户标识 用户的唯一标识
        NSString * user = passwordCredential.user;
        // 密码凭证对象的密码
        NSString * password = passwordCredential.password;
        
        NSLog(@"userID: %@", user);
        NSLog(@"password: %@", password);
        
    } else {
        
    }
}

// 授权失败
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    
    NSString *errorMsg = nil;
    
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
    }
    NSLog(@"%@", errorMsg);
}

#pragma mark- ASAuthorizationControllerPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    
    return self.view.window;
}

#pragma mark- apple授权状态 更改通知
- (void)handleSignInWithAppleStateChanged:(NSNotification *)notification
{
    NSLog(@"%@", notification.userInfo);
}
#pragma mark - 苹果授权    End    ========================



@end
