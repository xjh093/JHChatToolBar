//
//  JHChatToolBarButton.h
//  JHKit
//
//  Created by HaoCold on 2019/5/16.
//  Copyright © 2019 HaoCold. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHChatToolBarButton : UIButton

/// 与按钮关联的视图，比如 emoji 按钮对应的 emoji 视图。
@property (nonatomic,  strong) UIView *accessoryView;

@end

NS_ASSUME_NONNULL_END
