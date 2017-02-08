//
//  NSObject+Swizzled.m
//  SwizzledMethodTst
//
//  Created by iOSMax on 17/2/6.
//  Copyright © 2017年 iOSMax. All rights reserved.
//

#import "NSObject+Swizzled.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define SWLog(fmt, ...) NSLog((@"\nError：----------------------------------\n%s [Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define LoadSwizzled (false)
#else
#define SWLog(fmt, ...) NSLog((@"\nError：----------------------------------\n%s [Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define LoadSwizzled (true)
#endif

#define DEVICE_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

@implementation NSObject (Swizzled)

+ (void)load {
    
}

+ (void)sw_swizzleClassMethod:(SEL)origSelector withNewMethod:(SEL)newSelector {

    if (!LoadSwizzled) {
        return;
    }
    
    Class className = [self class];
    
    /** class_getClassMethod 获取类方法 */
    Method origMethod = class_getClassMethod(className, origSelector);
    Method newMethod  = class_getClassMethod(className, newSelector);
    
    /** class_getInstanceMethod 获取实例方法 */
    
    Class metaClass = objc_getMetaClass(NSStringFromClass(className).UTF8String);
    
    if (class_addMethod(metaClass,
                        newSelector,
                        method_getImplementation(newMethod),
                        method_getTypeEncoding(newMethod))) {
        //swizzing super class method, added if not exist 如果newSelector在本类中不存在 则直接新增
        class_replaceMethod(metaClass,
                            newSelector,
                            method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

- (void)sw_swizzleInstanceMethod:(SEL)origSelector withNewMethod:(SEL)newSelector {
    
    if (!LoadSwizzled) {
        return;
    }
    
    Class className = [self class];
    
    /** class_getInstanceMethod 获取实例方法 */
    Method origMethod = class_getInstanceMethod(className, origSelector);
    Method newMethod  = class_getInstanceMethod(className, newSelector);

    if (class_addMethod(className,
                        origSelector,
                        method_getImplementation(newMethod),
                        method_getTypeEncoding(newMethod)) ) {
        
        class_replaceMethod(className,
                            newSelector,
                            method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
        
    } else {
        /* 先将新增方法实现 和 原有方法 绑定 然后 再绑定 原有 方法实现 和 新增方法 实现方法实现互换 */
        IMP origImp = class_replaceMethod(className,
                                          origSelector,
                                          method_getImplementation(newMethod),
                                          method_getTypeEncoding(newMethod));
        
        class_replaceMethod(className,
                            newSelector,
                            origImp,
                            method_getTypeEncoding(origMethod));
    }
}

@end


#pragma mark - NSArray
@implementation NSArray (Swizzled)
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSArray sw_swizzleClassMethod:@selector(arrayWithObject:) withNewMethod:@selector(sw_arrayWithObject:)];
        [NSArray sw_swizzleClassMethod:@selector(arrayWithObjects:count:) withNewMethod:@selector(sw_arrayWithObjects:count:)];
        
        
        @autoreleasepool {
            /** NSArrayI */
            NSArray *array  = @[@1, @2, @3];
            [array sw_swizzleInstanceMethod:@selector(objectAtIndex:) withNewMethod:@selector(sw_objectAtIndex:)];
            [array sw_swizzleInstanceMethod:@selector(subarrayWithRange:) withNewMethod:@selector(sw_subarrayWithRange:)];
    
            /** iOS10 以上， 单个元素数组 类型是 __NSSingleObjectArrayI */
            if (DEVICE_VERSION >= 10.0) {
                NSArray *array1 = @[@1];
    
                [array1 sw_swizzleInstanceMethod:@selector(objectAtIndex:) withNewMethod:@selector(sw_objectAtIndex:)];
                [array1 sw_swizzleInstanceMethod:@selector(subarrayWithRange:) withNewMethod:@selector(sw_subarrayWithRange:)];
            }
    
            /** iOS9 以上，空数组 类型是 __NSArray0 */
            if (DEVICE_VERSION >= 9.0) {
                NSArray *array0 = @[];
    
                [array0 sw_swizzleInstanceMethod:@selector(objectAtIndex:) withNewMethod:@selector(sw_objectAtIndex:)];
                [array0 sw_swizzleInstanceMethod:@selector(subarrayWithRange:) withNewMethod:@selector(sw_subarrayWithRange:)];
            }
        }
        
    });
}

+ (instancetype)sw_arrayWithObject:(id)anObject {
    
    if (anObject) {
        return [self sw_arrayWithObject:anObject];
    }
    SWLog(@"Object：%@", anObject);
    
    return @[];
}

+ (instancetype)sw_arrayWithObjects:(const id [])objects count:(NSUInteger)cnt {
    NSUInteger index = 0 ;
    id arr[cnt];
    
    for (NSInteger i = 0; i < cnt; i ++) {
        if (objects[i]) {
            arr[index++] = objects[i];
        } else {
            SWLog(@"objects[%zi] = %@", i, objects[i]);
        }
    }
    
    return [self sw_arrayWithObjects:arr count:index];
}

- (id)sw_objectAtIndex:(NSUInteger)index {
    
    if (index < self.count) {
        return [self sw_objectAtIndex:index];
    }
    SWLog(@"Array：%@\n ObjectAtIndex：%zi MaxCnt：%zi", self, index, self.count);
    
    return nil;
}

- (NSArray<id> *)sw_subarrayWithRange:(NSRange)range {
    
    if (range.location + range.length <= self.count) {
        return [self sw_subarrayWithRange:range];
    }
    SWLog(@"Array：%@\n SubArrayAtRange：%zi - %zi MaxCnt：%zi", self, range.location, range.length, self.count);
    
    return nil;
}

@end

#pragma mark - NSMutableArray
@implementation NSMutableArray (Swizzled)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        
        [mutArray sw_swizzleInstanceMethod:@selector(addObject:)
                             withNewMethod:@selector(sw_addObject:)];
        
        [mutArray sw_swizzleInstanceMethod:@selector(insertObject:atIndex:)
                             withNewMethod:@selector(sw_insertObject:atIndex:)];
        
        [mutArray sw_swizzleInstanceMethod:@selector(removeObjectAtIndex:)
                             withNewMethod:@selector(sw_removeObjectAtIndex:)];
        
        [mutArray sw_swizzleInstanceMethod:@selector(removeObjectsInRange:)
                             withNewMethod:@selector(sw_removeObjectsInRange:)];
        
        [mutArray sw_swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:)
                             withNewMethod:@selector(sw_replaceObjectAtIndex:withObject:)];
        
        [mutArray sw_swizzleInstanceMethod:@selector(objectAtIndex:)
                             withNewMethod:@selector(sw_objectAtIndex:)];
        
        [mutArray sw_swizzleInstanceMethod:@selector(subarrayWithRange:)
                             withNewMethod:@selector(sw_subarrayWithRange:)];
        
        [mutArray release];
    });
}

- (void)sw_addObject:(id)object {
    
    if (!object) {
        SWLog(@"Array：%@\n 追加Object：%@", self, object);
        return ;
    }
    
    [self sw_addObject:object];
}

- (void)sw_insertObject:(id)object atIndex:(NSUInteger)index {
    if (!object) {
        SWLog(@"Array：%@\n 插入Object：%@ AtIndex：%zi", self, object, index);
        return ;
    }
    if (index > self.count) {
        SWLog(@"Array：%@\n 插入Object：%@ AtIndex：%zi MaxCnt：%zi", self, object, index, self.count);
        return ;
    }
    
    [self sw_insertObject:object atIndex:index];
}

- (void)sw_removeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self sw_removeObjectAtIndex:index];
    } else {
        SWLog(@"Array：%@\n RemoveAtIndex：%zi MaxCnt：%zi", self, index, self.count);
    }
}

- (void)sw_removeObjectsInRange:(NSRange)range {
    
    if (range.location + range.length <= self.count) {
        [self sw_removeObjectsInRange:range];
    } else {
        SWLog(@"Array：%@\n RemoveAtRange：%zi - %zi MaxCnt：%zi", self, range.location, range.length, self.count);
    }
}

- (void)sw_replaceObjectAtIndex:(NSUInteger)index withObject:(id)object {
    if (!object) {
        SWLog(@"Array：%@\n Replace Object：%@ AtIndex：%zi", self, object, index);
        return ;
    }
    
    if (index > self.count) {
        SWLog(@"Array：%@\n Replace Object：%@ AtIndex：%zi MaxCnt：%zi", self, object, index, self.count);
        return ;
    }
}

- (id)sw_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self sw_objectAtIndex:index];
    }
    SWLog(@"Array：%@\n ObjectAtIndex：%zi MaxCnt：%zi", self, index, self.count);
    
    return nil;
}

- (NSArray<id> *)sw_subarrayWithRange:(NSRange)range {
    if (range.location + range.length <= self.count) {
        return [self sw_subarrayWithRange:range];
    }
    SWLog(@"Array：%@\n SubArrayAtRange：%zi - %zi MaxCnt：%zi", self, range.location, range.length, self.count);
    
    return nil;
}


@end

#pragma mark - NSDictionary
@implementation NSDictionary (Swizzled)

+ (void)load {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        [NSDictionary sw_swizzleClassMethod:@selector(dictionaryWithObject:forKey:)
                              withNewMethod:@selector(sw_dictionaryWithObject:forKey:)];
        
        [NSDictionary sw_swizzleClassMethod:@selector(dictionaryWithObjects:forKeys:count:)
                              withNewMethod:@selector(sw_dictionaryWithObjects:forKeys:count:)];
    });
}

+ (instancetype)sw_dictionaryWithObject:(id)object forKey:(id <NSCopying>)key {
    if (object && key) {
        return [self sw_dictionaryWithObject:object forKey:key];
    }
    SWLog(@"Init Dic Obj：%@ Key：%@", object, key);
    
    return nil;
}

+ (instancetype)sw_dictionaryWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt {
    NSInteger index = 0;
    id allKey[cnt];
    id allObj[cnt];
    
    for (NSInteger i = 0; i < cnt; i ++) {
        if (keys[i] && objects[i]) {
            allKey[i] = keys[i];
            allObj[i] = objects[i];
            index ++;
        }
    }
    
    return [self sw_dictionaryWithObjects:allObj forKeys:allKey count:index];
}


@end


#pragma mark - NSMutableDictionary
@implementation NSMutableDictionary (Swizzled)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict sw_swizzleInstanceMethod:@selector(setObject:forKey:)
                         withNewMethod:@selector(sw_setObject:forKey:)];
        
        [dict sw_swizzleInstanceMethod:@selector(removeObjectForKey:)
                         withNewMethod:@selector(sw_removeObjectForKey:)];
    });
}

- (void)sw_setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    if (aKey) {
        [self sw_setObject:anObject forKey:aKey];
        return ;
    }
    
    SWLog(@"Dict：%@ SetObj：%@ ForKey：%@", self, anObject, aKey);
}

- (void)sw_removeObjectForKey:(id)aKey {
    if (aKey) {
        [self sw_removeObjectForKey:aKey];
        return ;
    }
    
    SWLog(@"Dict：%@ RemoveForKey：%@", self, aKey);
}


@end

