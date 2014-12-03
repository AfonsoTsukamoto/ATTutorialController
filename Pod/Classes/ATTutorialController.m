//
//  TutorialController.m
//  FullTime
//
//  Created by Afonso Tsukamoto on 20/08/14.
//

#import "ATTutorialController.h"
#import <Shimmer/FBShimmering.h>
#import <Shimmer/FBShimmeringView.h>
#import "UIWindow+Touches.h"

@interface ATTutorialController()<UIWindowTouchesProtocol>
@property (nonatomic, strong) UIWindow *mainWindow;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) CAShapeLayer *mask;
@property (nonatomic, strong) UILabel *tutorialLabel;
@property (nonatomic, strong) FBShimmeringView *shimmerLabel;
@property (nonatomic, strong) NSArray *framesAndStrings;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizer;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, copy) NSArray* (^frameAndStringsBlock)();
@property (nonatomic, copy) void (^completionBlock)();
@property (nonatomic, readwrite) NSInteger currentStep;
@property (nonatomic, readwrite) BOOL showingOrShowed;
@property (nonatomic, readwrite) BOOL firstTouchForTutorialStart;
@property (nonatomic, readwrite) BOOL waitsForTouches;
@property (nonatomic, readwrite) BOOL hasLabelPosition;
@end

@implementation ATTutorialController
@synthesize labelPosition = _labelPosition;

+(instancetype) sharedInstance{
    static ATTutorialController *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATTutorialController alloc] init];
    });
    
    // Make sure a window is alloced when used.
    if(sharedInstance.window == nil){
        [sharedInstance customInit];
    }
    return sharedInstance;
}

-(instancetype)init{
    if((self = [super init])){
        self.hasLabelPosition = NO;
        [self customInit];
    }
    return self;
}

-(void)setLabelPosition:(CGRect)labelPosition{
    _labelPosition = labelPosition;
    self.hasLabelPosition = YES;
}

-(UIWindow *)customInit{
    // Setup the text for the shimmer label
    self.shimmerLabelText = self.shimmerLabelText == nil ? @"Swipe or Tap" : self.shimmerLabelText;
    
    // Keep a reference to the main window
    self.mainWindow = [[[UIApplication sharedApplication]windows] firstObject];
    
    // Style the new window
    self.window = [[UIWindow alloc] initWithFrame:[self windowFrame]];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = UIWindowLevelAlert;
    [self.window setTouchesDelegate:self];
    [self.window setMultipleTouchEnabled:YES];
    
    // Add a background view to the tutorial
    self.backgroundView = [[UIView alloc] initWithFrame:[self windowFrame]];
    self.backgroundView.alpha = 0;
    [self.window addSubview:self.backgroundView];
    [self setUpMask];
    return self.window;
}

-(CGRect)windowFrame{
    return [[[[UIApplication sharedApplication]windows] firstObject] frame];
}

-(void)setUpMask{
    self.mask = [CAShapeLayer layer];
    [self.mask setFillRule:kCAFillRuleEvenOdd];
    [self.mask setFillColor:[[UIColor colorWithRed:19.0/255.0 green:19.0/255.0 blue:19.0/255.0 alpha:0.85] CGColor]];
    [self.backgroundView.layer addSublayer:self.mask];
}

-(UILabel *)labelForTutorialWithText:(NSString *)title{
    UILabel *label = [[UILabel alloc]initWithFrame: self.hasLabelPosition ? self.labelPosition : CGRectMake(20.0, 300.0, 280.0, 100.0)];
    [label setFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:title];
    [label setNumberOfLines:4];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

-(FBShimmeringView *)labelForTutorialSwipe{
    CGRect frame = (CGRect){
        {0, ((self.window.frame.size.height) - (60.0 + 20.0))}, // 60 = height of the label. 20 is the margin to the bottom.
        {self.window.frame.size.width, 60.0}
    };
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:self.shimmerLabelText];
    [label setBackgroundColor:[UIColor clearColor]];
    
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:frame];
    shimmeringView.contentView = label;
    return shimmeringView;
}

-(void)setUpForShow{
    // Making reallyyyyyy sure :)
    if(self.window == nil){
        [self customInit];
    }
    
    self.backgroundView.alpha = 0;
    [self.window setMultipleTouchEnabled:YES];
    [self.window makeKeyAndVisible];
    
    self.showingOrShowed = NO;
    
    if(!self.waitsForTouches){
        [self launchBasicTutorialAnimationWithFrames:[self framesForAnimation] andStrings:[self stringsForAnimation]];
        self.waitsForTouches = YES;
        self.firstTouchForTutorialStart = YES;
    }
}

#pragma mark - GetterForFrames

-(NSArray *)framesForAnimation{
    NSArray *iterated;
    if(self.frameAndStringsBlock){ iterated = self.frameAndStringsBlock();}
    else{ iterated = self.framesAndStrings; }
    __block NSMutableArray *mutableFrames = [NSMutableArray new];
    [iterated enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSValue *val = [obj objectForKey:@"frame"];
        if(val)
            [mutableFrames addObject:val];
    }];
    return mutableFrames;
}

-(NSArray *)stringsForAnimation{
    NSArray *iterated;
    if(self.frameAndStringsBlock){ iterated = self.frameAndStringsBlock();}
    else{ iterated = self.framesAndStrings; }
    __block NSMutableArray *mutableStrings = [NSMutableArray new];
    [iterated enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSValue *val = [obj objectForKey:@"string"];
        if(val)
            [mutableStrings addObject:val];
    }];
    return mutableStrings;
}

#pragma mark - Tutorial Public Methods

-(void)showTutorialWithFramesAndStrings:(NSArray*)framesAndStrings{
    self.framesAndStrings = [framesAndStrings copy];
    [self setUpForShow];
}

-(void)showTutorialWithFramesAndStrings:(NSArray*)framesAndStrings waitsForTouch:(BOOL)waits{
    self.waitsForTouches = waits;
    [self showTutorialWithFramesAndStrings:framesAndStrings];
}

-(void)showTutorialWithFramesAndStrings:(NSArray*)framesAndStrings completion:(void(^)())completion{
    self.completionBlock = completion;
    [self showTutorialWithFramesAndStrings:framesAndStrings];
}

-(void)showTutorialWithFramesAndStrings:(NSArray*)framesAndStrings completion:(void(^)())completion waitsForTouch:(BOOL)waits{
    self.waitsForTouches = waits;
    [self showTutorialWithFramesAndStrings:framesAndStrings completion:completion];
}

-(void)showTutorialWithFramesAndStringsBlock:(NSArray*(^)())framesAndStringsBlock{
    self.frameAndStringsBlock = framesAndStringsBlock;
    [self setUpForShow];
}

-(void)showTutorialWithFramesAndStringsBlock:(NSArray*(^)())framesAndStringsBlock completion:(void(^)())completion{
    self.completionBlock = completion;
    [self showTutorialWithFramesAndStringsBlock:framesAndStringsBlock];
}

-(void)showTutorialWithFramesAndStringsBlock:(NSArray*(^)())framesAndStringsBlock completion:(void(^)())completion waitsForTouch:(BOOL)waits{
    self.waitsForTouches = waits;
    [self showTutorialWithFramesAndStringsBlock:framesAndStringsBlock completion:completion];
    
}

#pragma mark - Tutorial Animations

-(void)animateCutAtRectToValue:(NSValue*)val{
    CGRect rect = [val CGRectValue];
    [self animateCutAtRectToRect:rect];
}

-(void)animateTutorialAppearWithPendingAnimation:(void(^)())animation{
    self.backgroundView.alpha = 0.0;
    [UIView beginAnimations: @"fade-in" context: nil];
    self.backgroundView.alpha = 1;
    animation();
    [UIView commitAnimations];
}

-(void)animateTutorialAppear{
    [self animateTutorialAppearWithPendingAnimation:^{
    }];
}

// For this piece of code you should check
// https://github.com/modocache/MDCFocusView
-(void)animateCutAtRectToRect:(CGRect)rect{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.backgroundView.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0f];
    [maskPath appendPath:cutoutPath];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = 1.0;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(self.mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [self.mask addAnimation:anim forKey:@"path"];
    self.mask.path = maskPath.CGPath;
}

-(void)launchBasicTutorialAnimationWithFrames:(NSArray*)frames andStrings:(NSArray *)strings{
    if(frames.count != strings.count){
        [NSException raise:@"Wrong number of strings/frames" format:@"Missing fields"];
    }
    
    self.showingOrShowed = YES;
    
    [self setCutAtRect:[(NSValue*)frames[0] CGRectValue]];
    
    self.tutorialLabel = [self labelForTutorialWithText:strings[0]];
    [self.backgroundView addSubview:self.tutorialLabel];
    
    self.shimmerLabel = [self labelForTutorialSwipe];
    [self.backgroundView addSubview:self.shimmerLabel];
    
    CGFloat prevX = self.tutorialLabel.frame.origin.x;
    [self.tutorialLabel setFrame:(CGRect){
        {self.window.frame.size.width, self.tutorialLabel.frame.origin.y},
        {self.tutorialLabel.frame.size.width, self.tutorialLabel.frame.size.height}
    }];
    
    [self.tutorialLabel setNumberOfLines:0];
    
    [self animateTutorialAppearWithPendingAnimation:^{
        [self.tutorialLabel setFrame:(CGRect){
            {prevX, self.tutorialLabel.frame.origin.y},
            {self.tutorialLabel.frame.size.width, self.tutorialLabel.frame.size.height}
        }];
    }];
    
    self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOrTapInWindow:)];
    self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionLeft;
    [self.window addGestureRecognizer:self.swipeRecognizer];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(swipeOrTapInWindow:)];
    [self.window addGestureRecognizer:self.tapRecognizer];
    
    self.currentStep = 0;
    self.shimmerLabel.shimmering = YES;
    
}


-(void)animateToNextTutorialStep{
    self.shimmerLabel.shimmering = NO;
    
    [self animateCutAtRectToValue:[self framesForAnimation][self.currentStep]];
    CGFloat prevX = self.tutorialLabel.frame.origin.x;
    [UIView animateWithDuration:.5 delay:.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.tutorialLabel setFrame:(CGRect){
            {-self.window.frame.size.width, self.tutorialLabel.frame.origin.y},
            {self.tutorialLabel.frame.size.width, self.tutorialLabel.frame.size.height}
        }];
    } completion:^(BOOL finished) {
        if([self stringsForAnimation].count != 0){
            self.tutorialLabel.text = [self stringsForAnimation][self.currentStep];
            [self.tutorialLabel setFrame:(CGRect){
                {self.window.frame.size.width, self.tutorialLabel.frame.origin.y},
                {self.tutorialLabel.frame.size.width, self.tutorialLabel.frame.size.height}
            }];
            [UIView animateWithDuration:.5 delay:.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.tutorialLabel setFrame:(CGRect){
                    {prevX, self.tutorialLabel.frame.origin.y},
                    {self.tutorialLabel.frame.size.width, self.tutorialLabel.frame.size.height}
                }];
                
            } completion:^(BOOL finished) {
                self.shimmerLabel.shimmering = YES;
            }];
        }
    }];
}

-(void)animateToNextTutorialStepOrStop{
    self.currentStep ++;
    if(self.currentStep >= [self framesForAnimation].count){
        [self cleanUp];
        return;
    }
    [self animateToNextTutorialStep];
}

-(void)setCutAtRect:(CGRect)rect {
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.backgroundView.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0f];
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    self.mask.path = maskPath.CGPath;
}

#pragma mark - Touches

-(void)swipeOrTapInWindow:(UISwipeGestureRecognizer*)sender{
    [self animateToNextTutorialStepOrStop];
}

-(void)windowTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!self.firstTouchForTutorialStart){
        [self launchBasicTutorialAnimationWithFrames:[self framesForAnimation] andStrings:[self stringsForAnimation]];
        self.firstTouchForTutorialStart = YES;
    }
}

#pragma mark - Cleanup

-(void)cleanUp{
    self.framesAndStrings = nil;
    self.frameAndStringsBlock = nil;
    self.currentStep = 0;
    [self.backgroundView removeGestureRecognizer:self.tapRecognizer];
    [self.backgroundView removeGestureRecognizer:self.swipeRecognizer];
    self.swipeRecognizer = nil;
    self.tapRecognizer = nil;
    self.waitsForTouches = NO;
    
    [UIView animateWithDuration:.5 animations:^{
        self.tutorialLabel.frame = (CGRect){
            { self.window.frame.origin.x - self.window.frame.size.width, self.tutorialLabel.frame.origin.y },
            { self.tutorialLabel.frame.size.width, self.tutorialLabel.frame.size.height }
        };
        
        self.shimmerLabel.frame = (CGRect){
            { self.window.frame.origin.x - self.window.frame.size.width, self.shimmerLabel.frame.origin.y },
            { self.shimmerLabel.frame.size.width, self.shimmerLabel.frame.size.height }
        };
    } completion:^(BOOL finished) {
        self.tutorialLabel = nil;
        self.shimmerLabel = nil;
    }];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.mainWindow makeKeyAndVisible];
        [self.window removeFromSuperview];
        self.window = nil;
        if(self.completionBlock != nil){
            self.completionBlock();
        }
        self.completionBlock = nil;
    }];
}

@end