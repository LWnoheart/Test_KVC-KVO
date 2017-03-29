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


-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"person.name"];
    [self.person removeObserver:self forKeyPath:@"name"];
}

@end
