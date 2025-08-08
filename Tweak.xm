
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <substrate.h>

static void *g_handle = NULL;
static const char *target_path = "/Library/MobileSubstrate/DynamicLibraries/iOSGodsiAPCracker.dylib";

%hook UIApplication
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL res = %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) keyWindow = [UIApplication sharedApplication].delegate.window;

        // Floating button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 120, 56, 56);
        btn.layer.cornerRadius = 28;
        btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [btn setTitle:@"MM" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        btn.alpha = 0.95;
        btn.tag = 0x123456;

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:btn action:@selector(handlePan:)];
        [btn addGestureRecognizer:pan];
        [btn addTarget:self action:@selector(modMenuTapped:) forControlEvents:UIControlEventTouchUpInside];

        [keyWindow addSubview:btn];
    });
    return res;
}
%end

// Categories for gesture and tap
static void handlePanIMP(id self, SEL _cmd, UIPanGestureRecognizer *g) {
    UIView *v = (UIView*)self;
    if (g.state == UIGestureRecognizerStateChanged || g.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [g translationInView:v.superview];
        CGRect f = v.frame;
        f.origin.x += translation.x;
        f.origin.y += translation.y;
        CGSize s = v.superview.bounds.size;
        if (f.origin.x < 0) f.origin.x = 0;
        if (f.origin.y < 20) f.origin.y = 20;
        if (f.origin.x + f.size.width > s.width) f.origin.x = s.width - f.size.width;
        if (f.origin.y + f.size.height > s.height) f.origin.y = s.height - f.size.height;
        v.frame = f;
        [g setTranslation:CGPointZero inView:v.superview];
    }
}

static void modMenuTappedIMP(id self, SEL _cmd, id sender) {
    UIWindow *w = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].delegate.window;
    UIView *menu = [w viewWithTag:0xDEADBEEF];
    if (menu && menu.superview) {
        menu.hidden = !menu.hidden;
        return;
    }
    CGRect mframe = CGRectMake(40, 160, 260, 120);
    UIView *container = [[UIView alloc] initWithFrame:mframe];
    container.backgroundColor = [UIColor colorWithWhite:0.06 alpha:0.95];
    container.layer.cornerRadius = 12;
    container.tag = 0xDEADBEEF;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 240, 28)];
    title.text = @"Mod Menu";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:18];
    [container addSubview:title];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 48, 160, 22)];
    lbl.text = @"iAPCracker";
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:14];
    [container addSubview:lbl];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(200, 44, 0, 0)];
    sw.on = NO;
    [sw addTarget:nil action:@selector(toggleCracker:) forControlEvents:UIControlEventValueChanged];
    [container addSubview:sw];

    [w addSubview:container];
}

%ctor {
    Class UIButtonClass = objc_getClass("UIButton");
    MSHookMessageEx(UIButtonClass, @selector(handlePan:), (IMP)handlePanIMP, NULL);
    MSHookMessageEx(UIButtonClass, @selector(modMenuTapped:), (IMP)modMenuTappedIMP, NULL);
    MSHookMessageEx(UIButtonClass, @selector(toggleCracker:), (IMP)toggleCrackerIMP, NULL);
}

static void toggleCrackerIMP(id self, SEL _cmd, UISwitch *sw) {
    if (sw.on) {
        if (!g_handle) {
            g_handle = dlopen(target_path, RTLD_NOW);
            if (!g_handle) {
                NSLog(@"[ModMenu] dlopen failed: %s", dlerror());
            } else {
                NSLog(@"[ModMenu] iAPCracker loaded");
            }
        }
    } else {
        if (g_handle) {
            dlclose(g_handle);
            g_handle = NULL;
            NSLog(@"[ModMenu] iAPCracker unloaded");
        }
    }
}
