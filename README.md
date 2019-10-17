# Catalyst-Helpers
Unlock missing UIKit functionality with these unsafe AppKit helpers. The overall goal is to let Apple know what functionality is missing in UIKit to build better apps for the Mac.

## Additional Catalyst Workarounds

In addition to the helper classes I created, there were still some visual glitches and other unexpected behaviour in UIKit that will feel foreign on the Mac that cannot be abstracted

### Blue highlights in UITableViewCell on selection

<img alt="Double clicking causes the cell to highlight blue" align="right" width="320" height="80" src="https://github.com/mmackh/Catalyst-Helpers/blob/master/screenshots/UITableView%20-%20Blue%20Highlight.png?raw=true">

When embedding a UITableView on the left panel of a UISplitView (self.primaryBackgroundStyle = UISplitViewControllerBackgroundStyleSidebar), the design will mimick NSOutlineView. This design is found in apps such as Xcode, Mail, Finder, etc. The difference between Xcode and Finder for example, is that Finder will not allow the cell to be highlighted, because it cannot become a firstResponder.

![NSOutlineView in Finder design](https://github.com/mmackh/Catalyst-Helpers/blob/master/screenshots/Finder%20Left%20Panel.png?raw=true)

On the Catalyst side of things, a click and subsequent selection of a given cell can cause the blue (or the user's chosen accent color) highlight to shimmer through on a single click. On a double click, the cell will turn blue. There is no apparent way to prevent the cell from changing to a solid color on double click without having to implement your own custom selectedBackgroundView and therefore losing the UIVibrancyEffect on selection. 

The workaround is quite simple (took me a while): add a UITapGestureRecognizer (numberOfTapsRequired = 1) to your cell. You'll have to manually create a protocol and then select the cell. Once these measures are implemented, double clicking on a clell will no longer turn the cell blue and the behaviour will be indistinguishable from a native app like Finder.  
