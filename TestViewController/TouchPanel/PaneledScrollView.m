//
//  PaneledScrollView.m
//
//  Created by Yoo SeungHwan on 2016/08/04.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PaneledScrollView.h"
#import "TestView.h"

@implementation PaneledScrollView

@synthesize panelSize ;
@synthesize panelContainerView ;
@synthesize dataSource ;
@synthesize defaultWidth ;
@synthesize defaultHeight ;

@synthesize leftFromRight ;


#define LABEL_TAG 3


// ---------------------------------------------------------------------------------
//	annotatePanel はデバッグ用
//	パネルの領域と番号を表示させる
// ---------------------------------------------------------------------------------
- (void)annotatePanel:(UIView*)panel
{
	static int totalPaneles = 0 ;
    
	UILabel* label = (UILabel*)[panel viewWithTag:LABEL_TAG] ;
	if ( !label )
	{
		++totalPaneles ;		// この番号は作成時で固定となる
		//UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake( 5, 5, 80, 50 )] ;
		[label setBackgroundColor:[UIColor whiteColor]] ;
		[label setTag:panel.tag] ;
		[label setTextColor:[UIColor blueColor]] ;
		[label setShadowColor:[UIColor yellowColor]] ;
		[label setShadowOffset:CGSizeMake( 1.0, 1.0 )] ;
		[label setFont:[UIFont boldSystemFontOfSize:20]] ;
		[label setText:[NSString stringWithFormat:@"%d", (int)panel.tag ] ] ;//totalPaneles]] ;
		[panel addSubview:label] ;
        
		[[panel layer] setBorderWidth:0.5] ;
		[[panel layer] setBorderColor:[[UIColor whiteColor] CGColor]] ;
	}
    
	[panel bringSubviewToFront:label] ;
}


// ---------------------------------------------------------------------------------
//	initWithFrame:
//		使っていないパネルビュー（パネル用 UIView ）保持用インスタンスの確保や、
//		表示パネル領域変数の初期化、タップ検出、およびパネルビュー埋め込み用ビューの埋め込みをおこなう
// ---------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
{
	if ( self = [super initWithFrame:frame] )
    {
        // 各パネル用 UIView は使い回すので、その管理用に NSMutableSet インスタンスを作成
		reusablePaneles = [[NSMutableSet alloc] init] ;
        
		// タップ検出用には、各パネルの UIView を使わず、全体を囲む UIView を用意する
        // ここでは以前用意した TestView を利用。ただし TestView は drawRect: を無効にした
		panelContainerView = [[TestView alloc] initWithFrame:CGRectZero] ;
        panelContainerView.backgroundColor = [ UIColor clearColor ] ;
		panelContainerView.drawSelf = NO ;		// drawRectを無効にする。
        
		[self addSubview:panelContainerView] ;
		//[self setPanelSize:CGSizeMake( defaultWidth, defaultHeight )] ;
        
		// 表示に必要な領域のパネルのインディックスを初期化。最初は空にする
		firstVisibleRow = firstVisibleColumn = (int)NSIntegerMax ;
		lastVisibleRow  = lastVisibleColumn  = (int)NSIntegerMin ;
		tagArray = [[NSMutableArray alloc] init] ;
        leftFromRight = NO ;
        
		// ズームに対する移譲を自分で管理することで、スケール別の画像切り替えを対応する
		[super setDelegate:self] ;
    }
    return	self ;
}


// ---------------------------------------------------------------------------------
//	現在利用されていない UIView があればそれを返す
//		nil を返す場合もある
// ---------------------------------------------------------------------------------
- (UIView*)dequeueReusablePanel
{
	UIView* panel = [reusablePaneles anyObject] ;		// どれでもいいから、あるやつを取り出す
	if ( panel )
	{
        //NSLog(@"panel->%@",panel);
        // 自動解放プールの管理外になったら release されるように設定
    	[reusablePaneles removeObject:panel] ;		// reusablePaneles から取り外す。ここで release が呼ばれる
    }
	return	panel ;
}


// ---------------------------------------------------------------------------------
//	reloadData
//	パネルビューを再設定する
//		現在 panelContainerView に埋め込まれている UIView はすべて取り外し reusablePaneles に
//		登録した上で layoutSubviews を呼び出す
// ---------------------------------------------------------------------------------
- (void)reloadData
{
	// 次の layoutSubviews 呼び出しで、panelContainerView に埋め込まれている UIView を
	// すべて再設定ため、現在埋め込まれている UIView はすべて取り外し reusablePaneles に登録する
	for ( UIView* view in [panelContainerView subviews] )
    {
		[reusablePaneles addObject:view] ;
		[view removeFromSuperview] ;
	}
	[tagArray removeAllObjects] ;
    
	// いったん、何もUIViewが無い状態に設定
	firstVisibleRow = firstVisibleColumn = (int)NSIntegerMax ;
	lastVisibleRow  = lastVisibleColumn  = (int)NSIntegerMin ;
    
	// layoutSubviewsを呼び出すよう命令
	[self setNeedsLayout] ;
}


// ---------------------------------------------------------------------------------
//	内容部を新しい内容に再設定
//	間接的にlayoutSubviewsが呼び出される
// ---------------------------------------------------------------------------------
- (void)reloadDataWithNewContentSize:(CGSize)size
							 realRow:(int)inMaxRow
						  realColumn:(int)inMaxColumn
{
	// panelContainerView の大きさも連動させる
	float	wHeight = 2901670.5 ;	// 現在調査中
	if ( wHeight < size.height )	// UIView のサイズをやや大きめに確保しようとすると、実メモリを消費するらしい
	{								// サイズを極大な値にすると、実メモリは消費せず、仮想的に行われる様子
		wHeight = size.height ;
	}
    [panelContainerView setFrame:CGRectMake( 0, 0, size.width, wHeight )] ;
    realRow = inMaxRow ;
	realColumn = inMaxColumn ;
    
    [ [dataSource mTestScrollView] setContentSize:CGSizeMake(size.width, size.height ) ] ;
    
    CGRect tmpRect = self.frame ;
    tmpRect.size.width = size.width ;
    tmpRect.size.height = size.height ;
    self.frame = tmpRect ;
    
    //    NSLog(@"resizeContentsize scrollview w:%f  h:%f",self.frame.size.width,self.frame.size.height);
    
    [ self setContentSize:CGSizeMake(tmpRect.size.width, size.height)];
    
	// パネルビューを再設定する
	[self reloadData] ;
}


// ---------------------------------------------------------------------------------
//	スクロール、ズームで呼ばれるメソッドの拡張
// ---------------------------------------------------------------------------------
- (void)layoutSubviews
{
	[super layoutSubviews] ;				// 元処理をおこなわせる。
    //	CGRect visibleBounds = [ self bounds ] ;	// 表示矩形
    CGRect visibleBounds = [[dataSource mTestScrollView] bounds ] ;
    defaultWidth = [dataSource panelSize].width ;
    defaultHeight = [dataSource panelSize].height ;
    //NSLog(@"w::%f   h::%f",visibleBounds.size.width,visibleBounds.size.height);
    
	NSInteger	theTag ;
	NSNumber*	tagNumber ;
    
	// panelContainerView に埋め込まれたパネル用 UIView のうち表示矩形外はすべて reusablePaneles に回収する
	for ( UIView* panel in [panelContainerView subviews] )
    {
		// パネル用 UIView が visibleBounds と交差しているかどうかを判断するため visibleBounds の座標系に変換する
		CGRect scaledPanelFrame = [panelContainerView convertRect:[panel frame]
														   toView:self] ;
		if ( !CGRectIntersectsRect( scaledPanelFrame, visibleBounds ) )
        {
			// 交差していないなら panelContainerView から取り外し reusablePaneles に移動させる
			[reusablePaneles addObject:panel] ;
			[panel removeFromSuperview] ;
		}
		else
		{
			[tagArray addObject:[NSNumber numberWithInteger:panel.tag]] ;
		}
	}
    
    
    CGSize panelSizeZoom = CGSizeMake(defaultWidth,defaultHeight) ;
    CGSize panelContainerViewSize = [panelContainerView frame].size ;
    
    panelContainerViewSize.width *= [ dataSource mTestScrollView ].zoomScale ;
    panelContainerViewSize.height *= [ dataSource mTestScrollView ].zoomScale ;
    
    panelSizeZoom.width *= [ dataSource mTestScrollView ].zoomScale ;
    panelSizeZoom.height *= [ dataSource mTestScrollView ].zoomScale ;
    
	// その大きさに基づいて、panelContainerView の内容を表示するにはいくつのパネルが必要か計算する
	int maxRow = MIN( realRow - 1, floorf( panelContainerViewSize.height / panelSizeZoom.height ) ) ;	// 縦表示に必要になる最大値（ゼロからカウント）
	int maxCol = MIN( realColumn - 1, floorf( panelContainerViewSize.width / panelSizeZoom.width  ) ) ;	// 横　〃　（ゼロからカウント）
    
	// 左、上、右、下のインディックスを計算する
	int firstNeededRow = MAX( 0, floorf( visibleBounds.origin.y / panelSizeZoom.height ) ) ;
	int firstNeededCol = MAX( 0, floorf( visibleBounds.origin.x / panelSizeZoom.width ) ) ;
	int lastNeededRow  = MIN( maxRow, floorf( CGRectGetMaxY( visibleBounds ) / panelSizeZoom.height ) ) ;
	int lastNeededCol  = MIN( maxCol, floorf( CGRectGetMaxX( visibleBounds ) / panelSizeZoom.width ) ) ;
    
	// このループは、新しく表示されるエリアに属するパネル用 UIView のループ
	// 以前の表示エリア内に存在していれば、パネル用 UIView はすでに存在し内容部の更新は不要
	// 存在しなければ新たに dataSource に内容部を更新したパネル用 UIView を用意してもらう必要がある
	for ( int row = firstNeededRow ; row <= lastNeededRow ; ++row )
    {
		for ( int col = firstNeededCol ; col <= lastNeededCol ; ++col )
        {
            //            NSLog(@"%d",row+col);
			BOOL needUpdateContents = YES ;
            
            // 対象の tag が決定
			if ( leftFromRight )
			{
				theTag = ( ( realColumn - ( col + 1 ) ) * realRow ) + row ;
			}
			else
			{
				theTag = col + ( row * ( maxCol + 1 ) ) ;
			}
            
			for ( tagNumber in tagArray )
			{
				// subviews に同じ tag があったかどうか
				if ( [tagNumber integerValue] == theTag )
				{
					// 同じ tag がある場合は、そのパネル用 UIView が存在する
					needUpdateContents = NO ;
					break ;
				}
			}
            
			if ( needUpdateContents )
            {
				// 新たに dataSource に内容部を更新したパネル用 UIView を用意してもらう必要がある
				UIView* panel = [dataSource paneledScrollView:self
												  panelForRow:row
													   column:col
												   resolution:0] ;
				// panelContainerView の適切な位置にパネル用 UIView を配置する
				CGRect frame = CGRectMake(defaultWidth  * col,
                                          defaultHeight * row,
                                          defaultWidth,
                                          defaultHeight ) ;
				[panel setFrame:frame] ;
				[panelContainerView addSubview:panel] ;
                
				[panel setTag:theTag] ;
                
				// デバッグ用にパネルの領域と番号を表示させる
                //Ori			[self annotatePanel:panel] ;
                
				// 枠を
                [[panel layer] setBorderWidth:1] ;
                
                //                [[panel layer] setCornerRadius:8];
                
                //#b0b0b0
                [[panel layer] setBorderColor:[[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.0] CGColor]] ;
                panel.backgroundColor = [ UIColor whiteColor ] ;
			}
		}
	}
	//	あたらしい表示エリアの設定。
	firstVisibleRow		= firstNeededRow ;
    firstVisibleColumn	= firstNeededCol ;
	lastVisibleRow		= lastNeededRow ;
    lastVisibleColumn	= lastNeededCol ;
	[tagArray removeAllObjects] ;
}

// ---------------------------------------------------------------------------------
//	zoomされた場合、もとに戻す作業
// ---------------------------------------------------------------------------------
- (void)inMinimumZoomScale
{
    defaultWidth = [dataSource panelSize].width ;
    defaultHeight = [dataSource panelSize].height ;
    
    [ [ dataSource mTestScrollView ]  setZoomScale:1.0 ] ;
    
    CGSize size = CGSizeMake( realColumn * defaultWidth , realRow * defaultHeight ) ;
    [ self reloadDataWithNewContentSize:size
                                realRow:realRow
                             realColumn:realColumn] ;
    
    [ dataSource resizeView ] ;
}

// ---------------------------------------------------------------------------------
//	UIScrollViewDelegateは自分が利用するので、他から設定されないようにする
// ---------------------------------------------------------------------------------
- (void)setDelegate:(id)delegate
{
    //NSLog( @"You can't set the delegate of a PaneledZoomableScrollView. It is its own delegate." ) ;
}

@end
