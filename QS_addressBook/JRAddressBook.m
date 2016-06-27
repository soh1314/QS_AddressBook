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
- (NSArray *)personInfoArray
{
    
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

@end
