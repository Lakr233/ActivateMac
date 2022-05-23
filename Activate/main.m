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
    [self setCollectionBehavior:0x101];
    [self setLevel:2005];
    [self setHasShadow:NO];
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (BOOL)canBecomeMainWindow {
    return NO;
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
    return [super initWithFrame:CGRectZero];
}

- (NSArray<NSString *>*)getString {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    NSString *dLanguage = [languages objectAtIndex:0];
    if ([dLanguage isEqualToString:@"zh-Hans"]) {
        return @[@"激活 macOS", @"您当前所使用的可能是盗版 macOS 副本，请前往偏好设置激活。"];
    } else if ([dLanguage isEqualToString:@"ja-JP"]) {
        return @[@"macOS をアクティブ化", @"「システム環境設定」アクティブ化に行ってください。"];
    } else {
        NSLog(@"Language: %@\n", dLanguage);
        return @[@"Activate macOS", @"Go to System Preferences to activate macOS."];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    NSArray<NSString *>* strings = [self getString];

    NSAttributedString *firstLine = [[NSAttributedString alloc] initWithString:strings[0]
                                                                    attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:24.0],
                                                                                  NSForegroundColorAttributeName: [NSColor colorWithWhite:0.57 alpha:0.5],
                                                                               }];

    NSAttributedString *secondLine = [[NSAttributedString alloc] initWithString:strings[1]
                                                                     attributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:13.0],
                                                                                   NSForegroundColorAttributeName: [NSColor colorWithWhite:0.57 alpha:0.5],
                                                                                }];

    CGFloat xPosition = self.bounds.size.width - 400;
    [firstLine drawAtPoint:CGPointMake(xPosition, 134)];
    [secondLine drawAtPoint:CGPointMake(xPosition, 116)];
}

@end


int main(int argc, const char *argv[]) {
    static AppDelegate *appDelegate = nil;
    appDelegate = [AppDelegate new];
    [NSApplication sharedApplication].delegate = appDelegate;
    return NSApplicationMain(argc, argv);
}
