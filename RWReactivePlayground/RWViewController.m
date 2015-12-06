//
//  RWViewController.m
//  RWReactivePlayground
//
//  Created by Colin Eberhardt on 18/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "RWViewController.h"
#import "RWDummySignInService.h"

@interface RWViewController ()

@property(weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property(weak, nonatomic) IBOutlet UIButton *signInButton;
@property(weak, nonatomic) IBOutlet UILabel *signInFailureText;

@property(strong, nonatomic) RWDummySignInService *signInService;

@end

@implementation RWViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupData];
    [self setupView];
}

#pragma mark - ⊂((・猿・))⊃ SetupData

- (void)setupData {
    self.signInService = [RWDummySignInService new];
    self.signInFailureText.hidden = YES;    // initially hide the failure message
}

#pragma mark - ⊂((・猿・))⊃ SetupView

- (void)setupView {
    // 验证username输入, map
    RACSignal *validUsernameSignal = [self.usernameTextField.rac_textSignal map:^id(NSString *text) {
        return @([self isValidUsername:text]);
    }];
    // 验证password输入, map
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal map:^id(NSString *text) {
        return @([self isValidPassword:text]);
    }];

    // 改变UI, RAC( , )
    RAC(self.usernameTextField, backgroundColor) = [validUsernameSignal map:^id(NSNumber *validUsernameSignal) {
        return validUsernameSignal.boolValue ? [UIColor clearColor] : [UIColor yellowColor];
    }];

    RAC(self.passwordTextField, backgroundColor) = [validPasswordSignal map:^id(NSNumber *validPasswordSignal) {
        return validPasswordSignal.boolValue ? [UIColor clearColor] : [UIColor yellowColor];
    }];

    // signUp验证, combineLatest(聚合), reduce(归纳)
    [[RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal] reduce:^id(NSNumber *usernameVaild, NSNumber *passwordVaild) {
        return @(usernameVaild.boolValue && passwordVaild.boolValue);
    }] subscribeNext:^(NSNumber *signupActive) {
        self.signInButton.enabled = signupActive.boolValue;
    }];

    // button signal
    [[[[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside]
            doNext:^(id x) {
                self.signInButton.enabled = NO;
                self.signInFailureText.hidden = YES;
            }]
            flattenMap:^id(id value) {
                return self.signInSignal;
            }]
            subscribeNext:^(NSNumber *signedIn) {
                self.signInButton.enabled = YES;
                self.signInFailureText.hidden = signedIn.boolValue;
                if (signedIn.boolValue) {
                    [self enterSignInSucessVC];
                }
            }];

}

#pragma mark - ⊂((・猿・))⊃ Set_Get

- (RACSignal *)signInSignal {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [self.signInService signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text complete:^(BOOL success) {
            [subscriber sendNext:@(success)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

#pragma mark - ⊂((・猿・))⊃ Action

- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 3;
}

#pragma mark - ⊂((・猿・))⊃ EnterVC

- (void)enterSignInSucessVC {
    [self performSegueWithIdentifier:@"signInSuccess" sender:self];
}

@end
