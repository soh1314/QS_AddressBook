//
//  ViewController.m
//  QS_addressBook
//
//  Created by jingshuihuang on 16/6/27.
//  Copyright © 2016年 QS. All rights reserved.
//

#import "ViewController.h"
#import "JRAddressBook.h"
@interface ViewController ()
@property (nonatomic , strong) UIImageView * imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [JRAddressBook requestAuthorize:^{
        NSLog(@"notDetermined");
    } authorized:^{
        NSLog(@"authorize");
    } other:^{
        NSLog(@"other");
    }];
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.view addSubview:_imageView];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray * tem = [[JRAddressBook defaultBook] addressNameArray];
    NSLog(@"%@",tem[1]);
    NSArray * tem1 = [[JRAddressBook defaultBook] addressPhoneArray];
    NSLog(@"%@",tem1[1]);
    NSMutableArray * tem3 =  [[JRAddressBook defaultBook] personInfoArr];
    NSMutableArray * tem4 = [self sortObjectsAccordingToInitialWith:tem3];
    
    for (int i = 0; i < tem4.count; i++) {
        NSArray * tem = tem4[i];
        for (int j = 0;j < tem.count; j++) {
               JRAdressInfo * info = tem[j];
            if (info.avartar) {
                _imageView.image = [UIImage imageWithData:info.avartar];
            }
               NSLog(@"%@",info.name);
        }
    }


}
-(NSMutableArray *)sortObjectsAccordingToInitialWith:(NSArray *)arr {
    
    // 初始化UILocalizedIndexedCollation
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //得出collation索引的数量，这里是27个（26个字母和1个#）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    //初始化一个数组newSectionsArray用来存放最终的数据，我们最终要得到的数据模型应该形如@[@[以A开头的数据数组], @[以B开头的数据数组], @[以C开头的数据数组], ... @[以#(其它)开头的数据数组]]
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    
    //将每个名字分到某个section下
    for (JRAdressInfo * personInfo in arr) {
        //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
        NSInteger sectionNumber = [collation sectionForObject:personInfo collationStringSelector:@selector(name)];
        //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
        NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
        [sectionNames addObject:personInfo];
    }
    
    //对每个section中的数组按照name属性排序
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *personArrayForSection = newSectionsArray[index];
        NSArray *sortedPersonArrayForSection = [collation sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(name)];
        newSectionsArray[index] = sortedPersonArrayForSection;
    }
    
    return newSectionsArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
