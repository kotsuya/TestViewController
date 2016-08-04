//
//  TestView.m
//
//  Created by Yoo SeungHwan on 2016/08/04.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

#import "TestView.h"
#import "PanelViewController.h"

@implementation TestView

@synthesize delegate ;
@synthesize drawSelf ;

//extern int			pvcColumn ;
// ---------------------------------------------------------------------------------
//	initWithFrame:
// ---------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] )
    {
        [self setMultipleTouchEnabled:YES] ;
		twoFingerTapIsPossible = YES ;
		multipleTouches = NO ;
    }
    return	self ;
}


// ---------------------------------------------------------------------------------
//	drawRect:
// ---------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
	if ( drawSelf == NO )
    {
		return ;
    }
    
	CGContextRef context = UIGraphicsGetCurrentContext() ;
	CGContextSetRGBFillColor( context, 0.5, 0.5, 0.5, 1.0 ) ;
	CGContextSetRGBStrokeColor( context, 0.5, 0.5, 0.5, 1.0 ) ;
	UIFont* font = [UIFont systemFontOfSize:12] ;
    
    UIColor* color = [UIColor blackColor] ;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = NSTextAlignmentLeft;
    
    // text の描画する際の設定(属性)を指定する
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : color,
                                 NSFontAttributeName : font,
                                 NSParagraphStyleAttributeName : style
                                 };
    
    
	CGPoint origin = self.frame.origin ;
	double left = self.bounds.origin.x ;
	double top = self.bounds.origin.y ;
	double right = left + self.bounds.size.width ;
	double bottom = top + self.bounds.size.height ;
	for ( double v = top ; v < bottom ; v += 100.0 )
    {
		for ( double h = left ; h < right ; h += 100.0 )
        {
			NSString* str = [NSString stringWithFormat:@"-[%.0lf, %.0lf]",
                             h + origin.x,
                             v + origin.y] ;
            
            [ str drawAtPoint:CGPointMake(h, v)
               withAttributes:attributes ] ;
		}
	}
    
	for ( double v = top ; v < bottom ; v += 100.0 )
    {
		CGContextMoveToPoint( context, left, v ) ;
		CGContextAddLineToPoint( context, right, v ) ;
		CGContextStrokePath( context ) ;
	}
    
	for ( double h = left ; h < right ; h += 100.0 )
    {
		CGContextMoveToPoint( context, h, top ) ;
		CGContextAddLineToPoint( context, h, bottom ) ;
		CGContextStrokePath( context ) ;
	}
}

// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)setZoomScale:(double)inScale
{
}

// ---------------------------------------------------------------------------------
//	長押し
// ---------------------------------------------------------------------------------
-(void)longTouch
{
    if ( [delegate respondsToSelector:@selector(view:longTouchAtPoint:)] )
	{
		[delegate view:self
	  longTouchAtPoint:tapLocation] ;
	}
}

// ---------------------------------------------------------------------------------
//	シングルタップ
// ---------------------------------------------------------------------------------
- (void)handleSingleTap
{
	if ( [delegate respondsToSelector:@selector(view:singleTapAtPoint:)] )
	{
		[delegate view:self
	  singleTapAtPoint:tapLocation] ;
	}
}


// ---------------------------------------------------------------------------------
//	ダブルタップ
// ---------------------------------------------------------------------------------
- (void)handleDoubleTap
{
	if ( [delegate respondsToSelector:@selector(view:doubleTapAtPoint:)] )
	{
		[delegate view:self
	  doubleTapAtPoint:tapLocation] ;
	}
}


// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)handleTwoFingerTap
{
	if ( [delegate respondsToSelector:@selector(view:twoFingerTapAtPoint:)] )
	{
		[delegate view:self
   twoFingerTapAtPoint:tapLocation] ;
	}
}


#define DOUBLE_TAP_DELAY 0.0
// ---------------------------------------------------------------------------------
//	指が触れた
//	こちらはUIScrollViewに埋め込まれていてもいなくても、同じタイミングで呼び出される
// ---------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    //mZoomTouchLocation
    if ( [[[event allTouches] allObjects] count] == 2)
    {
        // 2本指でのジェスチャーで2本とも離れた。まず各指のタップ数を求める
        int		cnt = 0 ;
        int		tapCounts[2] ;
        CGPoint	tapLocations[2] ;
        for ( UITouch* touch in [[event allTouches] allObjects] )
        {
            tapCounts[cnt]    = (int)[touch tapCount] ;
            tapLocations[cnt] = [touch locationInView:self] ;
            ++cnt ;
        }
        
        //        if ( ( tapCounts[0] == 1 ) && ( tapCounts[1] == 1 ) )
        {
            // 両方の指ともシングルタップ
            [ self touchesCancelled:touches withEvent:event ];
            
            [ super touchesBegan:touches withEvent:event ];
            return ;
        }
    }
    
    
    if (toolViewTimer) return ;
    
	// もし、このメソッドの前に handleSingleTap が登録されていて実行待ちであれば
	// DOUBLE_TAP_DELAY 間隔のあいだに touchesBegan が2度来た事になる
	// それはダブルタップとみなすべきなので、handleSingleTap 登録は解除する
	// もともと登録が無ければ、この処理はなにも影響をおよぼさない
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(handleSingleTap)
                                               object:nil] ;
    
	// event から、現在追跡中の自分に対するタッチの数を得る事ができる
	// touches の方からは touchesBegan を引き起こした指の数だけしか得られない事に注意
	if ( [[event touchesForView:self] count] > 1 )
    {
        multipleTouches = YES ;
    }
    
	// 同じく、追跡中の自分に対するタッチの数が2より大きければ2フィンガータップとはならない
    if ( [[event touchesForView:self] count] > 2 )
    {
        twoFingerTapIsPossible = NO ;
    }
	//printf( "TestView touchesBegan (twoFingerTapIsPossible = %s) (multipleTouches = %s)\n",
	//		twoFingerTapIsPossible ? "YES" : "NO",
	//		multipleTouches ? "YES" : "NO" ) ;
    
    UITouch* touch = [touches anyObject] ;
    tapLocation = [touch locationInView:self] ;
    toolViewTimer = [ NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector( timerFiredToolView: )
                                                    userInfo:nil
                                                     repeats:YES ] ;
    
}


// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
static CGPoint	midpointBetweenPoints( CGPoint aa, CGPoint bb )
{
	CGFloat x = ( aa.x + bb.x ) / 2.0 ;
	CGFloat y = ( aa.y + bb.y ) / 2.0 ;
	return	CGPointMake( x, y ) ;
}


// ---------------------------------------------------------------------------------
//	指が離れた
//	UIScrollView に埋め込まれていると、予想外の順序で呼び出される
//	ここでは、UIScrollView に埋め込まれていない場合のシーケンスで対応している
// ---------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    if ( toolViewTimer )
	{
		[ toolViewTimer invalidate ] ;
		toolViewTimer = nil ;
	}
    
	// event から、現在追跡中の自分に対するタッチの数を得る事ができる。
	// この数と touches の数を比較する事で、最後の指が離れたかどうかを判定できる
	// 例えば2本の指が触れている状態から1本だけ指が離れた場合、
	//		[touches count] = 1
	//		[[event touchesForView:self] count] = 2
	//	で、すべての指が離れたとは言えない
    
    BOOL allTouchesEnded = ( [touches count] == [[event touchesForView:self] count] ) ;
    if ( !multipleTouches )
    {
		// まず、現在追跡中の自分に対するタッチの数が 1 である場合（シングルフィンガー）
        UITouch* touch = [touches anyObject] ;
        tapLocation = [touch locationInView:self] ;
        
		// タップの数で、シングルタップかダブルタップか判断して実行
        if ( [touch tapCount] == 1 )
        {
            [self performSelector:@selector(handleSingleTap)
                       withObject:nil
                       afterDelay:DOUBLE_TAP_DELAY] ;
        }
        else if( [touch tapCount] == 2 )
        {
            
            //2013.3.7
            return ;
            
            //[self handleDoubleTap] ;
        }
    }
    else if ( multipleTouches && twoFingerTapIsPossible )
    {
		// 2本指でのジェスチャー
        if ( [touches count] == 2 && allTouchesEnded )
        {
			// 2本指でのジェスチャーで2本とも離れた。まず各指のタップ数を求める
            int		cnt = 0 ;
            int		tapCounts[2] ;
			CGPoint	tapLocations[2] ;
            for ( UITouch* touch in touches )
            {
                tapCounts[cnt]    = (int)[touch tapCount] ;
                tapLocations[cnt] = [touch locationInView:self] ;
                ++cnt ;
            }
            if ( ( tapCounts[0] == 1 ) && ( tapCounts[1] == 1 ) )
            {
				// 両方の指ともシングルタップ
                tapLocation = midpointBetweenPoints( tapLocations[0], tapLocations[1] ) ;
                [self handleTwoFingerTap] ;
            }
        }
        else if ( [touches count] == 1 && !allTouchesEnded )
        {
			// あと1本、指が残っている
            UITouch* touch = [touches anyObject] ;
            if ( [touch tapCount] == 1 )
            {
                // 注意 1）残りの指が離れた時の準備
                tapLocation = [touch locationInView:self] ;
            }
            else
            {
				//	何回もタップされているので、もはや2フィンガータップにはならない
                twoFingerTapIsPossible = NO ;
            }
        }
        else if ( [touches count] == 1 && allTouchesEnded )
        {
			// 複数の指がタッチしていたが、順に離れていき、最後の指が離れた
            UITouch* touch = [touches anyObject] ;
            if ( [touch tapCount] == 1 )
            {
				// 注意 1）で保存しておいた最初に離れた方の指の座標を使って、最終的な tapLocation を決定
                tapLocation = midpointBetweenPoints( tapLocation, [touch locationInView:self] ) ;
                [self handleTwoFingerTap] ;
            }
        }
    }
    
	if ( allTouchesEnded )
	{
		// すべての指が離れたのでリセット
		twoFingerTapIsPossible = YES ;
		multipleTouches = NO ;
	}
    
    /*
     printf( "TestView touchesEnded (twoFingerTapIsPossible = %s) (multipleTouches = %s)\n",
     twoFingerTapIsPossible ? "YES" : "NO",
     multipleTouches ? "YES" : "NO" ) ;
     printf( "   [touches count] = %d\n   [[event touchesForView:self] count] = %d\n",
     [touches count],
     [[event touchesForView:self] count] ) ;
     printf( "   location = %f:%f\n", tapLocation.x, tapLocation.y ) ;
     int xx = (int)( tapLocation.x / gPanelWidth ) ; //106
     int yy = (int)( tapLocation.y / gPanelHeight ) ; //106
     printf( "   index = %d:%d\n", xx, yy ) ;
     */
    
    //何行目にあたるかは、　( xx + 1 ) + ( pvcColumn * yy )
    
    /*   int panelNum = 0 ;
     
     panelNum = ( xx + 1 ) + ( pvcColumn * yy );
     
     [ [ NSNotificationCenter defaultCenter ] postNotificationName:LVEDTouchPanelTouchEndNotification
     object:[ NSNumber numberWithInt:panelNum ]
     userInfo: nil ] ;
     */
    
}


// ---------------------------------------------------------------------------------
//	電話がかかったときではなく、UIScrollView がフリックやピンチを確認した時も送られてくる
// ---------------------------------------------------------------------------------
- (void)touchesCancelled:(NSSet*)touches
               withEvent:(UIEvent*)event
{
    if ( toolViewTimer )
	{
		[ toolViewTimer invalidate ] ;
		toolViewTimer = nil ;
	}
    
	// すべての指が離れたのでリセット
	twoFingerTapIsPossible = YES ;
	multipleTouches = NO ;
    //	printf( "TestView touchesCancelled (twoFingerTapIsPossible = %s) (multipleTouches = %s)\n",
    //				twoFingerTapIsPossible ? "YES" : "NO",
    //				multipleTouches ? "YES" : "NO" ) ;
}

// ---------------------------------------------------------------------------------
//	touchesMoved: withEvent:
// ---------------------------------------------------------------------------------
- (void)touchesMoved:(NSSet*)touches
		   withEvent:(UIEvent*)event
{
    if ( toolViewTimer )
	{
		[ toolViewTimer invalidate ] ;
		toolViewTimer = nil ;
	}
}


// ---------------------------------------------------------------------------------
//	長押し
// ---------------------------------------------------------------------------------
- (void)timerFiredToolView:(NSTimer*)timer
{
    [ toolViewTimer invalidate ] ;
    toolViewTimer = nil ;
    
    [self performSelector:@selector(longTouch)
               withObject:nil
               afterDelay:DOUBLE_TAP_DELAY] ;
}

@end
