//
//  SettingViewController.m
//  Easy8BitCamera
//
//  Created by 浅見 憲司 on 2013/03/04.
//  Copyright (c) 2013年 mnj-tokorozawa. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 設定値をUIに設定
    self.enableMonochrome.on = [self.parentDelegate enableMonochrome];
    self.pixellateScale.selectedSegmentIndex = [[self.parentDelegate pixellateScale] intValue];
    self.posterizeLevel.selectedSegmentIndex = [[self.parentDelegate posterizeLevel] intValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 8bit推奨設定
- (IBAction)set8BitSetting:(id)sender {
    self.pixellateScale.selectedSegmentIndex = 2;
    self.posterizeLevel.selectedSegmentIndex = 2;
}

// 16bit推奨設定
- (IBAction)set16BitSetting:(id)sender {
    self.pixellateScale.selectedSegmentIndex = 1;
    self.posterizeLevel.selectedSegmentIndex = 1;
}

// セッティング完了ボタン押下時の処理
- (IBAction)closeButton:(id)sender {
    if ([self.parentDelegate respondsToSelector:@selector(settingValueChanged:scaleValue:levelValue:)]) {
        [self.parentDelegate settingValueChanged:self.enableMonochrome.on scaleValue:self.pixellateScale.selectedSegmentIndex levelValue:self.posterizeLevel.selectedSegmentIndex];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
