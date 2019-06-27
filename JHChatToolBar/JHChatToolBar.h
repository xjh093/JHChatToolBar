//
//  JHChatToolBar.h
//  JHKit
//
//  Created by HaoCold on 2019/5/16.
//  Copyright © 2019 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2019 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <UIKit/UIKit.h>
#import "JHChatToolBarButton.h"

@class JHChatToolBar;

@protocol JHChatToolBarDelegate <NSObject>

@required

/// frame变化
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didChangeFrameToHeight:(CGFloat)height;

@optional

/// 将要开始编辑
- (BOOL)chatToolBar:(JHChatToolBar *)chatToolBar textViewWillBeginEditing:(UITextView *)textView;
/// 已经开始编辑
- (void)chatToolBar:(JHChatToolBar *)chatToolBar textViewDidBeginEditing:(UITextView *)textView;
/// 将要结束编辑
- (BOOL)chatToolBar:(JHChatToolBar *)chatToolBar textViewWillEndEditing:(UITextView *)textView;
/// 已经结束编辑
- (void)chatToolBar:(JHChatToolBar *)chatToolBar textViewDidEndEditing:(UITextView *)textView;

/// 发送消息
- (BOOL)chatToolBar:(JHChatToolBar *)chatToolBar didSendText:(NSString *)text;
/// 输入了 @ 字符
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didInputAtInLocation:(NSUInteger)location;

/// 按下录音按钮开始录音
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didStartRecording:(UIView *)recordView;
/// 手指向上滑动取消录音
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didCancelRecording:(UIView *)recordView;
/// 松开手指完成录音
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didFinishRecoing:(UIView *)recordView;
/// 当手指离开按钮的范围内时
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didDragOutside:(UIView *)recordView;
/// 当手指再次进入按钮的范围内时
- (void)chatToolBar:(JHChatToolBar *)chatToolBar didDragInside:(UIView *)recordView;

@end

@interface JHChatToolBar : UIView

@property (nonatomic,    weak) id <JHChatToolBarDelegate> delegate;

+ (instancetype)chatToolBar;

/// 插入文本
- (void)insertText:(NSString *)text;
/// 删除文本
- (void)deleteText;
/// 恢复初始状态
- (BOOL)endEditing:(BOOL)force;

@end
