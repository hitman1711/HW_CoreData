//
//  Site.h
//  HW_CoreData
//
//  Created by Артур Сагидулин on 13.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Site : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) id preview;

@end
