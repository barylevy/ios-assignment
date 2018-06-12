//
//  HorizontalScrollView.m
//  paykey-ios-interview
//
//  Created by Ishay Weinstock on 12/16/14.
//  Copyright (c) 2014 Ishay Weinstock. All rights reserved.
//

#import "HorizontalTableView.h"

#define SEPARATOR_WIDTH 1
#define DEFAULT_CELL_WIDTH 100

@implementation HorizontalTableView
{
	// number of visible items in scroll view frame
	int nVisibleItems;
	
	// dictunary holds the visible views
	NSMutableDictionary<NSNumber*,UIView*>* vContainer;
	
	//pull of tmp view that can be reused
	NSMutableArray<UIView*> *tmpViews;
	
	UIScrollView* scrollView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		scrollView = [[UIScrollView alloc] initWithFrame:frame];
		scrollView.alwaysBounceHorizontal = true;
		scrollView.delegate = self;
		[self addSubview:scrollView];
		vContainer = [[NSMutableDictionary alloc] init];
		tmpViews = [[NSMutableArray alloc] init];
		nVisibleItems = 0;
		self.cellWidth = DEFAULT_CELL_WIDTH;
	}
	return self;
}
- (UIView*)dequeueCell{
	
	UIView* view = [tmpViews firstObject];
	if( view != nil ){
		[tmpViews removeObject:view];
	}
	return view;
}
- (void)layoutSubviews{
	[super layoutSubviews];
	
	[self layoutScrollView];
	
	[self layoutAndAddCells];
}
-(void) layoutScrollView{
	int cellSpace = (self.cellWidth+SEPARATOR_WIDTH);
	long nItems = [self.dataSource horizontalTableViewNumberOfCells:self];
	scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[scrollView setContentSize:CGSizeMake(cellSpace*nItems, scrollView.frame.size.height)];
	nVisibleItems = scrollView.frame.size.width / cellSpace + 2;
	
}
-(void)layoutAndAddCells{
	int cellSpace = (self.cellWidth+SEPARATOR_WIDTH);
	int startCell = scrollView.contentOffset.x/cellSpace;
	
	for (int i = startCell; i < nVisibleItems+1; ++i) {
		UIView* v = [self reloadCellAtIndex:i];
		if (v.superview == nil) {
			[scrollView addSubview:v];
		}
	}
}
-(UIView*)reloadCellAtIndex:(int)index{
	UIView* v = [vContainer objectForKey:[NSNumber numberWithInt:index]];
	if (v == nil){
		int cellSpace = (self.cellWidth+SEPARATOR_WIDTH);
		
		v = [self.dataSource horizontalTableView:self cellForIndex:index];
		[vContainer setObject:v forKey:[NSNumber numberWithInt:index]];
		v.frame = CGRectMake(index*cellSpace, 0, self.cellWidth, self.frame.size.height);
	}
	return v;
}
@end

@interface HorizontalTableView (scroll) <UIScrollViewDelegate>
@end

@implementation HorizontalTableView (scroll)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSDictionary* iter = [[NSDictionary alloc] initWithDictionary:vContainer];
	for (NSNumber* key in iter) {
		[self layoutCellAt:key];
	}
}
-(void)layoutCellAt:(NSNumber*)index{
	
	long nItems = [self.dataSource horizontalTableViewNumberOfCells:self];
	int offset = scrollView.contentOffset.x;
	UIView* val = [vContainer objectForKey:index];
	int newIndex = 0;
	if(val != nil){
		if (val.frame.origin.x+val.frame.size.width < offset) {
			//MOVE FORWARD
			if (nItems > ( newIndex = [index intValue] + nVisibleItems + 1)){
				[vContainer removeObjectForKey:index];
				[tmpViews addObject:val];
				[self reloadCellAtIndex:newIndex];
			}
		}else
		if (val.frame.origin.x > offset + scrollView.frame.size.width + self.cellWidth) {
			//MOVE BACKWARD
			if( 0 <= (newIndex = [index intValue] - nVisibleItems - 1)){
				[vContainer removeObjectForKey:index];
				[tmpViews addObject:val];
				[self reloadCellAtIndex:newIndex];
			}
		}
	}
	
}
@end
