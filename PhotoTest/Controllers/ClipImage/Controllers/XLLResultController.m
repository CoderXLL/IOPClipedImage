//
//  XLLResultController.m
//  PhotoTest
//
//  Created by xiaoll on 2019/3/25.
//  Copyright © 2019 Tuling Code. All rights reserved.
//

#import "XLLResultController.h"

@interface XLLResultController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation XLLResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.image = self.resultImage;
}

@end
