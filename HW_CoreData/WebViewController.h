//
//  WebViewController.h
//  HW_CoreData
//
//  Created by Артур Сагидулин on 13.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property NSData *data;
@property NSURL *url;
@end

