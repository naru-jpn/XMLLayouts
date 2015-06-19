
#import "MenuViewController.h"
#import "Example1NavigationController.h"
#import "Example2ViewController.h"
#import "Example3ViewController.h"

@implementation MenuViewController

#pragma mark - action

- (void)onButton1Clicked:(id)sender {
    [self presentViewController:[Example1NavigationController new] animated:YES completion:nil];
}

- (void)onButton2Clicked:(id)sender {
    [self presentViewController:[Example2ViewController new] animated:YES completion:nil];
}

- (void)onButton3Clicked:(id)sender {
    [self presentViewController:[Example3ViewController new] animated:YES completion:nil];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // load views from xml file
    [self.view loadXMLLayoutsWithResourceName:@"MenuLayout" completion:^(NSError *error) {
        
        // find button with id named 'button1'
        UIButton *button1 = (UIButton *)[self.view viewWithID:R.id(@"@id/button1")];
        [button1 addTarget:self action:@selector(onButton1Clicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // find button with id named 'button2'
        UIButton *button2 = (UIButton *)[self.view viewWithID:R.id(@"@id/button2")];
        [button2 addTarget:self action:@selector(onButton2Clicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // you can use blocks to find view with id
        [self.view findViewByID:R.id(@"@id/button3") work:^(UIView *button3) {
            [(UIButton *)button3 addTarget:self action:@selector(onButton3Clicked:) forControlEvents:UIControlEventTouchUpInside];
        }];
    }];
}

- (void)viewDidLayoutSubviews {
    // reload layouts when device will be lotated
    [self.view refreshAllLayout];
}

@end
