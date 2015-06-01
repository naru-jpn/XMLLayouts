
#import "Example1NavigationController.h"
#import "WelcomeViewController.h"

@implementation Example1NavigationController

- (instancetype)init {
    if (self = [super init]) {
        [self setViewControllers:@[[WelcomeViewController new]]];
    }
    return self;
}

@end
