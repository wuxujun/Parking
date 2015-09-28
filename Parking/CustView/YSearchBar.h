//
//  YSearchBar.h
//  Evaluation
//
//  Created by xujun wu on 13-9-4.
//  Copyright (c) 2013年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaseAppArc/UIViewExtention.h>

typedef enum{
    YSearchBarStateSearch,
    YSearchBarStateSearching,
    YSearchBarStateFinish
}YSearchBarState;

typedef enum{
    YSearchBarTypeWithCancelButton=1,
    YSearchBarTypeWithOutCancelButton
} YSearchBarType;


@protocol YSearchBarDelegate;

@interface YSearchBar : UIViewExtention{
    
}
@property (weak,nonatomic)id<YSearchBarDelegate> delegate;
@property (assign,nonatomic)YSearchBarType       searchBarType;
@property (strong,nonatomic)NSString             *placehoder;
@property (strong,nonatomic)NSString             *searchKey;

-(id)initWithFrame:(CGRect)frame type:(YSearchBarType)type;

-(IBAction)cancelButtonClicked:(UIButton*)cancelBtn;

-(void)cancelEditing;
-(void)begionEditing;

@end


@protocol YSearchBarDelegate <NSObject>

@optional
#pragma mark - Editing Text
-(void)searchBar:(YSearchBar*)searchBar textDidChange:(NSString *)searchText;
-(void)searchBarTextDidBeginEditing:(YSearchBar *)searchBar;
-(void)searchBarTextDidEndEditing:(YSearchBar*)searchBar;

#pragma mark Clicking Button
-(void)searchBarCancelButtonClicked:(YSearchBar*)searchBar;
-(void)searchBarSearchButtonClicked:(YSearchBar*)searchBar searchKey:(NSString*)searchKey;

@end

