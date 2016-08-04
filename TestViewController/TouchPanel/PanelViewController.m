//
//  PanelViewController.m
//
//  Created by Yoo SeungHwan on 2016/08/04.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

#import "PanelViewController.h"
#import "TestView.h"
#import "PanelView.h"

#import <QuartzCore/QuartzCore.h>

// ---------------------------------------------------------------------------------
//	Global
// ---------------------------------------------------------------------------------
int		pvcRow = 20 ;
int		pvcColumn = 20 ;

@implementation PanelViewController

@synthesize panelSize ;
@synthesize mPanelDataArray ;
@synthesize mTestScrollView ;
@synthesize scrollview ;


#pragma mark -
// ---------------------------------------------------------------------------------
//	init
// ---------------------------------------------------------------------------------
- (id)init
{
	self = [super init] ;
	if ( self )
	{
    
	}
    
	return	self ;
}


// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)loadView
{
    if (mTitleStr != nil)
    {
        self.title = mTitleStr ;
    }
    
	[super loadView] ;
    
    CGRect	frame = [ [ UIScreen mainScreen ] bounds ] ;
    frame.origin.x = 0.0 ;
	frame.origin.y = 0.0 ;
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height );
    
    mTestScrollView = [ [ UIScrollView alloc ] initWithFrame:frame ] ;
    [ mTestScrollView setDelegate:self ] ;
    mTestScrollView.maximumZoomScale = 1.5 ;
    mTestScrollView.minimumZoomScale = 0.7 ;
    mTestScrollView.autoresizesSubviews = YES ;
    
    mTestScrollView.backgroundColor = [ UIColor grayColor ];
    
    mThisScale = 1.0 ;
    self.view = mTestScrollView ;
    
	scrollview = [PaneledScrollView alloc] ;
	scrollview.defaultWidth = panelSize.width ;
	scrollview.defaultHeight = panelSize.height ;

    scrollview.scrollEnabled = NO ;
    
    scrollview = [scrollview initWithFrame:mTestScrollView.frame] ;
    [scrollview setDataSource:self] ;
    [[scrollview panelContainerView] setDelegate:self] ; //testView.delegate->self
    [ scrollview setBackgroundColor: [ UIColor clearColor ] ] ;
    //	[self.view addSubview:scrollview] ;
    [ mTestScrollView addSubview:scrollview ] ;
    
    [ self setRowColumn ] ;
    [ self setPanelSize ] ;
    
    CGSize size = CGSizeMake( pvcColumn * panelSize.width, pvcRow * panelSize.height  ) ;
    [scrollview reloadDataWithNewContentSize:size
									 realRow:pvcRow
								  realColumn:pvcColumn] ;
    [scrollview setContentOffset:CGPointZero] ;
    
    [ self setScrollDirection:NO ] ;
    
    // 左側ボタン
    closeButton = [ [ UIBarButtonItem alloc ] initWithTitle:@"Close"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector( closeModalViewWithAnimation: ) ] ;
    
}

// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// ---------------------------------------------------------------------------------
//	viewWillAppear:
// ---------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    //    NSLog( @"%@ viewWillAppear", [ self description ] ) ;
    self.navigationItem.rightBarButtonItem = closeButton ;
    
    if ( mSelectedPanelDic == nil)
    {
        [ self resizeView ] ;
    }
}

// ---------------------------------------------------------------------------------
//	viewWillAppear:
// ---------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    if ( mSelectedPanelDic != nil)
    {
        [ [ UIApplication sharedApplication] beginIgnoringInteractionEvents ] ;
        [ self panelViewDidPopview ] ;
    }
    
    //    NSLog( @"%@ viewDidAppear", [ self description ] ) ;
}

// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)resizeView
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isVerticalScreen = YES ;
    if (orientation == UIDeviceOrientationLandscapeRight || orientation ==  UIDeviceOrientationLandscapeLeft)
    {
        isVerticalScreen = NO ;
    }
    
    CGSize size = CGSizeMake( pvcColumn * panelSize.width,
                             pvcRow * panelSize.height) ;
    
    CGRect displayFrame = self.navigationController.view.frame ;
    
    float displayFrameWidth  =  displayFrame.size.width ;
    float displayFrameHeight  = displayFrame.size.height ;
    float displayFrameOrignX = 0.0 ;
    float displayFrameOrignY = 0.0 ;
    
    CGRect mainFrame = [ [ UIScreen mainScreen ] bounds ] ;
    
    displayFrameWidth = mainFrame.size.width ;
    displayFrameHeight = mainFrame.size.height ;
    
    if(mTestScrollView.contentSize.width < displayFrameWidth )
    {
        displayFrameOrignX = (displayFrameWidth - mTestScrollView.contentSize.width ) /2  ;
    }
    
    [ mTestScrollView setFrame:CGRectMake(0,
                                          0,
                                          displayFrameWidth,
                                          displayFrameHeight) ] ;
    
    [scrollview reloadDataWithNewContentSize:size
									 realRow:pvcRow
								  realColumn:pvcColumn] ;
    
    [ mTestScrollView setContentSize:CGSizeMake(mTestScrollView.contentSize.width*mTestScrollView.zoomScale,
                                                mTestScrollView.contentSize.height*mTestScrollView.zoomScale)];
    [ scrollview setFrame:CGRectMake(displayFrameOrignX,
                                     displayFrameOrignY,
                                     mTestScrollView.contentSize.width,
                                     mTestScrollView.contentSize.height ) ]  ;
    
    [ scrollview setContentSize:CGSizeMake(mTestScrollView.contentSize.width,
                                           mTestScrollView.contentSize.height)];
}

#pragma mark -
// ---------------------------------------------------------------------------------
//	シングルタップ対応
//		なにもしない
// ---------------------------------------------------------------------------------
-     (void)view:(TestView*)view
singleTapAtPoint:(CGPoint)tapLocation
{
    if (mSelectedPanelDic) return ;
    
    if (scrollview.zooming) return ;
    
    UIView *selectedView = nil ;
    for (int i=0; i<[[ view subviews ]count]; i++)
    {
        selectedView = [[ view subviews ] objectAtIndex:i ] ;
        //        NSLog(@"selectedView->%@[%d]",selectedView,i);
        if ( (selectedView.frame.origin.x < tapLocation.x)&&
            (tapLocation.x < selectedView.frame.size.width + selectedView.frame.origin.x ))
        {
            if ( (selectedView.frame.origin.y < tapLocation.y)&&
                (tapLocation.y < selectedView.frame.size.height + selectedView.frame.origin.y ))
            {
                break ;
            }
        }
    }
    
    if ( selectedView.tag >= binLineCount )
    {
        return ;
    }
    
    //TEST
    //切替に時間を置くのとビジュアル的なアニメーション
    [ UIView beginAnimations : @"Anima_SheetChange"
                     context : NULL ];
    [ UIView setAnimationDelegate : nil ];
    [ UIView setAnimationDuration:0.3 ];	// アニメーションの時間
    [ UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight
                            forView: selectedView cache: NO ] ;
    
    mSelectedPanelDic = [ [ NSDictionary alloc ] initWithObjectsAndKeys:
                         [ NSString stringWithFormat:@"%f", selectedView.frame.origin.x] , @"orignX",
                         [ NSString stringWithFormat:@"%f", selectedView.frame.origin.y] , @"orignY",
                         selectedView, @"view",
                         nil ] ;
    
    [ selectedView setBackgroundColor:[ UIColor whiteColor ] ];
    
    [ UIView commitAnimations ];
    ////
    
    if ( [[ mPanelDataArray objectAtIndex:selectedView.tag ] objectForKey:@"child" ])
    {
        [ self performSelector:@selector(addPanelViewDidAnimation:)
					withObject:mSelectedPanelDic
					afterDelay:0.15];
    }
    else
    {
        [ self performSelector:@selector(addDetailViewDidAnimation:)
                    withObject:mSelectedPanelDic
                    afterDelay:0.15];
    }
}

// ---------------------------------------------------------------------------------
//	長押し対応
//		tapLocation を scrollView zoomScale 1.0に戻す
// ---------------------------------------------------------------------------------
- (void)view:(TestView*)view longTouchAtPoint:(CGPoint)tapPoint
{
    if (mTestScrollView.zoomScale != 1.0)
    {
        CGRect r ;
        r.size.height = mTestScrollView.frame.size.height ;// / mTestScrollView.zoomScale ;
        r.size.width  = mTestScrollView.frame.size.width ;// / mTestScrollView.zoomScale ;
        r.origin.x = tapPoint.x - ( r.size.width  / 2.0 ) ;
        r.origin.y = tapPoint.y - ( r.size.height / 2.0 ) ;
        
        [ scrollview inMinimumZoomScale ] ;
        //        [ self resizeView ] ;
        
        [ mTestScrollView scrollRectToVisible:r animated:NO ] ;
    }
    
}

// ---------------------------------------------------------------------------------
//	ダブルタップ対応
//		tapLocation を中心にズームアウトする
// ---------------------------------------------------------------------------------
-	  (void)view:(TestView*)view
doubleTapAtPoint:(CGPoint)tapLocation
{
    //Cancel
    return ;
    ///////////////
  /*
    CGRect r ;
	r.size.height = scrollview.frame.size.height * 0.5 ;
    r.size.width  = scrollview.frame.size.width  * 0.5 ;
	r.origin.x = tapLocation.x - ( r.size.width  / 2.0 ) ;
    r.origin.y = tapLocation.y - ( r.size.height / 2.0 ) ;
    [scrollview zoomToRect:r
                  animated:YES] ;
   */
}


// ---------------------------------------------------------------------------------
//	2フィンガータップ対応
//		tapLocation を中心に 1：1 に戻す
// ---------------------------------------------------------------------------------
-        (void)view:(TestView*)view
twoFingerTapAtPoint:(CGPoint)tapLocation
{
    CGRect r ;
	r.size.height = scrollview.frame.size.height ;
    r.size.width  = scrollview.frame.size.width ;
	r.origin.x = tapLocation.x - ( r.size.width  / 2.0 ) ;
    r.origin.y = tapLocation.y - ( r.size.height / 2.0 ) ;
    [scrollview zoomToRect:r
                  animated:YES] ;
}

#pragma mark -
// ---------------------------------------------------------------------------------
//	指定された縦横インディックスに利用する UIView を返す
// ---------------------------------------------------------------------------------
- (UIView*)paneledScrollView:(PaneledScrollView*)paneledScrollView
				 panelForRow:(int)row
					  column:(int)column
				  resolution:(int)resolution
{
	// まず、再利用可能なUIImageViewがあるか確認
	PanelView* panel = (PanelView*)[scrollview dequeueReusablePanel] ;
	if ( !panel )
    {
		// frame は PaneledScrollView 側が調整するので気にせず CGRectZero を指定しておく
		panel = [[PanelView alloc] initWithFrame:CGRectZero
                                       maxLength:binMaxLength] ;
        panel.pController = self ;
        
		panel.binLineCount = binLineCount ;
		panel.binMaxLength = binMaxLength ;
        panel.maxColumn = pvcColumn ;
        
		// パネルの右や、下は、内容部が無い場合がある
		// この時に UIView が内容部をスケーリングしてしまうのを止める
		[panel setContentMode:UIViewContentModeTopLeft] ;
	}
	panel.logicalOrigin = CGPointMake(column * paneledScrollView.panelSize.width,
                                      row * paneledScrollView.panelSize.height ) ;
	[panel setNeedsDisplay] ;
    return	panel ;
}


#pragma mark -
// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)addPanelViewDidAnimation:(NSDictionary*)dic
{
    UIView* view = [ dic objectForKey:@"view" ] ;
    
    PanelViewController* panelViewController = [[PanelViewController  alloc] init] ;
    [self.navigationController pushViewController:panelViewController
                                         animated:YES ] ;
    [ panelViewController makeArrayData:(int)view.tag ] ;
}

// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)addDetailViewDidAnimation:(NSDictionary*)dic
{
    //NSLog( @"tag intValue -> %d", [tag intValue ] ) ;
    
    /*
     int	uiSize = sizeof( unsigned int ) ;
     
     DWORD block= 0;
     DWORD offset = 0 ;
     size_t	pos = uiSize * 2  + (( uiSize * 2 + binMaxLength )* [ tag intValue ]) ;
     
     lseek( binFD, pos, SEEK_SET );
     read(binFD, &block,  uiSize);
     
     read(binFD, &offset, uiSize );
     
     if ( block > 0 )
     {
     gFromPanelAction = YES ;
     [ gBrowserController showDetailByBlockOffset:(int)block offset:(int)offset ] ;
     }*/
}

// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)panelViewDidPopview
{
    if (mSelectedPanelDic != nil)
    {
        //TEST
        UIView* view = [ mSelectedPanelDic objectForKey:@"view" ] ;
        
        //切替に時間を置くのとビジュアル的なアニメーション
        [ UIView beginAnimations : @"Anima_SheetChange"
                         context : NULL ];
        [ UIView setAnimationDelegate : self ];
        [ UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:) ];
        
        [ UIView setAnimationDuration:0.2 ];	// アニメーションの時間
        [ UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft
                                forView: view cache: NO ] ;
        
        [ view setBackgroundColor:[ UIColor whiteColor ] ];
        
        [ UIView commitAnimations ];
        ////
        
        mSelectedPanelDic = nil ;
        
        /*
         UIView* view = [ mSelectedPanelDic objectForKey:@"view" ] ;
         [ self.view bringSubviewToFront:view ] ;
         
         [ UIView beginAnimations : @"kAnimKey_SetSelect"
         context : NULL ];
         
         [ UIView setAnimationDelegate : self ];
         [ UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:) ];
         
         //modalView animationのせいで少し長くする
         float animatinSec = 0.3 ;
         
         [ UIView setAnimationDuration:animatinSec ];	// アニメーションの時間
         
         CGAffineTransform transfarm = view.transform ;
         transfarm.a /= 1.1 ;
         transfarm.d /= 1.1 ;
         view.transform = transfarm ;
         
         CGRect tmpRect = view.frame ;
         tmpRect.origin.x = [[ mSelectedPanelDic objectForKey:@"orignX" ] floatValue ] ;
         tmpRect.origin.y = [[ mSelectedPanelDic objectForKey:@"orignY" ] floatValue ] ;
         view.frame = tmpRect ;
         
         [ UIView commitAnimations ];
         
         [ mSelectedPanelDic release ] ;
         mSelectedPanelDic = nil ;
         */
    }
    
}

// -----------------------------------------------------------------------------
//	panelViewDidPopview animationが終わった後
// -----------------------------------------------------------------------------
- (void)animationFinished:(NSString *)animationID
                 finished:(BOOL)finished
                  context:(void *)context
{
    while( [[UIApplication sharedApplication] isIgnoringInteractionEvents] )
    {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
}

// ---------------------------------------------------------------------------------
// close:
// ---------------------------------------------------------------------------------
- (void)closeModalViewWithAnimation:(id)sender
{
    [ self dismissViewControllerAnimated:YES
                              completion:nil ] ;
}


#pragma mark -
// ---------------------------------------------------------------------------------
//	getPanelDataAtIndex
// ---------------------------------------------------------------------------------
- (id)getPanelDataAtIndex:(NSInteger)index
{
    if ([ mPanelDataArray count ] < index)
    {
        return nil ;
    }
    return  [mPanelDataArray objectAtIndex:index] ;
}

// ---------------------------------------------------------------------------------
//	menu.plistから dataArrayを作成
// ---------------------------------------------------------------------------------
- (void)makeArrayData:(int)tag
{
    if ([self.navigationController.viewControllers count ] == 1) //topPage
    {
        NSString*	plistPath = [[NSBundle mainBundle] pathForResource:@"Panel"
                                                                ofType:@"plist"] ;
        mPanelDataArray = [ [ NSMutableArray alloc ] initWithContentsOfFile:plistPath ] ;
        mTitleStr = @"PANEL" ;
    }
    else //
    {
        NSArray* aaa = self.navigationController.viewControllers ;
        id visibleObject = [aaa objectAtIndex:[ aaa count ]-2] ;
        NSArray* tmpArray = [ [ NSArray alloc ] initWithArray: [ visibleObject mPanelDataArray ] ] ;
        mPanelDataArray = [ [NSMutableArray alloc] initWithArray:[[ tmpArray objectAtIndex:tag ] objectForKey:@"child"] ] ;
        mTitleStr = [[ tmpArray objectAtIndex:tag ] objectForKey:@"Title" ] ;
    }
    
    binLineCount = (int)[ mPanelDataArray count ] ;
}



// ---------------------------------------------------------------------------------
//	.bin から読み込み準備
// ---------------------------------------------------------------------------------
- (void)makeBinData:(NSString*)tag
{
   /*
	if ( ( binFD = open( [binPath UTF8String], O_RDONLY ) ) == -1 )
	{
		NSLog( @"BIN open error." ) ;
	}
	read( binFD, &binLineCount, sizeof( unsigned int) ) ;
	read( binFD, &binMaxLength, sizeof( unsigned int) ) ;
	if ( binLineCount == 0 || binMaxLength == 0 )
	{
		NSLog( @"BIN format error." ) ;
	}
    */
    
}

// ---------------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------------
- (void)setRowColumn
{
    int		minRow = 2 ;
    int		minCol = 2 ;
    
    if ( [mTitleStr isEqualToString:@"ABC" ] )
    {
        pvcRow = 7 ;
        pvcColumn = 4 ;
    }
    else if ( [mTitleStr isEqualToString:@"50" ] )
    {
        pvcRow = 10 ;
        pvcColumn = 5 ;
    }
    else
    {
        if ( (minRow * minCol) < binLineCount)
        {
            BOOL isOK = YES ;
            while ((minRow * minCol) < binLineCount)
            {
                if (isOK) minRow++ ;
                else minCol++ ;
                
                isOK = !isOK ;
            }
            
            pvcColumn = minCol ;
            pvcRow = minRow ;
        }
        else
        {
            pvcColumn = minCol ;
            pvcRow = minRow ;
        }
    }
//    NSLog(@"pvcColumn->%d  pvcRow->%d",pvcColumn,pvcRow);
}

// ---------------------------------------------------------------------------------
//  panelSize get set
// ---------------------------------------------------------------------------------
- (void)setPanelSize
{
    //    NSLog( @"PanelViewCont :%s ==> %d", __FUNCTION__, __LINE__ ) ;
    CGRect frame = self.navigationController.view.frame ;
    
    if ( [mTitleStr isEqualToString:@"ABC" ] )
    {
        panelSize.width = (frame.size.width)/4 ;
        panelSize.height = (frame.size.width)/4 ;
    }
    else if ( [mTitleStr isEqualToString:@"50" ] )
    {
        panelSize.width = (frame.size.width)/5 ;
        panelSize.height = (frame.size.width)/5 ;
    }
    else
    {
        if (binLineCount <= 10)
        {
            panelSize.width = frame.size.width ;
            panelSize.height = ( frame.size.height - ( 44 + 20.0 ) ) / binLineCount ;
            
            if (binLineCount > 5)
            {
                panelSize.width /= 2 ;
                panelSize.height *= 2 ;
            }
        }
        else
        {
            panelSize.width = 160 ;
            panelSize.height = 100 ;
        }
    }
}

// ---------------------------------------------------------------------------------
//	縦組はスクロールを右から表示させる
// ---------------------------------------------------------------------------------
- (void)setScrollDirection:(BOOL)leftFromRight
{
	scrollview.leftFromRight = leftFromRight ;
    
	if ( leftFromRight )
	{
		CGSize size = CGSizeMake( pvcColumn * panelSize.width, pvcRow * panelSize.height ) ;
        [mTestScrollView scrollRectToVisible:CGRectMake( size.width - panelSize.width,
                                                        0.0,
                                                        panelSize.width,
                                                        panelSize.height )
                                    animated:NO] ;
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate
// ---------------------------------------------------------------------------------
//	scrollViewDidScroll:
//		dragging,zooming,tapの最後には必ず来るから
// ---------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    //    NSLog(@"mTestScrollView.bounces->%@",mTestScrollView.bounces?@"YES":@"NO");
    //(scrollView.zooming)で足りないので...
    if (mIsZooming) return ;
    
    //(scrollView.dragging)で足りないので
    if (mIsDragging || mTestScrollView.bounces)
    {
        //        NSLog(@"scrollViewDidScroll");
        [ scrollview layoutSubviews];
    }
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    mIsDragging = YES ;
    //    NSLog(@"scrollViewWillBeginDragging");
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    mIsDragging = NO ;
    //    NSLog(@"scrollViewDidEndDragging");
}


// ---------------------------------------------------------------------------------
//	viewForZoomingInScrollView
// ---------------------------------------------------------------------------------
- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return scrollview ;
}

// ---------------------------------------------------------------------------------
//	scrollViewWillBeginZooming :
// ---------------------------------------------------------------------------------
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView
                          withView:(UIView *)view // called before the scroll view begins zooming its content
{
    //    NSLog(@"scrollViewWillBeginZooming");
    mIsZooming = YES ;
}

// ---------------------------------------------------------------------------------
//	scrollViewDidZoom :scrollView scrolling
// ---------------------------------------------------------------------------------
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //    NSLog(@"scrollViewDidZoom");
}

// ---------------------------------------------------------------------------------
//	scrollViewDidEndZooming :
// ---------------------------------------------------------------------------------
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
					   withView:(UIView *)view
						atScale:(CGFloat)scale
{
    //    NSLog(@"scrollViewDidEndZooming");
    mIsZooming = NO ;
    [ scrollview layoutSubviews];
    mThisScale = scale ;
    
    //resizeView
    if (mTestScrollView.contentSize.width < mTestScrollView.frame.size.width)
    {
        [ self resizeView ] ;
    }
}

@end
