//
//  JHChatToolBar.m
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

#import "JHChatToolBar.h"
#import "JHEmojiPadView.h"

// 0 or 34
static CGFloat JHChatToolBar_iPhoneX_bottomH;

@interface JHChatToolBar()<UITextViewDelegate>
@property (nonatomic,  strong) UIView *toolBarView;
@property (nonatomic,  strong) UIView *leftItemView;
@property (nonatomic,  strong) UITextView *textView;
@property (nonatomic,  strong) UILabel *textViewHolder;
@property (nonatomic,  strong) UIView *rightItemView;
@property (nonatomic,  strong) JHChatToolBarButton *switchButton;
@property (nonatomic,  strong) UIButton *recordButton;
@property (nonatomic,  strong) JHChatToolBarButton *faceButton;
@property (nonatomic,  strong) JHChatToolBarButton *moreButton;

@property (nonatomic,  strong) JHChatToolBarButton *preButton;
/// 表情视图、更多视图等
@property (nonatomic,  strong) UIView *accessoryView;

@property (nonatomic,  assign) CGFloat  textViewHeight;
@property (nonatomic,  assign) CGFloat  minTextViewHeight;
@property (nonatomic,  assign) CGFloat  maxTextViewHeight;
@property (nonatomic,  assign) CGFloat  preTextViewHeight;

/// 切换到录音按钮时，保存textView的内容。切换回来时，再显示。
@property (nonatomic,    copy) NSString *text;

@end

@implementation JHChatToolBar

#pragma mark -------------------------------------视图-------------------------------------------

#pragma mark --- override

+ (void)initialize
{
    JHChatToolBar_iPhoneX_bottomH = [UIApplication sharedApplication].statusBarFrame.size.height == 20 ? 0 : 34;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        CGRect frame = self.frame;
        frame.origin.y = newSuperview.frame.size.height - frame.size.height - JHChatToolBar_iPhoneX_bottomH;
        self.frame = frame;
        
        [self frameDidChanged];
    }
}

- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }else{
        for (UIButton *button in _rightItemView.subviews) {
            button.selected = NO;
        }
        
        [UIView animateWithDuration:0.25 delay:0 options:(7 << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            CGRect frame = self.frame;
            frame.origin.y = CGRectGetMaxY(self.superview.frame) - CGRectGetHeight(_toolBarView.frame);
            self.frame = frame;
            
            [self frameDidChanged];
        } completion:^(BOOL finished) {
            [_accessoryView removeFromSuperview];
            _accessoryView = nil;
            
            CGRect frame = self.frame;
            frame.size.height = CGRectGetHeight(_toolBarView.frame);
            self.frame = frame;
        }];
    }
    
    return result;
}

+ (instancetype)chatToolBar
{
    return [[JHChatToolBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 46)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height <= 0) {
        frame.size.height = 46;
    }
    self = [super initWithFrame:frame];
    if (self) {
        
        _textViewHeight = 36;
        [self jhSetupViews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

#pragma mark --- custom

- (void)jhSetupViews
{
    [self addSubview:self.toolBarView];
    [_toolBarView addSubview:self.leftItemView];
    [_toolBarView addSubview:self.textView];
    [_textView addSubview:self.textViewHolder];
    [_toolBarView addSubview:self.recordButton];
    [_toolBarView addSubview:self.rightItemView];
    
    [_leftItemView addSubview:self.switchButton];
    [_rightItemView addSubview:self.faceButton];
    [_rightItemView addSubview:self.moreButton];
    
    [self updateItemView:_leftItemView];
    [self updateItemView:_rightItemView];
    
    _recordButton.frame = _textView.frame;
    
    _maxTextViewHeight = ceilf(_textView.font.lineHeight * 4);
    _minTextViewHeight = _textView.frame.size.height;
    _preTextViewHeight = _minTextViewHeight;
}

#pragma mark --- 布局子视图

- (void)updateItemView:(UIView *)itemView
{
    CGFloat x = 0;
    CGFloat offsetX = 0;
    for (UIView *view in itemView.subviews) {
        CGRect frame = view.frame;
        frame.origin.x = x;
        frame.origin.y = (itemView.frame.size.height - view.frame.size.height)*0.5;
        view.frame = frame;
        
        x += view.frame.size.width + offsetX;
    }
    
    x -= offsetX;
    
    CGRect frame = itemView.frame;
    frame.size.width = x;
    itemView.frame = frame;
    
    if (itemView == _leftItemView) {
        frame = _textView.frame;
        frame.origin.x = CGRectGetMaxX(_leftItemView.frame);
        _textView.frame = frame;
    }
    else if (itemView == _rightItemView) {
        frame.origin.x = self.frame.size.width - x;
        itemView.frame = frame;
        
        frame = _textView.frame;
        frame.size.width = _rightItemView.frame.origin.x - frame.origin.x - 7.5;
        _textView.frame = frame;
    }
    
    _recordButton.frame = _textView.frame;
}

- (UIView *)setupItemView
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds));
    //view.backgroundColor = [UIColor whiteColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    return view;
}

- (JHChatToolBarButton *)setupButton:(NSInteger)tag normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage
{
    JHChatToolBarButton *button = [JHChatToolBarButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    button.frame = CGRectMake(0, 0, 40, 40);
    if (normalImage) {
        [button setImage:[UIImage imageNamed:normalImage] forState:0];
    }
    if (selectedImage) {
        [button setImage:[UIImage imageNamed:selectedImage] forState:1<<2];
    }
    [button addTarget:self action:@selector(clickActioin:) forControlEvents:1<<6];
    return button;
}

#pragma mark -------------------------------------事件-------------------------------------------

#pragma mark --- UIKeyboardNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0 options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        CGRect frame = self.frame;
        frame.origin.y = endFrame.origin.y - frame.size.height;
        self.frame = frame;
        
        [self frameDidChanged];
    } completion:nil];
}

#pragma mark --- UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    BOOL flag = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:textViewWillBeginEditing:)]) {
        flag = [_delegate chatToolBar:self textViewWillBeginEditing:_textView];
    }

    if (flag) {
        [self refreshWillEditingStatus];
    }
    
    return flag;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self resetButtonStatus];
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:textViewDidBeginEditing:)]) {
        [_delegate chatToolBar:self textViewDidBeginEditing:_textView];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:textViewWillEndEditing:)]) {
        return [_delegate chatToolBar:self textViewWillEndEditing:_textView];
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _textViewHolder.hidden = textView.text.length > 0;
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:textViewDidEndEditing:)]) {
        [_delegate chatToolBar:self textViewDidEndEditing:_textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didSendText:)]) {
            BOOL isSend = [_delegate chatToolBar:self didSendText:textView.text];
            if (isSend) {
                textView.text = @"";
            }else {
                [textView resignFirstResponder];
            }
            [self shouldChangeTextViewHeight];
        }
        return NO;
    }
    else if ([text isEqualToString:@"@"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didInputAtInLocation:)]) {
            [_delegate chatToolBar:self didInputAtInLocation:range.location];
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _textViewHolder.hidden = textView.text.length > 0;
    
    [self shouldChangeTextViewHeight];
}

#pragma mark --- 根据文字计算高度
- (void)shouldChangeTextViewHeight
{
    CGFloat contentH = ceilf([_textView sizeThatFits:_textView.frame.size].height);
    
    if (contentH < _minTextViewHeight) {
        contentH = _minTextViewHeight;
    }
    if (contentH > _maxTextViewHeight + 2) {
        contentH = _maxTextViewHeight + 2;
    }else{
        [_textView setContentOffset:CGPointZero animated:YES];
    }
    
    if (contentH == _preTextViewHeight) {
        return;
    }else{
        CGFloat changeHeight = contentH - _preTextViewHeight;
        
        CGRect frame = self.frame;
        frame.size.height += changeHeight;
        frame.origin.y -= changeHeight;
        self.frame = frame;
        
        frame = _toolBarView.frame;
        frame.size.height += changeHeight;
        _toolBarView.frame = frame;
        
        _preTextViewHeight = contentH;
        
        [self frameDidChanged];
    }
}

#pragma mark --- 自身尺寸改变了
- (void)frameDidChanged
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didChangeFrameToHeight:)]) {
        [_delegate chatToolBar:self didChangeFrameToHeight:CGRectGetHeight(self.frame)];
    }
}

#pragma mark --- 将要编辑时，更新状态
- (void)refreshWillEditingStatus
{
    _textViewHolder.hidden = YES;
    
    // 重置高度
    CGRect frame = self.frame;
    frame.size.height = _toolBarView.frame.size.height;
    self.frame = frame;
    
    // 移除底部辅助视图
    [_accessoryView removeFromSuperview];
    
    [self frameDidChanged];
}

#pragma mark --- 重置按钮状态
- (void)resetButtonStatus
{
    // 重置状态
    for (UIButton *button in _leftItemView.subviews) {
        button.selected = NO;
    }
    
    for (UIButton *button in _rightItemView.subviews) {
        button.selected = NO;
    }
}

#pragma mark --- 按钮点击事件
- (void)clickActioin:(JHChatToolBarButton *)button
{
    // 记录上一个操作的按钮
    if (_preButton != button) {
        _preButton.selected = NO;
        _preButton = button;
    }
    
    button.selected = !button.selected;
    
    // 移除 表情、更多视图
    if (_accessoryView) {
        [_accessoryView removeFromSuperview];
        _accessoryView = nil;
    }
    
    // 默认显示输入框，隐藏录音按钮
    _textView.hidden = NO;
    _recordButton.hidden = YES;
    
    // 还原内容
    if (_text.length > 0) {
        _textView.text = _text;
        _text = @"";
        [_textView setContentOffset:CGPointZero animated:YES];
        [self shouldChangeTextViewHeight];
    }
    
    if (button.selected == NO) { // 显示 输入框
        
        // 先重置高度
        CGRect frame = self.frame;
        frame.size.height = _toolBarView.frame.size.height;
        self.frame = frame;
        
        [_textView becomeFirstResponder];
    }else{
        
        // 先重置高度、回到底部
        CGRect frame = self.frame;
        frame.size.height = _toolBarView.frame.size.height;
        frame.origin.y = self.superview.frame.size.height - frame.size.height;
        self.frame = frame;
        
        [_textView resignFirstResponder];
    }
    
    NSInteger tag = button.tag;
    if (tag == 100) {
        [self recordActioin:button];
    }else if (tag == 200) {
        [self moreActioin:button];
    }else if (tag == 300) {
        [self faceActioin:button];
    }
}

#pragma mark --- 切换输入与录音事件
- (void)recordActioin:(JHChatToolBarButton *)button
{
    if (button.selected) { // 显示 录音按钮
        _recordButton.hidden = NO;
        _textView.hidden = YES;
        
        // 清空输入框
        _text = _textView.text;
        _textView.text = @"";
        [self shouldChangeTextViewHeight];
    }
}

#pragma mark --- 更多事件
- (void)moreActioin:(JHChatToolBarButton *)button
{
    if (button.selected) { // 显示 更多视图
        [self showBottomView:button.accessoryView];
    }
}

#pragma mark --- 表情事件
- (void)faceActioin:(JHChatToolBarButton *)button
{
    if (button.selected) { // 显示 表情视图
        [self showBottomView:button.accessoryView];
    }
}

#pragma mark --- 显示表情视图、更多视图等
- (void)showBottomView:(UIView *)view
{
    CGRect frame = view.frame;
    frame.origin.y = _toolBarView.frame.size.height;
    view.frame = frame;
    
    frame = self.frame;
    frame.size.height = CGRectGetMaxY(view.frame);
    frame.origin.y = self.superview.frame.size.height - frame.size.height - JHChatToolBar_iPhoneX_bottomH;
    self.frame = frame;
    
    [self addSubview:view];
    _accessoryView = view;
    
    [self frameDidChanged];
}

#pragma mark --- 开始录音
- (void)recordTouchDown
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didStartRecording:)]) {
        [_delegate chatToolBar:self didStartRecording:nil];
    }
}

#pragma mark --- 取消录音
- (void)recordTouchUpOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didCancelRecording:)]) {
        [_delegate chatToolBar:self didCancelRecording:nil];
    }
}

#pragma mark --- 结束录音
- (void)recordTouchUpInside
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didFinishRecoing:)]) {
        [_delegate chatToolBar:self didFinishRecoing:nil];
    }
}

#pragma mark --- 上滑取消
- (void)recordDragOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didDragOutside:)]) {
        [_delegate chatToolBar:self didDragOutside:nil];
    }
}

#pragma mark --- 下滑继续
- (void)recordDragInside
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didDragInside:)]) {
        [_delegate chatToolBar:self didDragInside:nil];
    }
}

#pragma mark --- 更多视图菜单按钮点击事件
- (void)clickMoreViewMenu:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolBar:didClickMoreViewMenu:)]) {
        [_delegate chatToolBar:self didClickMoreViewMenu:button];
    }
}

#pragma mark --- 插入Emoji
- (void)insertEmoji:(NSString *)text
{
    if ([text isEqualToString:@"[删除]"]) {
        if (_textView.text.length == 0) {
            return;
        }
        
        NSRange range = _textView.selectedRange;
        range.location -= 1;
        range.length = 1;
        NSString *s = [_textView.text substringWithRange:range];
        if ([s isEqualToString:@"]"]) {
            while (![s isEqualToString:@"["]) {
                [_textView deleteBackward];
                NSRange range = _textView.selectedRange;
                range.location -= 1;
                range.length = 1;
                s = [_textView.text substringWithRange:range];
            }
        }
        [_textView deleteBackward];
    }else{
        [self insertText:text];
        CGFloat contentH = ceilf([_textView sizeThatFits:_textView.frame.size].height);
        [_textView setContentOffset:CGPointMake(0, contentH-CGRectGetHeight(_textView.frame)) animated:YES];
    }
}

#pragma mark - public

#pragma mark --- 插入文本
- (void)insertText:(NSString *)text
{
    [_textView insertText:text];
}

#pragma mark --- 删除文本
- (void)deleteText;
{
    [_textView deleteBackward];
}

#pragma mark -------------------------------------懒加载-----------------------------------------

- (UIView *)toolBarView{
    if (!_toolBarView) {
        UIView *view = [[UIView alloc] init];
        view.frame = self.bounds;
        view.backgroundColor = [UIColor orangeColor];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _toolBarView = view;
    }
    return _toolBarView;
}

- (UITextView *)textView{
    if (!_textView) {
        UITextView *textView = [[UITextView alloc] init];
        textView.frame = CGRectMake(0, (self.frame.size.height-_textViewHeight)*0.5, self.frame.size.width, _textViewHeight);
        textView.text = @"";
        textView.delegate = self;
        textView.textColor = [UIColor blackColor];
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textView.layer.masksToBounds = YES;
        textView.font = [UIFont systemFontOfSize:14];
        textView.textAlignment = NSTextAlignmentLeft;
        textView.textContainerInset = UIEdgeInsetsMake(9, 5, 9, 2);
        textView.returnKeyType = UIReturnKeySend;
        textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        textView.textContainer.lineFragmentPadding = 0;
        _textView = textView;
    }
    return _textView;
}

- (UILabel *)textViewHolder{
    if (!_textViewHolder) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = self.textView.bounds;
        label.text = @" 请输入聊天内容...";
        label.textColor = [UIColor lightGrayColor];
        label.font = _textView.font;
        label.textAlignment = NSTextAlignmentLeft;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textViewHolder = label;
    }
    return _textViewHolder;
}

- (UIView *)leftItemView{
    if (!_leftItemView) {
        _leftItemView = [self setupItemView];
    }
    return _leftItemView;
}

- (UIView *)rightItemView{
    if (!_rightItemView) {
        _rightItemView = [self setupItemView];
    }
    return _rightItemView;
}

- (JHChatToolBarButton *)switchButton{
    if (!_switchButton) {
        _switchButton = [self setupButton:100 normalImage:@"btn_JHChatToolBar_microphone" selectedImage:@"btn_JHChatToolBar_keyboard1"];
    }
    return _switchButton;
}

- (UIButton *)recordButton{
    if (!_recordButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor lightGrayColor];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.cornerRadius = CGRectGetHeight(self.textView.frame)*0.5;
        [button setTitle:@"按住说话" forState:0];
        [button setTitleColor:[UIColor whiteColor] forState:0];
        [button addTarget:self action:@selector(recordTouchDown) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(recordTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(recordTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [button addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
        button.hidden = YES;
        _recordButton = button;
    }
    return _recordButton;
}

- (JHChatToolBarButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [self setupButton:200 normalImage:@"btn_JHChatToolBar_more" selectedImage:@"btn_JHChatToolBar_keyboard2"];
        _moreButton.accessoryView = ({
            UIView *view = [[UIView alloc] init];
            view.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 150);
            view.backgroundColor = [UIColor lightGrayColor];
            view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 30);
            label.text = @"更多按钮对应的视图";
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:20];
            label.textAlignment = 1;
            [view addSubview:label];
            
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            button1.frame = CGRectMake(10, 50, 60, 60);
            button1.backgroundColor = [UIColor brownColor];
            button1.titleLabel.font = [UIFont systemFontOfSize:16];
            [button1 setTitle:@"拍照" forState:0];
            [button1 setTitleColor:[UIColor blackColor] forState:0];
            [button1 setImage:nil forState:0];
            [button1 jh_handleEvent:1<<6 inTarget:self block:^(JHChatToolBar *target, id  _Nonnull sender) {
                NSLog(@"拍照");
                [target clickMoreViewMenu:sender];
            }];
            [view addSubview:button1];
            
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
            button2.frame = CGRectMake(80, 50, 60, 60);
            button2.backgroundColor = [UIColor brownColor];
            button2.titleLabel.font = [UIFont systemFontOfSize:16];
            [button2 setTitle:@"红包" forState:0];
            [button2 setTitleColor:[UIColor blackColor] forState:0];
            [button2 setImage:nil forState:0];
            [button2 jh_handleEvent:1<<6 inTarget:self block:^(JHChatToolBar *target, id  _Nonnull sender) {
                NSLog(@"红包");
                [target clickMoreViewMenu:sender];
            }];
            [view addSubview:button2];
            
            UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
            button3.frame = CGRectMake(150, 50, 60, 60);
            button3.backgroundColor = [UIColor brownColor];
            button3.titleLabel.font = [UIFont systemFontOfSize:16];
            [button3 setTitle:@"图片" forState:0];
            [button3 setTitleColor:[UIColor blackColor] forState:0];
            [button3 setImage:nil forState:0];
            [button3 jh_handleEvent:1<<6 inTarget:self block:^(JHChatToolBar *target, id  _Nonnull sender) {
                NSLog(@"图片");
                [target clickMoreViewMenu:sender];
            }];
            [view addSubview:button3];
            
            view;
        });
    }
    return _moreButton;
}

- (JHChatToolBarButton *)faceButton{
    if (!_faceButton) {
        _faceButton = [self setupButton:300 normalImage:@"btn_JHChatToolBar_face" selectedImage:@"btn_JHChatToolBar_keyboard2"];
        _faceButton.accessoryView = ({
            __weak typeof(self) ws = self;
            JHEmojiPadConfig *config = [[JHEmojiPadConfig alloc] init];
            config.emojiType = JHEmojiType_Face1;
            config.topOffset = 10;
            JHEmojiPadView *emojiPad = [[JHEmojiPadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) config:config];
            emojiPad.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            emojiPad.emojiClickBlock = ^(NSString *face, NSString *text) {
                NSLog(@"表情图片：%@，表情内容：%@",face,text);
                [ws insertEmoji:text];
            };
            emojiPad;
        });
    }
    return _faceButton;
}

@end
