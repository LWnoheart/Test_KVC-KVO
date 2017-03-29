//
//  Person.m
//  Test_KVC-KVO
//
//  Created by 李巍 on 2017/3/29.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "Person.h"

@implementation Person

-(id)initWithName:(NSString *)name age:(NSInteger)age sex:(NSInteger)sex
{
    self = [super init];
    if (self) {
        self.name       = name;
        self.age        = age;
        self.sex        = sex;
    }
    return self;
}

-(void)swimmingInLocal:(NSString *)local
{
    NSLog(@"妈蛋！在%@游泳差点淹死",local);
}
@end
