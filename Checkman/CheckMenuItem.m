#import "CheckMenuItem.h"
#import "InfoMenuItem.h"
#import "Check.h"

@interface CheckMenuItem ()
@property (nonatomic, strong) Check *check;
@end

@implementation CheckMenuItem

@synthesize check = _check;

- (id)initWithCheck:(Check *)check {
    if (self = [super init]) {
        self.check = check;
        self.enabled = YES;
        self.target = self;
        self.action = @selector(_performAction);

        [self _refreshName];
        [self _refreshStatusImage];
        [self.check addObserverForRunning:self];
    }
    return self;
}

- (void)dealloc {
    [self.check removeObserverForRunning:self];
}

#pragma mark - 

- (void)_performAction {
    [self.check openUrl];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self _refreshName];
    [self _refreshStatusImage];
    [self _refreshInfoSubmenu];
}

- (void)_refreshName {
    self.title = self.check.isRunning ?
        [NSString stringWithFormat:@"%@...", self.check.name] : self.check.name;
}

- (void)_refreshStatusImage {
    NSString *statusImageName =
        [Check statusImageNameForCheckStatus:self.check.status changing:self.check.isChanging];
    self.image = [NSImage imageNamed:statusImageName];
}

- (void)_refreshInfoSubmenu {
    if (self.check.info) {
        // Reuse existing submenu to avoid orphaning possibly opened menu
        self.submenu = self.submenu ? self.submenu : [[NSMenu alloc] init];
        [self _udpateMenu:self.submenu fromArray:self.check.info];
    } else {
        self.submenu = nil;
    }
}

- (void)_udpateMenu:(NSMenu *)menu fromArray:(NSArray *)array {
    [menu removeAllItems];

    for (NSArray *keyValuePair in array) {
        NSString *key = [keyValuePair objectAtIndex:0];
        NSString *value = [keyValuePair objectAtIndex:1];
        NSString *valueString = [NSString stringWithFormat:@"%@", value];
        [menu addItem:[InfoMenuItem menuItemWithName:key value:valueString]];
    }
    [menu update];
}
@end
