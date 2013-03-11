//
//  Easy8BitCameraViewController.h
//  Easy8BitCamera
//
//  Created by 浅見 憲司 on 2013/03/03.
//  Copyright (c) 2013年 mnj-tokorozawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Easy8BitCameraViewController;

@protocol Easy8BitCameraViewDelegate <NSObject>
- (void) settingValueChanged:(BOOL)monochromeFlg scaleValue:(NSInteger)scaleValue levelValue:(NSInteger)levelValue;
- (BOOL) enableMonochrome;
- (NSNumber *) pixellateScale;
- (NSNumber *) posterizeLevel;
@end

@interface Easy8BitCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, Easy8BitCameraViewDelegate> {
    NSNumber *enableMonochrome;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionButton;
- (IBAction)showPhotoLibrary:(id)sender;
- (IBAction)showCamera:(id)sender;
- (IBAction)showOption:(id)sender;
- (IBAction)showSetting:(id)sender;

@end
