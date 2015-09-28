//
//  YSearchBar.m
//  Evaluation
//
//  Created by xujun wu on 13-9-4.
//  Copyright (c) 2013年 xujun wu. All rights reserved.
//

#import "YSearchBar.h"

@interface YSearchBar()<UITextFieldDelegate>

@property (nonatomic,strong)UITextField         *textField;
@property (nonatomic,strong)UIButton            *cancelButton;
@property (nonatomic,strong)UIImageView         *searchIcon;

@property (assign,nonatomic)YSearchBarState     state;

@end

@implementation YSearchBar

-(void)initializeFields
{
    self.backgroundColor=[UIColor colorWithRed:242 green:123 blue:4 alpha:1.0];
    
    UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_search"]];
    [img setFrame:CGRectMake(5, 7, 30, 30)];
    if (IOS_VERSION_7_OR_ABOVE) {
        [img setFrame:CGRectMake(5, 27, 30, 30)];
    }
    [self addSubview:img];
    
    self.textField=[[UITextField alloc]init];
    [self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.textField setReturnKeyType:UIReturnKeySearch];
    [self addSubview:self.textField];
    
    self.cancelButton=[[UIButton alloc]init];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"pill_white"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"pill_white_pressed"] forState:UIControlStateHighlighted];
    
    [self addSubview:self.cancelButton];
    
    UIImageView *lineView1=[[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-2, self.frame.size.width, 2)];
    [lineView1 setImage:[UIImage imageNamed:@"navbar_shadow_portrait"]];
    [self addSubview:lineView1];
    
    [self reAdjustLayout];
}

- (id)initWithFrame:(CGRect)frame type:(YSearchBarType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeFields];
        
        self.searchBarType=type;
        self.state=YSearchBarStateFinish;
        
    }
    return self;
}


-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    CGFloat y=0.0;
    if (IOS_VERSION_7_OR_ABOVE) {
        y=20.0;
    }
    [self.textField setFrame:CGRectMake(35, (44-34)/2+y, self.frame.size.width-100, 34)];
    
    [self.cancelButton setFrame:CGRectMake(self.frame.size.width-60, (44-32)/2+y, 50, 32)];
    
}

-(void)setPlacehoder:(NSString *)placehoder
{
    _placehoder=placehoder;
    [self.textField setPlaceholder:_placehoder];
}

-(void)cancelButtonClicked:(UIButton *)cancelBtn
{
    [self.textField resignFirstResponder];

    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

-(void)cancelEditing
{
    [self.textField resignFirstResponder];
}

-(void)begionEditing
{
    [self.textField becomeFirstResponder];
    self.state=YSearchBarStateSearch;
}

#pragma mark - TextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text==nil||textField.text.length==0)
    {
        return NO;
    }
    [textField resignFirstResponder];
    self.searchKey=textField.text;
    if([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:searchKey:)])
    {
        [self.delegate searchBarSearchButtonClicked:self searchKey:self.searchKey];
    }
    
    return YES;
}


@end
