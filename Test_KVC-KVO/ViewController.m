//
//  ViewController.m
//  Test_KVC-KVO
//
//  Created by 李巍 on 2017/3/29.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>

typedef id (*RIMP) (id,SEL, ...);//
typedef void (*NIMP) (id,SEL, ...);

@interface ViewController ()
@property (nonatomic,strong)Person *person;
@property (nonatomic,strong)NSArray *personArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 100, 50, 50);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    
    self.person = [[Person alloc]initWithName:@"呵呵" age:21 sex:0];
    
    [self addObserver:self forKeyPath:@"person.name" options:NSKeyValueObservingOptionNew context:@"context1"];
    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld context:@"context2"];
    
    
    Person *p1 = [[Person alloc]initWithName:@"张平" age:14 sex:1];
    Person *p2 = [[Person alloc]initWithName:@"董芬" age:21 sex:0];
    Person *p3 = [[Person alloc]initWithName:@"李娜娜" age:14 sex:0];
    Person *p4 = [[Person alloc]initWithName:@"王霸儿" age:23 sex:1];
    Person *p5 = [[Person alloc]initWithName:@"田刚" age:5 sex:1];
    Person *p6 = [[Person alloc]initWithName:@"孙淑芬" age:27 sex:0];
    Person *p7 = [[Person alloc]initWithName:@"周忠国" age:18 sex:1];
    
    self.personArray = @[p1,p2,p3,p4,p5,p6,p7];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"keyPath:%@____object:%@____context:%@____change:\n%@",keyPath,object,context,change);
    /*
     KVO 是 Objective-C 对观察者模式（Observer Pattern）的实现。也是 Cocoa Binding 的基础。当被观察对象的某个属性发生更改时，观察者对象会获得通知。
     
     KVO是基于runtime机制实现的
     当某个类的属性对象第一次被观察时，系统就会在运行期动态地创建该类的一个派生类，在这个派生类中重写基类中任何被观察属性的setter 方法。派生类在被重写的setter方法内实现真正的通知机制
     如果原类为Person，那么生成的派生类名为NSKVONotifying_Person
     每个类对象中都有一个isa指针指向当前类，当一个类对象的第一次被观察，那么系统会偷偷将isa指针指向动态生成的派生类，从而在给被监控属性赋值时执行的是派生类的setter方法
     键值观察通知依赖于NSObject 的两个方法: willChangeValueForKey: 和 didChangevlueForKey:；在一个被观察属性发生改变之前， willChangeValueForKey:一定会被调用，这就 会记录旧的值。而当改变发生后，didChangeValueForKey:会被调用，继而 observeValueForKey:ofObject:change:context: 也会被调用。
     补充：KVO的这套实现机制中苹果还偷偷重写了class方法，让我们误认为还是使用的当前类，从而达到隐藏生成的派生类
     
     
     
     
     触发类的willChangeValueForKey:和didChangeValueForKey:方法可以实现手动触发KVO
     http://tech.glowing.com/cn/implement-kvo/
     */
}


-(void)buttonPress:(UIButton *)btn
{
    [self keyPathAvg];
    [self keyPathMax];
    [self keyPathMin];
    [self keyPathSum];
    [self keyPathCount];
    [self keyPathUnionOfObjects];
    [self keyPathDistinctUnionOfObjects];
    
    self.person.name = @"大傻逼";
}


-(void)directCallMethod
{
    [self.person swimmingInLocal:@"游泳池"];
}

-(void)principleCallMethod
{
    SEL sel = sel_getUid("swimmingInLocal:");
    NIMP method = (NIMP)class_getMethodImplementation(object_getClass(self.person), sel);//objc_msg_lookup (self.person->isa,sel);
    method(self.person,sel,@"游泳池");
    
//    if !OBJC_OLD_DISPATCH_PROTOTYPES
//        typedef void (*IMP)(void /* id, SEL, ... */ );
//    else
//        typedef id (*IMP)(id, SEL, ...);
//    endif
//    在budingsetting中Enable Strict Checking of objc_msgSend Calls默认开启，IMP是无参数和返回值的，直接写IMP执行的话编译器会报错，所以重新定义一个和有参数的IMP指针相同的指针类型，在获取IMP时把它强转为此类型。另外需要区分IMP是否有返回值，假如有用的有返回值类型直接调用会出现EXC_BAD_ACCESS错误，所以定义一个无返回值的IMP。
}



//KVC中KeyPath的集合运算符，Key-Value Coding(KVC)
-(void)keyPathAvg//平均值
{
    NSInteger avg = [[self.personArray valueForKeyPath:@"@avg.age"]integerValue];
    NSLog(@"平均年龄%ld",(long)avg);
}

-(void)keyPathSum
{
    NSInteger sum = [[self.personArray valueForKeyPath:@"@sum.age"]integerValue];
    NSLog(@"年龄总和%ld",(long)sum);
}

-(void)keyPathMax
{
    NSInteger max = [[self.personArray valueForKeyPath:@"@max.age"]integerValue];
    NSLog(@"最大年龄%ld",(long)max);
}

-(void)keyPathMin
{
    NSInteger min = [[self.personArray valueForKeyPath:@"@min.age"]integerValue];
    NSLog(@"最小年龄%ld",(long)min);
}

-(void)keyPathCount
{
    NSInteger count = [[self.personArray valueForKeyPath:@"@count.age"]integerValue];//等价于self.personArray.count和[self.personArray valueForKey:@"@count"]
    NSLog(@"个数：%ld",(long)count);
}

-(void)keyPathUnionOfObjects//返回指定属性的值的数组，不去重
{
    NSArray *array = [self.personArray valueForKeyPath:@"@unionOfObjects.age"];
    NSLog(@"年龄集合\n%@",array);
}


-(void)keyPathDistinctUnionOfObjects//返回指定属性去重后的值的数组
{
    NSArray *array = [self.personArray valueForKeyPath:@"@distinctUnionOfObjects.age"];
    NSLog(@"年龄集合去重\n%@",array);
}

//还有unionOfArrays，distinctUnionOfArrays，distinctUnionOfSets，针对的是嵌套集合，比如[@[perArray,perArray2] valueForKeyPath:@"@unionOfArrays.name"];

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 KVC底层实现原理步骤
 第一步：寻找该属性有没有setsetter方法？有，就直接赋值
 第二步：寻找有没有该属性的成员属性？有，就直接赋值
 第三步：寻找有没有该属性带下划线的成员属性？有，就直接赋值
 */

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"person.name"];
    [self.person removeObserver:self forKeyPath:@"name"];
}

@end
