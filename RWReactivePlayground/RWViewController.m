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

@property(nonatomic) BOOL passwordIsValid;
@property(nonatomic) BOOL usernameIsValid;
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
    [self updateUIState];

    // handle text changes for both text fields
    [self.usernameTextField addTarget:self action:@selector(usernameTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(passwordTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - ⊂((・猿・))⊃ Action

- (BOOL)isValidUsername:(NSString *)username {
    return username.length > 3;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length > 3;
}

- (IBAction)signInButtonTouched:(id)sender {
    // disable all UI controls
    self.signInButton.enabled = NO;
    self.signInFailureText.hidden = YES;

    // sign in
    [self.signInService signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text complete:^(BOOL success) {
        self.signInButton.enabled = YES;
        self.signInFailureText.hidden = success;
        if (success) {
            [self enterSignInSucessVC];
        }
    }];
}

// updates the enabled state and style of the text fields based on whether the current username
// and password combo is valid
- (void)updateUIState {
    self.usernameTextField.backgroundColor = self.usernameIsValid ? [UIColor clearColor] : [UIColor yellowColor];
    self.passwordTextField.backgroundColor = self.passwordIsValid ? [UIColor clearColor] : [UIColor yellowColor];
    self.signInButton.enabled = self.usernameIsValid && self.passwordIsValid;
}

- (void)usernameTextFieldChanged {
    self.usernameIsValid = [self isValidUsername:self.usernameTextField.text];
    [self updateUIState];
}

- (void)passwordTextFieldChanged {
    self.passwordIsValid = [self isValidPassword:self.passwordTextField.text];
    [self updateUIState];
}

#pragma mark - ⊂((・猿・))⊃ EnterVC

- (void)enterSignInSucessVC {
    [self performSegueWithIdentifier:@"signInSuccess" sender:self];
}

@end
