//
//  PanelView.h
//
//  Created by Yoo SeungHwan on 2016/08/04.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PanelView : UIView
{
	CGPoint	logicalOrigin ;
    
    int				maxRow ;
	int				maxColumn ;
    
	unsigned int	binLineCount ;
	unsigned int	binMaxLength ;
    
    id				pController ;
}

@property (readwrite) CGPoint	logicalOrigin ;

@property (nonatomic, assign) int	maxRow ;
@property (nonatomic, assign) int	maxColumn ;

@property (nonatomic, assign) unsigned int	binLineCount ;
@property (nonatomic, assign) unsigned int	binMaxLength ;

@property (nonatomic, retain) id            pController ;


- (id)initWithFrame:(CGRect)frame
		  maxLength:(unsigned int)maxLength ;

@end
