//
//  NSObject+Print.m
//  singsoundDemo
//
//  Created by Haitang on 17/8/31.
//  Copyright © 2017年 singsound. All rights reserved.
//

#import "NSObject+Print.h"
#import <objc/runtime.h>//导入runtime头文件

@implementation NSObject (Print)

-(NSString *)print{
    //初始化一个字典
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    //得到当前class的所有属性
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    //循环并用KVC得到每个属性的值
    for (int i = 0; i<count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name]?:@"nil";//默认值为nil字符串
        [dictionary setObject:value forKey:name];//装载到字典里
    }
    
    //释放
    free(properties);
    
    //return
    return [NSString stringWithFormat:@"<%@: %p> -- %@",[self class],self,dictionary];
}
@end