//
//  VVPropertyExpressionSetter.m
//  VirtualView
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "VVPropertyExpressionSetter.h"

@interface VVPropertyExpressionSetter ()

@property (nonatomic, strong, readwrite) VVExpression *expression;

@end

@implementation VVPropertyExpressionSetter

+ (VVPropertyExpressionSetter *)setterWithPropertyKey:(int)key expressionString:(NSString *)expressionString
{
    if (expressionString && expressionString.length > 0) {
        expressionString = [expressionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (expressionString.length > 0 && ([expressionString hasPrefix:@"@{"] || [expressionString hasPrefix:@"${"])) {
            VVExpression *expression = [VVExpression expressionWithString:expressionString];
            if (expression && [expression isKindOfClass:[VVConstExpression class]] == NO) {
                VVPropertyExpressionSetter *setter = [[self alloc] initWithPropertyKey:key];
                setter.expression = expression;
                return setter;
            }
        }
    }
    return nil;
}

- (instancetype)initWithPropertyKey:(int)key
{
    if (self = [super initWithPropertyKey:key]) {
        switch (key) {
            case STR_ID_autoDimDirection:
            case STR_ID_stayTime:
            case STR_ID_animatorTime:
            case STR_ID_autoSwitchTime:
                _valueType = TYPE_INT;
                break;
            case STR_ID_paddingLeft:
            case STR_ID_paddingTop:
            case STR_ID_paddingRight:
            case STR_ID_paddingBottom:
            case STR_ID_layoutMarginLeft:
            case STR_ID_layoutMarginRight:
            case STR_ID_layoutMarginTop:
            case STR_ID_layoutMarginBottom:
            case STR_ID_autoDimX:
            case STR_ID_autoDimY:
            case STR_ID_borderWidth:
            case STR_ID_borderRadius:
            case STR_ID_borderTopLeftRadius:
            case STR_ID_borderTopRightRadius:
            case STR_ID_borderBottomLeftRadius:
            case STR_ID_borderBottomRightRadius:
            case STR_ID_itemHorizontalMargin:
            case STR_ID_itemVerticalMargin:
            case STR_ID_textSize:
                _valueType = TYPE_FLOAT;
                break;
            case STR_ID_data:
            case STR_ID_dataUrl:
            case STR_ID_dataParam:
            case STR_ID_action:
            case STR_ID_actionParam:
            case STR_ID_class:
            case STR_ID_name:
            case STR_ID_backgroundImage:
            case STR_ID_src:
            case STR_ID_text:
            case STR_ID_ck:
                _valueType = TYPE_STRING;
                break;
            case STR_ID_color:
            case STR_ID_textColor:
            case STR_ID_borderColor:
            case STR_ID_maskColor:
            case STR_ID_background:
                _valueType = TYPE_COLOR;
                break;
            case STR_ID_autoSwitch:
            case STR_ID_canSlide:
            case STR_ID_inmainthread:
                _valueType = TYPE_BOOLEAN;
                break;
            case STR_ID_visibility:
                _valueType = TYPE_VISIBILITY;
                break;
            case STR_ID_gravity:
                _valueType = TYPE_GRAVITY;
                break;
            case STR_ID_dataTag:
            default:
                _valueType = TYPE_OBJECT;
                break;
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name = %@; expression = %@>", self.class, self, self.name, self.expression];
}

- (BOOL)isExpression
{
    return YES;
}

- (void)applyToNode:(VVBaseNode *)node withObject:(nullable NSDictionary *)object
{
    if (self.expression) {
        id objectValue = [self.expression resultWithObject:object];
        NSString *stringValue = [objectValue description];
        BOOL handled = NO;
        switch (self.valueType) {
            case TYPE_INT:
            {
                handled = [node setIntValue:[stringValue intValue] forKey:self.key];
            }
                break;
            case TYPE_FLOAT:
            {
                handled = [node setFloatValue:[stringValue floatValue] forKey:self.key];
            }
                break;
            case TYPE_STRING:
            case TYPE_COLOR:
            {
                handled = [node setStringDataValue:stringValue forKey:self.key];
            }
                break;
            case TYPE_BOOLEAN:
            {
                BOOL boolValue = 0;
                if ([stringValue isEqualToString:@"true"]) {
                    boolValue = 1;
                }
                handled = [node setIntValue:boolValue forKey:self.key];
            }
                break;
            case TYPE_VISIBILITY:
            {
                int visibilityValue = VVVisibilityGone;
                if ([stringValue isEqualToString:@"invisible"]) {
                    visibilityValue = VVVisibilityInvisible;
                } else if ([stringValue isEqualToString:@"visible"]) {
                    visibilityValue = VVVisibilityVisible;
                }
                handled = [node setIntValue:visibilityValue forKey:self.key];
            }
                break;
            case TYPE_GRAVITY:
            {
                handled = [node setIntValue:[VVPropertyExpressionSetter getGravity:stringValue] forKey:self.key];
            }
                break;
            case TYPE_OBJECT:
            {
                [node setDataObj:objectValue forKey:self.key];
                handled = YES;
            }
                break;
            default:
                break;
        }
#ifdef VV_DEBUG
        NSAssert(handled == YES, @"Property is not handled.");
#endif
    }
}

+ (int)getGravity:(NSString *)stringValue
{
    NSArray *array = [stringValue componentsSeparatedByString:@"|"];
    int gravity = 0;
    for (NSString *item in array) {
        NSString *trimmedItem = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([trimmedItem isEqualToString:@"left"]) {
            gravity |= VVGravityLeft;
        } else if ([trimmedItem isEqualToString:@"right"]) {
            gravity |= VVGravityRight;
        } else if ([trimmedItem isEqualToString:@"h_center"]) {
            gravity |= VVGravityHCenter;
        } else if ([trimmedItem isEqualToString:@"top"]) {
            gravity |= VVGravityTop;
        } else if ([trimmedItem isEqualToString:@"bottom"]) {
            gravity |= VVGravityBottom;
        } else if ([trimmedItem isEqualToString:@"v_center"]) {
            gravity |= VVGravityVCenter;
        } else if ([trimmedItem isEqualToString:@"center"]) {
            gravity |= VVGravityHCenter | VVGravityVCenter;
        }
    }
    return gravity;
}

@end
