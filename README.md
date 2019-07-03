# UIPopoverCard

`UIPopoverCard` creating bottom slide card for show information.

![Screenshot](https://github.com/AlekseyPleshkov/UIPopoverCard/blob/master/example.gif?raw=true)

## Installation

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `UIPopoverCard` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod 'UIPopoverCard', '~> 0.1.1'
end
```

Then, run the following command:

```bash
$ pod install
```

## How to use

You need create class `UIPopoverCard` and set they `UIPopoverCardConfiguration` ans `UIPopoverCardBody`.
Add delegate to `UIPopoverCardDelegate` in your ViewController for work with events.

``` swift
// ...

override func viewDidLoad() {
    super.viewDidLoad()
    // ...
    
    // UIPopoverCard
    let config = UIPopoverCardConfiguration()
    let body = UIPopoverCardBody(xibName: "Test")
    let popoverCard = UIPopoverCard(self, configure: config, body: body)
    
    popoverCard.show()
    // popoverCard.hide()
    
    // ...
}
```

### UIPopoverCardConfiguration params

``` swift
let config = UIPopoverCardConfiguration()

config.overlayColor = UIColor.lightGray
config.overlayAlpha = 0.5
config.cardBackgroundColor = UIColor.white
config.headerCardLineColor = UIColor.lightGray
config.isShowBackground = true
config.isHideCardTapToBackground = true
config.visibleAnimationDuration = 0.5
config.changeStateAnimationDuration = 0.3
config.availableStates= [.small, .middle, .large]
config.isAdaptiveByContent = false
```

### UIPopoverCardBody initialization types

``` swift
// Create body by uiview
let body = UIPopoverCardBody(view: YOU_UIVIEW)

// Create body from xib name
let body = UIPopoverCardBody(xibName: "YOU_XIB_NAME")
```

### UIPopoverCardDelegate events

```swift
/// Will change visibility state of popover card
func popoverCard(_ popoverCard: UIPopoverCard, willChangeShow isVisible: Bool)

/// Did change visibility state of popover card
func popoverCard(_ popoverCard: UIPopoverCard, didChangeShow isVisible: Bool)

/// Did change state of size card
func popoverCard(_ popoverCard: UIPopoverCard, didChangeSize state: UIPopoverCardState)
```

## About Me

* Aleksey Pleshkov
* Email: [im@alekseypleshkov.ru](mailto:im@alekseypleshkov.ru)
* Website: [alekseypleshkov.ru](https://alekseypleshkov.ru)

## License

`UIPopoverCard` is released under the MIT license. In short, it's royalty-free but you must keep the copyright notice in your code or software distribution.
