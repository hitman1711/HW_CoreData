//
//  NetManager.m
//  HW_CoreData
//
//  Created by Артур Сагидулин on 13.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "NetManager.h"

@implementation NetManager{
    dispatch_queue_t queue;
}

+(instancetype)sharedInstance{
    static id _singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        queue = dispatch_queue_create("NetManager", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(void)downloadSite:(Site *)site:(void(^)(Site *site))completion{
    dispatch_async(queue, ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        NSURL *url = [NSURL URLWithString:site.url];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *err) {
            if (!err) {
                site.data = data;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"ERROR!: %@", err.localizedDescription);
                });
            }
            dispatch_group_leave(group);
        }];
        [task resume];
        
        dispatch_group_enter(group);
        NSString *imgStringUrl = [NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain=%@", site.url];
        NSURL *imgUrl = [NSURL URLWithString:imgStringUrl];
        NSURLSessionDataTask *imgTask = [[NSURLSession sharedSession] dataTaskWithURL:imgUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *err) {
            
            if (!err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    site.preview = [UIImage imageWithData:data];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"ERROR!: %@", err.localizedDescription);
                });
            }
            dispatch_group_leave(group);
        }];
        [imgTask resume];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", @"inComplete");
            completion(site);
        });
    });
    
}


@end
