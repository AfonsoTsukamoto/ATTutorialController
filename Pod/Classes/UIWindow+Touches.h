//
//  UIWindow+UIWindow_Touches.h
//  FullTime
//
//  Created by Afonso Tsukamoto on 22/08/14.
//
//  This is dangerous code :)
//
//  We used method swizzling on the ui window to allow the window to notify its delegate
//  when the touches began method is called.

#import <UIKit/UIKit.h>

@protocol UIWindowTouchesProtocol <NSObject>
@optional
-(void)windowTouches:(NSSet*)touches withEvent:(UIEvent *)event;
@end

@interface UIWindow (Touches)
@property (nonatomic, strong) id<UIWindowTouchesProtocol> touchesDelegate;
@end
