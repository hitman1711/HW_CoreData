//
//  WebViewController.m
//  HW_CoreData
//
//  Created by Артур Сагидулин on 13.04.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController (){
    BOOL canLoad;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    canLoad = YES;
    [_webView loadData:_data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:_url];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return canLoad;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    canLoad = NO;
}

@end
