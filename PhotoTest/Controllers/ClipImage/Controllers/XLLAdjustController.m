//
//  XLLAdjustController.m
//  PhotoTest
//
//  Created by xiaoll on 2019/3/25.
//  Copyright © 2019 Tuling Code. All rights reserved.
//

#import "XLLAdjustController.h"
#import "XLLResultController.h"
#import "XLLAdjustContainerView.h"

@interface XLLAdjustController ()

@property (weak, nonatomic) IBOutlet XLLAdjustContainerView *adjustContainerView;

@end

@implementation XLLAdjustController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"finishClip"])
    {
        XLLResultController *resultVC = (XLLResultController *)segue.destinationViewController;
        resultVC.resultImage = [self.adjustContainerView.adjustView getClipedImage];
    }
}

@end
