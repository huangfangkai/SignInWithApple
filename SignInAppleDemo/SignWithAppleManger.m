//
//  SignWithAppleManger.m
//  ihz
//
//  Created by hfk on 2020/7/3.
//  Copyright © 2020 张佳磊. All rights reserved.
//

#import "SignWithAppleManger.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "SAMKeychain.h"

NSString* const ShareCurrentIdentifier = @"ShareCurrentIdentifier";

@interface SignWithAppleManger ()<ASAuthorizationControllerDelegate, // 提供关于授权请求结果信息的接口
ASAuthorizationControllerPresentationContextProviding> // 控制器的代理找一个展示授权控制器的上下文的接口

/**
 需要返回数据block
 */
@property (nonatomic , copy) SignBackInfoBlock block;

@end

@implementation SignWithAppleManger

+ (instancetype)sharedManager {
    static SignWithAppleManger *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
        
    });
    return shared_manager;
}
-(void)SignInWithAppleWithBlock:(SignBackInfoBlock)block{
    
    self.block = block;
    
    [self observeAppleSignInState];
    
    if (@available(iOS 13.0, *)) {
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIdProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        // 创建新的AppleID 授权请求
        ASAuthorizationAppleIDRequest *appleIdRequest = [appleIdProvider createRequest];
        // 在用户授权期间请求的联系信息
        appleIdRequest.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIdRequest]];
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;
        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    }else{
        // 处理不支持系统版本
        if (self.block) {
            self.block(@"该系统版本不可用Apple登录", NO, NO);
        }
    }
}

-(void)ExistingSignInWithAppleWithBlock:(SignBackInfoBlock)block{
    
    self.block = block;
    
    [self observeAppleSignInState];
    
    if (@available(iOS 13.0, *)) {
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIdProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        // 授权请求AppleID
        ASAuthorizationAppleIDRequest *appleIdRequest = [appleIdProvider createRequest];
        // 为了执行钥匙串凭证分享生成请求的一种机制
        ASAuthorizationPasswordProvider *passwordProvider = [[ASAuthorizationPasswordProvider alloc] init];
        ASAuthorizationPasswordRequest *passwordRequest = [passwordProvider createRequest];
        NSMutableArray <ASAuthorizationRequest *>* requestArr = [NSMutableArray arrayWithCapacity:2];
        if (appleIdRequest) {
            [requestArr addObject:appleIdRequest];
        }
        if (passwordRequest) {
            [requestArr addObject:passwordRequest];
        }
        // ASAuthorizationRequest：对于不同种类授权请求的基类
        NSArray <ASAuthorizationRequest *>* requests = [requestArr copy];
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:requests];
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;
        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    }else{
        // 处理不支持系统版本
        if (self.block) {
            self.block(@"该系统版本不可用Apple登录", NO, NO);
        }
    }
}
#pragma mark - delegate
//@optional 授权成功地回调
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){
    //    NSLog(@"授权完成:::%@", authorization.credential);
    //    NSLog(@"%s", __FUNCTION__);
    //    NSLog(@"%@", controller);
    //    NSLog(@"%@", authorization);
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 用户登录使用ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = (ASAuthorizationAppleIDCredential *)authorization.credential;
        NSString *user = appleIDCredential.user;
        // 使用钥匙串的方式保存用户的唯一信息
        [SAMKeychain setPassword:user forService:[NSBundle mainBundle].bundleIdentifier account:ShareCurrentIdentifier];
        // 使用过授权的，可能获取不到以下三个参数
        NSString *familyName = appleIDCredential.fullName.familyName;
        NSString *givenName = appleIDCredential.fullName.givenName;
        NSString *email = appleIDCredential.email;
        NSData *identityToken = appleIDCredential.identityToken;
        NSData *authorizationCode = appleIDCredential.authorizationCode;
        // 服务器验证需要使用的参数
        NSString *identityTokenStr = [[NSString alloc] initWithData:identityToken encoding:NSUTF8StringEncoding];
        NSString *authorizationCodeStr = [[NSString alloc] initWithData:authorizationCode encoding:NSUTF8StringEncoding];
        if (self.block) {
            self.block(user, YES, NO);
        }
    }else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]){
        // 这个获取的是iCloud记录的账号密码，需要输入框支持iOS 12 记录账号密码的新特性，如果不支持，可以忽略
        // Sign in using an existing iCloud Keychain credential.
        // 用户登录使用现有的密码凭证
        ASPasswordCredential *passwordCredential = (ASPasswordCredential *)authorization.credential;
        // 密码凭证对象的用户标识 用户的唯一标识
        NSString *user = passwordCredential.user;
        // 密码凭证对象的密码
        NSString *password = passwordCredential.password;
    }else{
        if (self.block) {
            self.block(@"授权信息均不符", NO, NO);
        }
    }
}

//MARK:授权失败的回调
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)){
    // Handle error.
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
        default:
            break;
    }
    if (self.block) {
        self.block(errorMsg, NO, YES);
    }
}
//MARK ASAuthorizationControllerPresentationContextProviding
//告诉代理应该在哪个window 展示内容给用户
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){
    // 返回window
    return [UIApplication sharedApplication].windows.lastObject;
}
//MARK:添加苹果登录的状态通知
- (void)observeAppleSignInState {
    if (@available(iOS 13.0, *)) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}
//MARK:观察SignInWithApple状态改变
- (void)handleSignInWithAppleStateChanged:(NSNotification *) noti {
    NSLog(@"%@", noti.name);
    NSLog(@"%@", noti.userInfo);
}
- (void)dealloc {
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}
@end
