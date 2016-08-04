//
//  PaneledScrollView.h
//
//  Created by Yoo SeungHwan on 2016/08/04.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestView ;

@protocol PaneledScrollViewDataSource ;

@interface PaneledScrollView : UIScrollView
<UIScrollViewDelegate>
{
    id <PaneledScrollViewDataSource>	dataSource ;	// 指定された内容部を持つパネルビュー（パネル用 UIView ）を提供するインスタンス
    CGSize				panelSize ;				// パネルビューの大きさ
    TestView*			panelContainerView ;	// パネルビューを埋め込み束ねるビュー
    NSMutableSet*		reusablePaneles ;		// 現在利用していないパネルビューを保持するインスタンス
    int					realRow ;				// 実際指定の縦 row 数
	int					realColumn ;			// 実際指定の横 column 数
    int					firstVisibleRow ;		// 縦横のパネルの最小最大インディックス
	int					firstVisibleColumn ;
	int					lastVisibleRow ;
	int					lastVisibleColumn ;
	NSMutableArray*		tagArray ;
    
	CGFloat				defaultWidth ;
	CGFloat				defaultHeight ;
    
    BOOL				leftFromRight ;
}
@property (nonatomic, retain) id <PaneledScrollViewDataSource> dataSource ;
@property (nonatomic, assign) CGSize panelSize ;
@property (nonatomic, readonly) TestView*	panelContainerView ;
@property (nonatomic, assign) CGFloat	defaultWidth ;
@property (nonatomic, assign) CGFloat	defaultHeight ;

@property (nonatomic, assign) BOOL	leftFromRight ;

- (UIView*)dequeueReusablePanel ;	// 現在利用していないパネルビューがあれば返す。なければ nil を返す
- (void)reloadData ;
- (void)reloadDataWithNewContentSize:(CGSize)size
							 realRow:(int)inMaxRow
						  realColumn:(int)inMaxColumn ;

- (void)inMinimumZoomScale;

@end

#pragma mark -
// ---------------------------------------------------------------------------------
//	指定された内容部を持つパネルビューを提供するプロトコル
// ---------------------------------------------------------------------------------
@protocol PaneledScrollViewDataSource <NSObject>

@property (nonatomic, assign) UIScrollView* mTestScrollView ;
@property (nonatomic, assign) CGSize    panelSize ;

// 横 column 番目、縦 row 番目の内容部を持つパネルビューを返す
- (UIView*)paneledScrollView:(PaneledScrollView*)scrollView
				 panelForRow:(int)row
					  column:(int)column
				  resolution:(int)resolution ;

- (void)resizeView ;

@end


