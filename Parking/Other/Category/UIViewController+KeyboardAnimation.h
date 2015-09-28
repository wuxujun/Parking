//
//  UIViewController+KeyboardAnimation.h
//  Parking
//
//  Created by xujunwu on 15/9/21.
//  Copyright © 2015年 ___Hongkui___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KeyboardAnimation)

/**
 *  Block which contains user defined animations
 *
 *  @param keyboardRect Finish keyboard frame
 *  @param duration     Duration for keyboard showing animation
 *  @param isShowing    If isShowing is YES we handle keyboard showing, if NO we process keyboard dismissing
 */
typedef void(^ANAnimationsWithKeyboardBlock)(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing);

/**
 *  Block to handle a start point of animation, could be used for simultaneous animations OR for setting some flags for internal usage.
 *
 *  @param keyboardRect Finish keyboard frame
 *  @param duration     Duration for keyboard showing animation
 *  @param isShowing    If isShowing is YES we handle keyboard showing, if NO we process keyboard dismissing
 */
typedef void(^ANBeforeAnimationsWithKeyboardBlock)(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing);

/**
 *  Block to handle completion of keyboard animation
 *
 *  @param finished If NO animation was canceled during performing
 */
typedef void(^ANCompletionKeyboardAnimations)(BOOL finished);

/**
 *  Animation block will be called inside [UIView animateWithDuration:::::]
 *
 *  @tip viewWillAppear is the best place to subscribe to keyboard events
 *
 *  @param animations User defined animations. If using auto layout don't forget to call layoutIfNeeded
 *  @param completion User defined completion block, will be called when animation ends
 *
 *  @warning These blocks will he holding inside UIViewController which calls it, so as with any block-style API avoid a retain cycle
 */
- (void)an_subscribeKeyboardWithAnimations:(ANAnimationsWithKeyboardBlock)animations
                                completion:(ANCompletionKeyboardAnimations)completion;

/**
 *  Animation block will be called inside [UIView animateWithDuration:::::]
 *
 *  @tip viewWillAppear is the best place to subscribe to keyboard events
 *
 *  @param beforeAnimations Preanimation actions should be performed inside this block
 *  @param animations       User defined animations. If using auto layout don't forget to call layoutIfNeeded
 *  @param completion       User defined completion block, will be called when animation ends
 *
 *  @warning These blocks will he holding inside UIViewController which calls it, so as with any block-style API avoid a retain cycle
 */
- (void)an_subscribeKeyboardWithBeforeAnimations:(ANBeforeAnimationsWithKeyboardBlock)beforeAnimations
                                      animations:(ANAnimationsWithKeyboardBlock)animations
                                      completion:(ANCompletionKeyboardAnimations)completion;

/**
 *
 *  Call it to unsubscribe from keyboard events and clean all animations and completion blocks
 *
 *  @tip viewWillDisappear is the best place to call it
 *
 *  @warning If you will not call it when current view disappeared, subscribed view controller will handle keyboard events on other screens
 */
- (void)an_unsubscribeKeyboard;

@end
