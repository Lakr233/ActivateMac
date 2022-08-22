//
//  main.m
//  ActivateMac
//
//  Created by Lessica <82flex@gmail.com> on 2022/5/17.
//

#import <AppKit/AppKit.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@interface AppWindow : NSWindow
@end

@interface AppWindowController : NSWindowController
- (instancetype)initWithScreen:(NSScreen *)screen;
@end

@interface AppController : NSViewController
@end

@interface AppView : NSView
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) NSString *animationTitle;
@end


@implementation AppDelegate {
    NSMutableArray *_windowControllers;
}

- (instancetype)init {
    self = [super init];
    _windowControllers = [[NSMutableArray alloc] init];
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self bootstrap];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bootstrap)
                                                 name:NSApplicationDidChangeScreenParametersNotification
                                               object:nil];

    // To show dock icon, comment this line.
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)bootstrap {
    for (NSWindowController *windowCtrl in _windowControllers) {
        [windowCtrl close];
    }
    [_windowControllers removeAllObjects];

    for (NSScreen *screen in [NSScreen screens]) {
        [_windowControllers addObject:[self createWindowControllerForScreen:screen]];
    }
}

- (NSWindowController *)createWindowControllerForScreen:(NSScreen *)screen {
    NSWindowController *ctrl = [[AppWindowController alloc] initWithScreen:screen];
    [[ctrl window] setFrameOrigin:screen.frame.origin];
    [[ctrl window] setContentSize:screen.frame.size];
    [[ctrl window] makeKeyAndOrderFront:nil];
    return ctrl;
}

@end


@implementation AppWindow

- (instancetype)initWithScreen:(NSScreen *)screen {
    self = [super initWithContentRect:[screen frame]
                            styleMask:(NSWindowStyleMaskBorderless | NSWindowStyleMaskFullSizeContentView)
                              backing:NSBackingStoreBuffered
                                defer:NO
                               screen:screen];

    [self setOpaque:NO];
    [self setAlphaValue:1];
    [self setTitleVisibility:NSWindowTitleHidden];
    [self setTitlebarAppearsTransparent:YES];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setIgnoresMouseEvents:YES];
    [self setMovable:NO];
    [self setCollectionBehavior:NSWindowCollectionBehaviorFullScreenAuxiliary | NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorCanJoinAllSpaces];
    [self setLevel:kCGStatusWindowLevel];
    [self setHasShadow:NO];
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (BOOL)canBecomeMainWindow {
    return NO;
}

- (NSWindowCollectionBehavior)collectionBehavior {
    return NSWindowCollectionBehaviorFullScreenAuxiliary | NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorCanJoinAllSpaces;
}

@end


@implementation AppWindowController

- (instancetype)initWithScreen:(NSScreen *)screen {
    self = [super initWithWindow:[[AppWindow alloc] initWithScreen:screen]];
    [self setContentViewController:[AppController new]];
    return self;
}

@end


@implementation AppController

- (instancetype)init {
    return [super initWithNibName:nil bundle:nil];
}

- (void)loadView {
    [self setView:[AppView new]];
}

@end


@implementation AppView

- (instancetype)init {
    self.animationTitle = [self currentTime];
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doAnimationYouWant) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
    return [super initWithFrame:CGRectZero];
}

- (void)doAnimationYouWant
{
    self.animationTitle = [self currentTime];
    [self setNeedsDisplay:YES];
}

- (NSString *)currentTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    return [dateFormatter stringFromDate:currentDate];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSString *title = @"macOS 12 Pro Insider Preview";
    NSString *description = @"Evaluation copy. Build 25169.rs_prerelease.220723-1625";

    NSAttributedString *firstLine = [[NSAttributedString alloc] initWithString:title
                                                                    attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:24.0],
                                                                                  NSForegroundColorAttributeName: [NSColor colorWithWhite:0.57 alpha:0.5],
                                                                               }];
    
    NSAttributedString *timeLine = [[NSAttributedString alloc] initWithString:self.animationTitle?:@""
                                                                    attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:13],
                                                                                  NSForegroundColorAttributeName: [NSColor colorWithWhite:0.57 alpha:0.5],
                                                                               }];

    NSAttributedString *secondLine = [[NSAttributedString alloc] initWithString:description
                                                                     attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:13.0],
                                                                                   NSForegroundColorAttributeName: [NSColor colorWithWhite:0.57 alpha:0.5],
                                                                                }];

    CGRect firstLineRect = [firstLine boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
    CGRect secondLineRect = [secondLine boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];

    CGFloat decisionWidth = MAX(firstLineRect.size.width, secondLineRect.size.width);

    CGFloat xPosition = self.bounds.size.width - 125 - decisionWidth; // padding to right 125
    [firstLine drawAtPoint:CGPointMake(xPosition, 134)];
    [timeLine drawAtPoint:CGPointMake(xPosition + firstLineRect.size.width + 10, 137)];
    [secondLine drawAtPoint:CGPointMake(xPosition, 116)];
}

@end


int main(int argc, const char *argv[]) {
    static AppDelegate *appDelegate = nil;
    appDelegate = [AppDelegate new];
    [NSApplication sharedApplication].delegate = appDelegate;
    return NSApplicationMain(argc, argv);
}
