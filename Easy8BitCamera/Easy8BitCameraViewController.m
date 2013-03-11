//
//  Easy8BitCameraViewController.m
//  Easy8BitCamera
//
//  Created by 浅見 憲司 on 2013/03/03.
//  Copyright (c) 2013年 mnj-tokorozawa. All rights reserved.
//

#import "Easy8BitCameraViewController.h"
#import "SettingViewController.h"

#import <CoreImage/CoreImage.h>
#import <Social/Social.h>

@interface Easy8BitCameraViewController ()

@end

@implementation Easy8BitCameraViewController

NSArray *pixellateScaleArray;
NSArray *posterizeLevelArray;

NSNumber *enableMonochrome;
NSNumber *pixellateScale;
NSNumber *posterizeLevel;

// カメラ、アルバムの定数
UIImagePickerControllerSourceType typePhotoLibrary = UIImagePickerControllerSourceTypePhotoLibrary;
UIImagePickerControllerSourceType typeCamera = UIImagePickerControllerSourceTypeCamera;

// Socialフレームワーク
SLComposeViewController *socialViewController;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 画像の粗さ、減色の度合い
    pixellateScaleArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:6], [NSNumber numberWithInt:10], [NSNumber numberWithInt:16], nil];
    posterizeLevelArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:30], [NSNumber numberWithInt:12], [NSNumber numberWithInt:6], [NSNumber numberWithInt:4], nil];
    
    enableMonochrome = [NSNumber numberWithInteger:0];
    pixellateScale = [NSNumber numberWithInteger:2];
    posterizeLevel = [NSNumber numberWithInteger:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 写真アルバム起動
- (IBAction)showPhotoLibrary:(id)sender {
    
    self.imageView.tag = typePhotoLibrary;
    
    if ([UIImagePickerController isSourceTypeAvailable:typePhotoLibrary]) {
        if (self.imageView.image != NULL) {
            [self confirmClear];
        } else {
            [self showImagePicker:typePhotoLibrary];
        }
    }
}

// カメラ起動
- (IBAction)showCamera:(id)sender {
    
    self.imageView.tag = typeCamera;
    
    if ([UIImagePickerController isSourceTypeAvailable:typeCamera]) {
        if (self.imageView.image != NULL) {
            [self confirmClear];
        } else {
            [self showImagePicker:typeCamera];
        }
    } else {
        UIAlertView *noCameraAlert = [[UIAlertView alloc] initWithTitle:@"カメラ非対応です" message:@"カメラは起動できません。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [noCameraAlert show];
    }
}

// 写真アルバム or カメラの起動
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *viewImagePicker = [[UIImagePickerController alloc] init];
    viewImagePicker.sourceType = sourceType;
    viewImagePicker.delegate = self;
    
    [self presentViewController:viewImagePicker animated:YES completion:NULL];
}

// Option画面のボタン設定
- (IBAction)showOption:(id)sender {
    
    UIActionSheet *confirmSave = [[UIActionSheet alloc] init];
    
    confirmSave.delegate = self;
    confirmSave.title = @"この画像をどうしますか？";
    [confirmSave addButtonWithTitle:@"twitterに投稿する"];
    [confirmSave addButtonWithTitle:@"Facebookに投稿する"];
    [confirmSave addButtonWithTitle:@"保存する"];
    [confirmSave addButtonWithTitle:@"キャンセル"];
    [confirmSave addButtonWithTitle:@"クリア"];
    confirmSave.cancelButtonIndex = 3;
    confirmSave.destructiveButtonIndex = 4;
    
    [confirmSave showInView:self.view];
}

// セッティング画面の表示
- (IBAction)showSetting:(id)sender {
    
    self.imageView.tag = 99;
    
    if (self.imageView.image != NULL) {
        [self confirmClear];
    } else {
        [self segueToSettingView];
    }
}

// 写真クリア時の確認アラート
- (void)confirmClear {
    UIAlertView *confirmClearAlert = [[UIAlertView alloc] initWithTitle:@"クリア確認" message:@"現在表示されている画像はクリアされますが、よろしいですか？" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
    [confirmClearAlert show];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIGraphicsBeginImageContext(selectedImage.size);
    [selectedImage drawInRect:CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height)];
    selectedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:selectedImage];
    
    CIImage *firstImage;
    if ([enableMonochrome intValue] == 1) {
        CIFilter *filter0 = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey, inputImage, nil];
        [filter0 setValue:[CIColor colorWithRed:0.75 green:0.75 blue:0.75] forKey:@"inputColor"];
        firstImage = [filter0 outputImage];
        inputImage = nil;
        filter0 = nil;
        selectedImage = nil;
    } else {
        firstImage = inputImage;
    }
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate" keysAndValues:kCIInputImageKey, firstImage, nil];
    [filter setValue:[pixellateScaleArray objectAtIndex:[pixellateScale intValue]] forKey:@"inputScale"];
    CIImage *middleImage = [filter outputImage];
    filter = nil;
    firstImage = nil;
    
    CIFilter *filter2 = [CIFilter filterWithName:@"CIColorPosterize" keysAndValues:kCIInputImageKey, middleImage, nil];
    [filter2 setValue:[posterizeLevelArray objectAtIndex:[posterizeLevel intValue]] forKey:@"inputLevels"];
    CIImage *outputImage = [filter2 outputImage];
    filter2 = nil;
    middleImage = nil;
    
    
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    if (picker.sourceType == typePhotoLibrary) {
        [self dismissViewControllerAnimated:YES completion:^{
            self.imageView.image = filteredImage;
            self.optionButton.enabled = YES;
        }];
    } else if (picker.sourceType == typeCamera) {
        [self dismissViewControllerAnimated:YES completion:^{
            self.imageView.image = filteredImage;
            self.optionButton.enabled = YES;
        }];
    }
}

// Optionボタン押下時の処理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        // twitter共有
        case 0:
            socialViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [socialViewController setInitialText:@" アプリテスト中"];
            [socialViewController addImage:self.imageView.image];
            [self presentViewController:socialViewController animated:YES completion:NULL];
            break;
        // Facebook共有
        case 1:
            socialViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [socialViewController setInitialText:@" Fb用アプリテスト中"];
            [socialViewController addImage:self.imageView.image];
            [self presentViewController:socialViewController animated:YES completion:NULL];
            break;
        // アルバムに加工した写真を保存
        case 2:
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
            break;
        // キャンセル
        case 3:
            break;
        // クリア
        case 4:
            self.imageView.tag = -1;
            [self confirmClear];
            break;
    }
}

// 写真アルバム or カメラ起動時の処理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
        self.imageView.image = NULL;
        self.optionButton.enabled = NO;
        if (self.imageView.tag == typePhotoLibrary) {
            [self showImagePicker:typePhotoLibrary];
        } else if (self.imageView.tag == typeCamera) {
            [self showImagePicker:typeCamera];
        } else if (self.imageView.tag == 99) {
            [self segueToSettingView];
        } else {
        }
    }
}

// 設定完了処理
- (void)settingValueChanged:(BOOL)monochromeFlg scaleValue:(NSInteger)scaleValue levelValue:(NSInteger)levelValue {
    
    if (monochromeFlg == YES) {
        enableMonochrome = [NSNumber numberWithInteger:1];
    } else {
        enableMonochrome = [NSNumber numberWithInteger:0];
    }
    pixellateScale = [NSNumber numberWithInteger:scaleValue];
    posterizeLevel = [NSNumber numberWithInteger:levelValue];
}

// セッティングページへの遷移（モーダル）
- (void) segueToSettingView {
    SettingViewController *settingController = [[self storyboard] instantiateViewControllerWithIdentifier:@"settingView"];
    [settingController setParentDelegate:self];
    [self presentViewController:settingController animated:YES completion:NULL];
}

// getter method
- (BOOL)enableMonochrome {
    return [enableMonochrome boolValue];
}

- (NSNumber *)pixellateScale {
    return pixellateScale;
}

- (NSNumber *)posterizeLevel {
    return posterizeLevel;
}

@end
