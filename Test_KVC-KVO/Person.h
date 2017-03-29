//
//  Person.h
//  Test_KVC-KVO
//
//  Created by 李巍 on 2017/3/29.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface Person : NSObject

@property (nonatomic,strong)NSString        *name;
@property (nonatomic,assign)NSInteger       age;
@property (nonatomic,assign)NSInteger       sex;

@property (nonatomic,strong)UIImage         *portrait;

-(id)initWithName:(NSString *)name age:(NSInteger)age sex:(NSInteger)sex;

-(void)swimmingInLocal:(NSString *)local;


@end
