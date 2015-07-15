# XMLLayouts
Lay out UI using XML for ios

[![Version](http://img.shields.io/cocoapods/v/XMLLayouts.svg)](http://cocoapods.org/?q=XMLLayouts)
 

## Try sample project

```
$ pod try XMLLayouts
```
 
 
## Installation with CocoaPods

#### Podfile
 
```
platform :ios, '7.0'
pod 'XMLLayouts'
```
 
 
## Architecture

#### Constants
- `XMLLayoutConstants`

#### Content
- `XMLLayout` - base class of container and content
* `<LayoutContainer>`
  - `XMLLayoutContainer`
  - `XMLLayoutLinearLayout`
  - `XMLLayoutRelativeLayout`
  * `<XMLDependencyGraph>`
    - `XMLDependency`
    - `XMLDependencyGraph`
* `<LayoutContent>`
  - `XMLLayoutContent`
 
#### R
* `<R>`
  - `R`
  * `<Managers>`
    - `XMLIDStore`
    - `XMLImageManager`
    - `XMLTextManager`
    - `XMLColorManager`

#### Converter
* `<Converter>`
  - `XMLLayoutConverter`
  - `XMLIntermediateObjectCache`

#### UIView+XMLLayouts
* `<UIView+XMLLayouts>`
  - `UIView+XMLLayouts` 
  

## Usage

#### Load UI with xml resource file

1\. Create xml resource file and write XML
```XML
<?xml version="1.0" encoding="UTF-8" ?>
<XMLLayouts>
    <RelativeLayout width="match_parent" height="match_parent">
        <UILabel width="wrap_content" height="wrap_content" text="@string/welcome" font="HelveticaNeue:22" text_color="333" align_parent="center" />
    </RelativeLayout>
</XMLLayouts>
```

2\. Load XML
```objectivec
- (void)viewDidLoad {
  [super viewDidLoad];
  [self.view loadXMLLayoutsWithResourceName:@"Welcome" completion:^(NSError *error) {
    ...
  }];
}
```
