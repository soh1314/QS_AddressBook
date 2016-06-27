//
//  JRAdressInfo.h
//  QS_addressBook
//
//  Created by jingshuihuang on 16/6/27.
//  Copyright © 2016年 QS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRAdressInfo : NSObject
@property (nonatomic,copy)NSString * name;
@property (nonatomic , strong) NSMutableArray * phoneArray;
@property (nonatomic , copy) NSString * address;
@property (nonatomic , copy) NSString * otherInfo;
@property (nonatomic , strong) NSData * avartar;

@end
