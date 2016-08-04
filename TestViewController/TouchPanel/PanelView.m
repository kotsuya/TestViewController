//
//  PanelView.m
//
//  Created by Yoo SeungHwan on 2016/08/04.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

#import "PanelView.h"
#import "PanelViewController.h"



// ---------------------------------------------------------------------------------
//	Extern
// ---------------------------------------------------------------------------------
extern int			gFontSizeNormal ;
extern CGFontRef	gPanelFont ;

@implementation PanelView

@synthesize	logicalOrigin ;
@synthesize maxRow ;
@synthesize maxColumn ;
@synthesize pController ;
@synthesize binLineCount ;
@synthesize binMaxLength ;



// ---------------------------------------------------------------------------------
//	initWithFrame: maxLength:
// ---------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
		  maxLength:(unsigned int)maxLength
{
    if ( self = [super initWithFrame:frame] )
    {
		logicalOrigin.x = 0 ;
		logicalOrigin.y = 0 ;
    }
    return	self ;
}


// ---------------------------------------------------------------------------------
//	drawRect:
//		自分の中の一番左上にある、全体の座標上での自身のピクセルグリッド位置にクロスラインと座標を表示する
// ---------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    CGContextSetFillColorWithColor( context, [UIColor whiteColor].CGColor ) ;
    
    //CGContextFillRect( context, self.bounds ) ;
    //CGContextSetFillColorWithColor( context, [UIColor blackColor].CGColor ) ;
    
    if ( self.tag < binLineCount )
    {
        id tmpObj = [ (PanelViewController*)pController getPanelDataAtIndex:self.tag ] ;
        if ( [tmpObj isKindOfClass:[ NSDictionary class ]] )
        {
            NSString* theStr = [ tmpObj objectForKey:@"Data" ] ;
            
            UIColor* color = [UIColor blackColor] ;
            UIFont*	mainFont = [ UIFont fontWithName:@"HiraMinProN-W6" size : 17 ];
            
            // パラグラフで文字の描画位置などを指定する
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineBreakMode = NSLineBreakByTruncatingTail;
            style.alignment = NSTextAlignmentLeft;
            
            // text の描画する際の設定(属性)を指定する
            NSDictionary *attributes = @{
                                         NSForegroundColorAttributeName : color,
                                         NSFontAttributeName : mainFont,
                                         NSParagraphStyleAttributeName : style
                                         };
            
            [ theStr drawInRect:CGRectInset( rect, 10, 10 )
                 withAttributes:attributes ] ;
        }
    }
}

@end
