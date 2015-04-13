//
//  NetManager.h
//  HW_CoreData
//
//  Created by Артур Сагидулин on 13.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Site.h"

@interface NetManager : NSObject
+(instancetype)sharedInstance;
-(void)downloadSite:(Site *)site:(void(^)(Site *site))completion;
@end
