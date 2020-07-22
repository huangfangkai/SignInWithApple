//
//  SignAppleViewController.m
//  SignAppleDemo
//
//  Created by hfk on 2020/7/22.
//  Copyright © 2020 hfk. All rights reserved.
//

#import "SignAppleViewController.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "SignWithAppleManger.h"

@interface SignAppleViewController ()

@end

@implementation SignAppleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
-(void)setUI{
    // 使用系统提供的按钮，要注意不支持系统版本的处理
    if (@available(iOS 13.0, *)) {
        // Sign In With Apple Button
        ASAuthorizationAppleIDButton *btn_apple = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeDefault style:ASAuthorizationAppleIDButtonStyleWhite];
        btn_apple.frame = CGRectMake(50, 100,  250, 100);
        [btn_apple addTarget:self action:@selector(signWithApple:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn_apple];
    }
    
    // 或者自己用UIButton实现按钮样式
    UIButton *btn_custom = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_custom.frame = CGRectMake(50, 250, 150, 44);
    [btn_custom setTitle:@"Sign in with Apple" forState:UIControlStateNormal];
    [btn_custom setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    [btn_custom addTarget:self action:@selector(signWithApple:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_custom];
    
}
-(void)signWithApple:(UIButton *)sender{
    [[SignWithAppleManger sharedManager]SignInWithAppleWithBlock:^(id  _Nonnull data, BOOL success, BOOL showError) {
        NSLog(@"123");
    }];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
