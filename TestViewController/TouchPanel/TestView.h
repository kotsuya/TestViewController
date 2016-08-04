//
//  TestView.h
//
//  Created by Yoo SeungHwan on 2016/08/04.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TestViewDelegate ;			// TestView の定義より後ろで定義しているので、
// ワーニングが出ないように先にコンパイラに存在だけ知らせる。

@interface TestView : UIView
{
	id<TestViewDelegate>	delegate ;	// ジェスチャー検出の通知先
	CGPoint	tapLocation ;				// タップ位置（TestView ローカル座標）
	BOOL	multipleTouches ;			// 複数の指が触れた場合に YES になる。全部の指が離れた時に NO にリセット
	BOOL	twoFingerTapIsPossible ;	// 2フィンガータップとみなされなくなった時に NO になる。全部の指が離れた時に YES にリセット
	BOOL	drawSelf ;					// NO なら drawRect を機能させない
    NSTimer*	toolViewTimer ;
}

@property (nonatomic, retain) id<TestViewDelegate> delegate ;
@property (readwrite) BOOL drawSelf ;

@end


#pragma mark -
// ---------------------------------------------------------------------------------
//	オリジナルのデリゲートメソッド定義
// ---------------------------------------------------------------------------------
@protocol TestViewDelegate<NSObject>

@optional
- (void)view:(TestView*)view singleTapAtPoint:(CGPoint)tapPoint ;
- (void)view:(TestView*)view doubleTapAtPoint:(CGPoint)tapPoint ;
- (void)view:(TestView*)view twoFingerTapAtPoint:(CGPoint)tapPoint ;

- (void)view:(TestView*)view longTouchAtPoint:(CGPoint)tapPoint ;

@end

