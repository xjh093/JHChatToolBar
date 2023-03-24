//
//  ViewController.m
//  JHChatToolBarDemo
//
//  Created by HaoCold on 2023/3/24.
//

#import "ViewController.h"
#import "JHChatToolBar.h"

@interface ViewController ()<JHChatToolBarDelegate>
@property (nonatomic,  strong) JHChatToolBar *chatBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#error "unzip source.zip"
    /*
     解压 JHEmojiKeyboard 文件夹内的 source.zip，里面包含表情文件，并导入工程
     */
    
    //self.view.backgroundColor = [UIColor blackColor];
    
    _chatBar = [JHChatToolBar chatToolBar:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width-30, 46)];
    _chatBar.delegate = self;
    _chatBar.bottomOffsetHeight = 34; // 底部安全距离
    [self.view addSubview:_chatBar];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 60);
    button.backgroundColor = [UIColor lightGrayColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"收起键盘" forState:0];
    [button setTitleColor:[UIColor blackColor] forState:0];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:1<<6];
    [self.view addSubview:button];
    button.center = CGPointMake(self.view.center.x, 100);
}

- (void)buttonAction
{
    [_chatBar endEditing:YES];
}

#pragma mark --- JHChatToolBarDelegate

/// frame变化
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didChangeFrameToHeight:(CGFloat)height
{
    NSLog(@"frame变化:%@", @(height));
}

/// 将要开始编辑
- (BOOL)chatToolBar:(JHChatToolBar *)chatToolBar textViewWillBeginEditing:(UITextView *)textView
{
    NSLog(@"将要开始编辑");
    return YES;
}

/// 已经开始编辑
- (void)chatToolBar:(JHChatToolBar *)chatToolBar textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"已经开始编辑");
}

/// 将要结束编辑
- (BOOL)chatToolBar:(JHChatToolBar *)chatToolBar textViewWillEndEditing:(UITextView *)textView
{
    NSLog(@"将要结束编辑");
    return YES;
}

/// 已经结束编辑
- (void)chatToolBar:(JHChatToolBar *)chatToolBar textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"已经结束编辑");
}

/// 发送消息
- (BOOL)chatToolBar:(JHChatToolBar *)chatToolBar didSendText:(NSString *)text
{
    NSLog(@"发送消息:%@",text);
    return YES;
}

/// 输入了 @ 字符
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didInputAtInLocation:(NSUInteger)location
{
    NSLog(@"输入了 @ 字符:%@", @(location));
}

/// 按下录音按钮开始录音
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didStartRecording:(UIView *)recordView
{
    NSLog(@"按下录音按钮开始录音");
}

/// 手指向上滑动取消录音
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didCancelRecording:(UIView *)recordView
{
    NSLog(@"手指向上滑动取消录音");
}

/// 松开手指完成录音
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didFinishRecoing:(UIView *)recordView
{
    NSLog(@"松开手指完成录音");
}

/// 当手指离开按钮的范围内时
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didDragOutside:(UIView *)recordView
{
    NSLog(@"当手指离开按钮的范围内时");
}

/// 当手指再次进入按钮的范围内时
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didDragInside:(UIView *)recordView
{
    NSLog(@"当手指再次进入按钮的范围内时");
}

/// 更多视图菜单按钮点击事件
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didClickMoreViewMenu:(UIView *)recordView
{
    NSLog(@"更多视图菜单按钮点击事件");
}

@end
