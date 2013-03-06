//
//  LoginViewController.m
//  as_test
//
//  Created by Tia Shelley on 3/6/13.
//  Copyright (c) 2013 Tia Shelley. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize loginButton = _loginButton;
@synthesize loginField = _loginField;
@synthesize passwordField = _passwordField;

- (void)viewDidLoad
{
    self.passwordField.delegate = self;
    self.loginField.delegate = self;
    self.passwordField.secureTextEntry = YES;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//hides keyboard when enter is clicked
- (BOOL) textFieldShouldReturn: (UITextField *) textField{
    return [textField resignFirstResponder];
}

- (IBAction)beginLogin {
    NSLog(@"%@, %@", _loginField.text, _passwordField.text);
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"userid=%@&password=%@", _loginField.text, _passwordField.text ];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: @"http://animal-stories.danceforscience.com/validate2.php" ] ];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
    NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
    NSLog(@"responseData: %@", content);
    if ([content isEqual: @"no such user"]){
        [self alertStatus:@"Login Failed. Please try again" :@"Login Failed"];
        _passwordField.text = @"";
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
