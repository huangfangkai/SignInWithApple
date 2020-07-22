//
//  SignWithAppleManger.h
//  ihz
//
//  Created by hfk on 2020/7/3.
//  Copyright © 2020 张佳磊. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SignBackInfoBlock)(id data , BOOL success, BOOL showError);

@interface SignWithAppleManger : NSObject


+ (instancetype)sharedManager;

-(void)SignInWithAppleWithBlock:(SignBackInfoBlock)block;

// 如果存在iCloud Keychain 凭证或者AppleID 凭证提示用户
-(void)ExistingSignInWithAppleWithBlock:(SignBackInfoBlock)block;


@end

NS_ASSUME_NONNULL_END
