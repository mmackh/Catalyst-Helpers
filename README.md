# Catalyst-Helpers
Unlock missing UIKit functionality with these unsafe AppKit helpers. The overall goal is to let Apple know what functionality is missing in UIKit to build better apps for the Mac.

## IPDFMacEventBus & Keyboard Navigation

The fundamental aspect of what sets iOS (excluding tvOS) aparat form macOS is the inability to correctly navigate through views, not only text fields, with a keyboard. I've come to realise that a UIKeyCommand is not enough and sometimes you would simply be better off with keyDown:, which iOS lacks. So I've wrapped NSEvent's addLocalMonitorForEventsMatchingMask - where you are able to choose whether an event actually gets passed to UIKit or not. Always remember to removeMonitor: otherwhise you'll be left with leaks everywhere.

```
IPDFMacEventBusMonitor *monitor = [IPDFMacEventBusMonitor monitorWithType:IPDFMacEventBusTypeKeydown eventHandler:^IPDFMacEventBusEvent *(IPDFMacEventBusEvent *event)
{
    if ([event isTab])
    {
        if (weakSelf.cancel.isFirstResponder)
        {
            [weakSelf.save becomeFirstResponder];
            return nil;
        }

        if (weakSelf.save.isFirstResponder)
        {
            [weakSelf.textField becomeFirstResponder];
            return nil;
        }

        if (weakSelf.textField.isFirstResponder)
        {
            [weakSelf.cancel becomeFirstResponder];
            return nil;
        }
    }

    if ([event isEnter])
    {
        if (weakSelf.cancel.isFirstResponder)
        {
            [weakSelf.cancel sendActionsForControlEvents:UIControlEventTouchUpInside];
            return nil;
        }

        if (weakSelf.save.isFirstResponder)
        {
            [weakSelf.save sendActionsForControlEvents:UIControlEventTouchUpInside];
            return nil;
        }
    }

    if ([event isESC])
    {
        [weakSelf dismissWithCompletionHandler:nil];
        return nil;
    }

    return event;
}];
sheet.monitor = monitor;
[[IPDFMacEventBus sharedBus] addMonitor:monitor];
```

## IPDFMacEventBus & App State Events

InstaPDF doesn't fetch documents in the background, but rather when the window becomes key. At first it was quite confusing not being able to know when this occurs, due to UIApplicationWillEnterForegroundNotification only firing once on launch. I pondered swizzling, but observing notifications is a better solution. Again, remove the monitors to prevent leaks.

```
[[IPDFMacEventBus sharedBus] addMonitor:[IPDFMacEventBusMonitor monitorWithType:IPDFMacEventBusTypeAppState eventHandler:^IPDFMacEventBusEvent *(IPDFMacEventBusEvent *event)
{
    if (event.appState == IPDFMacEventBusAppStateEventBecomeActive)
    {
        NSLog(@"Become Active");
    }

    if (event.appState == IPDFMacEventBusAppStateEventTerminate)
    {
        NSLog(@"Terminate...");
    }
    return nil;
}]];
```

## Additional Catalyst Workarounds

In addition to the helper classes I created, there were still some visual glitches and other unexpected behaviour in UIKit that will feel foreign on the Mac that cannot be abstracted

### Opening Files from Dock Icon & Right-Click Finder "Open In..."

You'll need to swizzle (I prefer https://github.com/steipete/Aspects). 

1. Add appropriate entry to Info.plist, .pdf files in the example below
```
<array>
	<dict>
		<key>CFBundleTypeExtensions</key>
		<array>
			<string>pdf</string>
		</array>
		<key>CFBundleTypeIconFiles</key>
		<array/>
		<key>CFBundleTypeName</key>
		<string>PDF Document</string>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>LSHandlerRank</key>
		<string>Owner</string>
		<key>LSItemContentTypes</key>
		<array>
			<string>com.adobe.pdf</string>
		</array>
	</dict>
</array>
```

2. Declare the appropriate selector to hook in AppDelegate
```
@interface AppDelegate ()

@end

@interface NSObject (private)

- (void)processOpenURLs:(id)arg1;

@end
```

3. Hook the selector and process the files
```
__weak typeof(self) weakSelf = self;
[[NSNotificationCenter defaultCenter] addObserverForName:@"NSApplicationDidFinishLaunchingNotification" object:nil queue:nil usingBlock:^(NSNotification *note)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id app = [NSClassFromString(@"NSApplication") sharedApplication];
        id delegate = [app delegate];

        [delegate aspect_hookSelector:@selector(processOpenURLs:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, NSArray *fileURLs)
        {
            [weakSelf openFiles:fileURLs];
        } error:nil];
    });
}];
```
Before the dock would allow me to drag in files, I had to either: run a different project in Xcode after the plist entry or restart the OS. I can't remember which one helped.

### Blue highlights in UITableViewCell on selection

<img alt="Double clicking causes the cell to highlight blue" align="right" width="320" height="80" src="https://github.com/mmackh/Catalyst-Helpers/blob/master/screenshots/UITableView%20-%20Blue%20Highlight.png?raw=true">

When embedding a UITableView on the left panel of a UISplitView (self.primaryBackgroundStyle = UISplitViewControllerBackgroundStyleSidebar), the design will mimick NSOutlineView. This design is found in apps such as Xcode, Mail, Finder, etc. The difference between Xcode and Finder for example, is that Finder will not allow the cell to be highlighted, because it cannot become a firstResponder.

![NSOutlineView in Finder design](https://github.com/mmackh/Catalyst-Helpers/blob/master/screenshots/Finder%20Left%20Panel.png?raw=true)

On the Catalyst side of things, a click and subsequent selection of a given cell can cause the blue (or the user's chosen accent color) highlight to shimmer/glitch through. On a double click, the cell will turn blue. There is no apparent way to prevent the cell from changing to a solid color on double click without having to implement your own custom selectedBackgroundView and therefore losing the UIVibrancyEffect on selection. 

The workaround is quite simple (took me a while): add a UITapGestureRecognizer (numberOfTapsRequired = 1) to your cell. You'll have to manually create a protocol and then select the cell. Once these measures are implemented, double clicking will no longer turn the cell blue and the behaviour will be indistinguishable from a native app like Finder.  
