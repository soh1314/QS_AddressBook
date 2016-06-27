//
//  JRAddressBook.m
//  YingbaFinance
//
//  Created by jingshuihuang on 16/6/27.
//  Copyright © 2016年 huoqiangshou. All rights reserved.
//

#import "JRAddressBook.h"
#import <AddressBook/AddressBook.h>

@implementation JRAddressBook
+ (instancetype)defaultBook
{
    static JRAddressBook * book = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        book = [super allocWithZone:nil];
    });
    return book;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [JRAddressBook defaultBook];
}
+ (void)requestAuthorize:(void(^)())notDetermined authorized:(void(^)())authorized other:(void(^)())other;
{
    if ([self addressBookStatus] == JRAddressBookNotDetermined) {
        ABAddressBookRef book = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
            if (granted) {
                
                notDetermined();
            }
        });
        CFRelease(book);
    }
    else if ([self addressBookStatus] == JRAddressBookAuthorized)
    {
        ABAddressBookRef book = ABAddressBookCreate();
        CFRelease(book);
        authorized();
    }
    else
    {
        other();
    }
}
+ (JRAddressBookStatus)addressBookStatus
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        return JRAddressBookNotDetermined;
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        return JRAddressBookAuthorized;
    }
    else
    {
        return JRAddressBookOther;
    }
}
-(NSMutableArray *)addressPerson
{
    if (!_addressPerson) {
        _addressPerson = [NSMutableArray array];
        [_addressPerson addObjectsFromArray:[self addressNameArray]];
    }
    return _addressPerson;
}
- (NSMutableArray *)addressPhone
{
    if (!_addressPhone) {
        _addressPhone = [NSMutableArray array];
        
    }
    return _addressPhone;
}
- (NSArray *)addressNameArray
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    CFArrayRef personArr = ABAddressBookCopyArrayOfAllPeople(book);
    CFIndex count = ABAddressBookGetPersonCount(book);

    NSMutableArray * tem = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(personArr, i);
        NSString * personLastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString * personFirstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
       CFStringRef fullName = ABRecordCopyCompositeName(person);
        NSString * personName = nil;
        if ((__bridge id)fullName != nil) {
           personName = (__bridge NSString *)fullName;
        }
        else
        {
            personName = [NSString stringWithFormat:@"%@%@",personFirstName,personLastName];
        }
        [tem addObject:personName];
    }
    CFRelease(personArr);
    CFRelease(book);
    return tem;
}
- (NSArray *)addressPhoneArray
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    CFArrayRef personArr = ABAddressBookCopyArrayOfAllPeople(book);
    CFIndex count = ABAddressBookGetPersonCount(book);
    NSMutableArray * phoneNum = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(personArr, i);
        ABMultiValueRef phoneRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneCount = ABMultiValueGetCount(phoneRef);
        for (int i = 0; i < phoneCount; i++) {
            NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneRef,i);
            [phoneNum addObject:phoneValue];
        }
        CFRelease(phoneRef);
    }
    CFRelease(personArr);
    CFRelease(book);
    return phoneNum;
}
- (NSMutableArray *)personInfoArr
{
    if (!_personInfoArr) {
        _personInfoArr = [NSMutableArray array];
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        CFArrayRef personArr = ABAddressBookCopyArrayOfAllPeople(book);
        CFIndex count = ABAddressBookGetPersonCount(book);
        for (int i = 0; i < count; i++) {
            ABRecordRef record = CFArrayGetValueAtIndex(personArr, i);
            //名字
            NSString * lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
            NSString * firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
            CFStringRef fullName = ABRecordCopyCompositeName(record);
            NSString * personName = nil;
            if ((__bridge id)fullName != nil) {
                personName = (__bridge NSString *)fullName;
            }
            else
            {
                personName = [NSString stringWithFormat:@"%@%@",firstName,lastName];
            }
            JRAdressInfo * info = [[JRAdressInfo alloc]init];
            info.name = personName;
            //电话号码
            ABMultiValueRef phoneNumRef = ABRecordCopyValue(record, kABPersonPhoneProperty);
            CFIndex phoneNumCount = ABMultiValueGetCount(phoneNumRef);
            NSMutableArray * phoneNumArr = [NSMutableArray array];
            for (int j = 0; j < phoneNumCount ; j++) {
                NSString * phoneNum = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumRef, j);
                [phoneNumArr addObject:phoneNum];
            }
            info.phoneArray = phoneNumArr;
            //照片
        
            CFDataRef image = ABPersonCopyImageData(record);
            NSData * imageData = (__bridge_transfer NSData *)image;
            info.avartar = imageData;
            [_personInfoArr addObject:info];
        }
        CFRelease(personArr);
        CFRelease(book);
    }
    return _personInfoArr;
}
//分组的方法 --- 调用其他人写的方法
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


@end
