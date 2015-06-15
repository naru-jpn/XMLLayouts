
#ifndef Layouts_XMLLayoutConstants_h
#define Layouts_XMLLayoutConstants_h

/* common */
OBJC_EXPORT NSString * const kXMLLayouts;

OBJC_EXPORT NSString * const kXMLLayoutID;

OBJC_EXPORT NSString * const kXMLLayoutWidth;
OBJC_EXPORT NSString * const kXMLLayoutHeight;
OBJC_EXPORT NSString * const kXMLLayoutWeight;
OBJC_EXPORT NSString * const kXMLLayoutWeightSum;

OBJC_EXPORT NSString * const kXMLLayoutMargin;
OBJC_EXPORT NSString * const kXMLLayoutMarginTop;
OBJC_EXPORT NSString * const kXMLLayoutMarginLeft;
OBJC_EXPORT NSString * const kXMLLayoutMarginBottom;
OBJC_EXPORT NSString * const kXMLLayoutMarginRight;

OBJC_EXPORT NSString * const kXMLLayoutPadding;
OBJC_EXPORT NSString * const kXMLLayoutPaddingTop;
OBJC_EXPORT NSString * const kXMLLayoutPaddingLeft;
OBJC_EXPORT NSString * const kXMLLayoutPaddingBottom;
OBJC_EXPORT NSString * const kXMLLayoutPaddingRight;

OBJC_EXTERN NSString * const kXMLLayoutLengthModeMatchParent;
OBJC_EXTERN NSString * const kXMLLayoutLengthModeWrapContent;

OBJC_EXPORT NSString * const kXMLLayoutElementLinearLayout;
OBJC_EXPORT NSString * const kXMLLayoutElementRelativeLayout;

OBJC_EXPORT NSString * const kXMLLayoutGravity;
OBJC_EXPORT NSString * const kXMLLayoutGravityTop;
OBJC_EXPORT NSString * const kXMLLayoutGravityRight;
OBJC_EXPORT NSString * const kXMLLayoutGravityBottom;
OBJC_EXPORT NSString * const kXMLLayoutGravityLeft;
OBJC_EXPORT NSString * const kXMLLayoutGravityCenterHorizontal;
OBJC_EXPORT NSString * const kXMLLayoutGravityCenterVertical;
OBJC_EXPORT NSString * const kXMLLayoutGravityCenter;
OBJC_EXPORT NSString * const kXMLLayoutLayoutGravity;

OBJC_EXPORT NSString * const kXMLLayoutVisility;
OBJC_EXPORT NSString * const kXMLLayoutVisilityVisible;
OBJC_EXPORT NSString * const kXMLLayoutVisilityInvisible;
OBJC_EXPORT NSString * const kXMLLayoutVisilityGone;

/* layout content */
OBJC_EXPORT NSString * const kXMLLayoutViewPropertyFont;
OBJC_EXPORT NSString * const kXMLLayoutViewPropertyText;
OBJC_EXPORT NSString * const kXMLLayoutViewPropertyTextColor;
OBJC_EXPORT NSString * const kXMLLayoutViewPropertyBackgroundColor;
OBJC_EXPORT NSString * const kXMLLayoutViewPropertyTitle;
OBJC_EXPORT NSString * const kXMLLayoutViewPropertyTitleColor;
OBJC_EXPORT NSString * const kXMLLayoutViewPropertyNumberOfLines;

/* layout container */
OBJC_EXPORT NSString * const kXMLLayoutBackgroundImage;

/* linear layout */
OBJC_EXPORT NSString * const kXMLLayoutOrientation;
OBJC_EXPORT NSString * const kXMLLayoutOrientationHorizontal;
OBJC_EXPORT NSString * const kXMLLayoutOrientationVertical;

/* relative layout */
OBJC_EXPORT NSString * const kXMLRelativityAlignTop;
OBJC_EXPORT NSString * const kXMLRelativityAlignLeft;
OBJC_EXPORT NSString * const kXMLRelativityAlignBottom;
OBJC_EXPORT NSString * const kXMLRelativityAlignRight;

OBJC_EXPORT NSString * const kXMLRelativityPositionTop;
OBJC_EXPORT NSString * const kXMLRelativityPositionToLeft;
OBJC_EXPORT NSString * const kXMLRelativityPositionBottom;
OBJC_EXPORT NSString * const kXMLRelativityPositionToRight;

OBJC_EXPORT NSString * const kXMLRelativityAlignParent;
OBJC_EXPORT NSString * const kXMLRelativityAlignParentTop;
OBJC_EXPORT NSString * const kXMLRelativityAlignParentLeft;
OBJC_EXPORT NSString * const kXMLRelativityAlignParentBottom;
OBJC_EXPORT NSString * const kXMLRelativityAlignParentRight;
OBJC_EXPORT NSString * const kXMLRelativityAlignParentCenterHorizontal;
OBJC_EXPORT NSString * const kXMLRelativityAlignParentCenterVertical;
OBJC_EXPORT NSString * const kXMLRelativityAlignParentCenter;

/* converter */
OBJC_EXPORT NSString * const kXMLLayoutConverterInclude;
OBJC_EXPORT NSString * const kXMLLayoutConverterIncludedXML;
OBJC_EXPORT NSString * const kXMLLayoutConverterIncludedResourceName;
OBJC_EXPORT NSString * const kXMLLayoutConverterIncludedParent;

/* xml reader */
OBJC_EXPORT NSString * const kXMLLayoutReaderInclude;
OBJC_EXPORT NSString * const kXMLLayoutReaderIncludedLayoutXML;

#endif
