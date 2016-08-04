//
//  PanelViewController.h
//

#import <UIKit/UIKit.h>

#import "PaneledScrollView.h"
#import "TestView.h"


@interface PanelViewController : UIViewController
<PaneledScrollViewDataSource, TestViewDelegate,UIScrollViewDelegate>
{
	PaneledScrollView*	scrollview ;	//	スクロールビュー
    
	CGSize			panelSize ;
	int				pvcRow ;
	int				pvcColumn ;
    
	unsigned int	binLineCount ;
	unsigned int	binMaxLength ;
    
    UIBarButtonItem*	closeButton ;
    
    NSMutableArray* mPanelDataArray ;
    NSDictionary*   mSelectedPanelDic ;
    
    NSString*       mTitleStr ;
    
    BOOL            mAniFlag ;
    CGRect          test ;
    
    UIScrollView*   mTestScrollView ;
    
    BOOL            mIsZooming ;
    BOOL            mIsDragging ;
    float           mThisScale ;
}

@property (nonatomic, assign) CGSize	panelSize ;

@property (nonatomic, retain) NSMutableArray* mPanelDataArray ;

@property (nonatomic, retain) UIScrollView*   mTestScrollView ;
@property (nonatomic, retain) PaneledScrollView*	scrollview ;	//	スクロールビュー

- (void)makeArrayData:(int)tag ;
- (void)makeBinData:(NSString*)tag;

- (id)getPanelDataAtIndex:(NSInteger)index;
- (void)panelViewDidPopview ;

@end

