//
//  JRAddressBook.h
//  YingbaFinance
//
//  Created by jingshuihuang on 16/6/27.
//  Copyright © 2016年 huoqiangshou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRAdressInfo.h"
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,JRAddressBookStatus)
{
    JRAddressBookNotDetermined = 0,
    JRAddressBookAuthorized,
    JRAddressBookOther
};

@interface JRAddressBook : NSObject
@property (nonatomic , strong) NSMutableArray * addressPerson;
@property (nonatomic , strong) NSMutableArray * addressPhone;
@property (nonatomic , strong) NSMutableArray * personInfoArr;

@property (nonatomic , assign) JRAddressBookStatus addressBookStatus;
+ (instancetype)defaultBook;
+ (JRAddressBookStatus)addressBookStatus;
+ (void)requestAuthorize:(void(^)())notDetermined authorized:(void(^)())authorized other:(void(^)())other;

- (NSArray *)addressNameArray;
- (NSArray *)addressPhoneArray;
- (NSMutableArray *)personInfoArr;

@end


