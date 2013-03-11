//
//  SettingViewController.h
//  Easy8BitCamera
//
//  Created by 浅見 憲司 on 2013/03/04.
//  Copyright (c) 2013年 mnj-tokorozawa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Easy8BitCameraViewController.h"

@class SettingViewController;

@interface SettingViewController : UIViewController

@property (weak, nonatomic) id<Easy8BitCameraViewDelegate> parentDelegate;

@property (weak, nonatomic) IBOutlet UISwitch *enableMonochrome;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pixellateScale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *posterizeLevel;

- (IBAction)set8BitSetting:(id)sender;
- (IBAction)set16BitSetting:(id)sender;
- (IBAction)closeButton:(id)sender;
@end
