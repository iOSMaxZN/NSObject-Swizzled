//
//  NSObject+Swizzled.h
//  SwizzledMethodTst
//
//  Created by iOSMax on 17/2/6.
//  Copyright © 2017年 iOSMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzled)

+ (void)sw_swizzleClassMethod:(SEL)origSelector withNewMethod:(SEL)newSelector;

- (void)sw_swizzleInstanceMethod:(SEL)origSelector withNewMethod:(SEL)newSelector;

@end
