//
//  TutorialController.h
//  FullTime
//
//  Created by Afonso Tsukamoto on 20/08/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ATTutorialController : NSObject

// The text for the FBShimmer view.
// Default is 'Swipe or Tap'
@property (nonatomic, strong) NSString *shimmerLabelText;

// You can set the label frame before calling the show tutorial.
// This is for the cases where the frame of the label is on top of the frame beign highlighted or just because you
// want the label somewhere else.
@property (nonatomic, readwrite) CGRect labelPosition;

// Is a singleton, so sharedInstance ftw
+(instancetype) sharedInstance;

// Usefull methods to launch the tutorial.
// The verification must be performed in the controller showing the tutorial.
// The block methods are useful for the cases where your layout is not raeady where you want to call the tutorial.
// The blocks are only called just before the tutorial shows, so it can, and possibly will, be after the layout is ready.

-(void)showTutorialWithFramesAndStrings:(NSArray*)framesAndStrings;

-(void)showTutorialWithFramesAndStrings:(NSArray*)framesAndStrings waitsForTouch:(BOOL)waits;

-(void)showTutorialWithFramesAndStrings:(NSArray*)framesAndStrings completion:(void(^)())completion;

-(void)showTutorialWithFramesAndStrings:(NSArray*)framesAndStrings completion:(void(^)())completion waitsForTouch:(BOOL)waits;

-(void)showTutorialWithFramesAndStringsBlock:(NSArray*(^)())framesAndStringsBlock;

-(void)showTutorialWithFramesAndStringsBlock:(NSArray*(^)())framesAndStringsBlock completion:(void(^)())completion;

-(void)showTutorialWithFramesAndStringsBlock:(NSArray*(^)())framesAndStringsBlock completion:(void(^)())completion waitsForTouch:(BOOL)waits;
@end
