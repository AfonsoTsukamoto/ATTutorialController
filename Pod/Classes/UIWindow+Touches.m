//
//  UIWindow+UIWindow_Touches.m
//  FullTime
//
//  Created by Afonso Tsukamoto on 22/08/14.
//

#import <objc/runtime.h>

#import "UIWindow+Touches.h"


static const void *touchesDelegateKey = &touchesDelegateKey;

static void (*Original_touchesBeganMethod)(id, SEL, NSSet *, UIEvent *);

static void SwizzledTouchesBegan(id _self, SEL _cmd, NSSet *touches, UIEvent *event){
    if([_self touchesDelegate] != nil){
        if([[_self touchesDelegate] respondsToSelector:@selector(windowTouches:withEvent:)]){
            [[_self touchesDelegate] windowTouches:touches withEvent:event];
        }
    }
    return Original_touchesBeganMethod(_self, _cmd, touches, event);
}

@implementation UIWindow (Touches)

-(void)setTouchesDelegate:(id<UIWindowTouchesProtocol>)touchesDelegate
{
    objc_setAssociatedObject(self, touchesDelegateKey, touchesDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id<UIWindowTouchesProtocol>)touchesDelegate
{
    return objc_getAssociatedObject(self, touchesDelegateKey);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIWindow class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        SEL originalSelector = @selector(touchesBegan:withEvent:);
        //SEL swizzledSelector = @selector(swizzled_touchesBegan:withEvent:);
        
        IMP replacement = (IMP)SwizzledTouchesBegan;
        
        IMP *store = (IMP*)&Original_touchesBeganMethod;
        IMP originalImp = NULL;
        
        Method method = class_getInstanceMethod(class, originalSelector);
    
        if (method) {
            const char *type = method_getTypeEncoding(method);
            originalImp = class_replaceMethod(class, originalSelector, replacement, type);
            if (!originalImp) {
                originalImp = method_getImplementation(method);
            }
        }
        if (originalImp && store) { *store = originalImp; }
    });
}


@end