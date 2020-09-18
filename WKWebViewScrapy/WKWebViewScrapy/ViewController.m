//
//  ViewController.m
//  WKWebViewScrapy
//
//  Created by Sun,Mingzhe on 2020/9/18.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadWebView];
    NSLog(@"你好");
    // Do any additional setup after loading the view.
}

// 加载爬取网页
- (void)loadWebView{
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://weibo.com/"]]];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.webView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"网页抓取结果:%@", result);
        [self writeToFileWithTxt:result];
    }];
    
    NSString *titleSrcString = [NSString stringWithFormat:@"document.getElementsByClassName('weibo-text')[0].getElementsByTagName('a')[0].href"];
    [self.webView evaluateJavaScript:titleSrcString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // 超话链接
        NSLog(@"标题链接抓取结果:%@", result);
    }];
    
    NSString *titleString = [NSString stringWithFormat:@"document.getElementsByClassName('weibo-text')[0].textContent"];
    [self.webView evaluateJavaScript:titleString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // 标题
        NSLog(@"标题抓取结果:%@", result);
    }];

    NSString *imageSrcString = [NSString stringWithFormat:@"document.getElementsByClassName('m-img-box')[0].getElementsByTagName('img')[0].src"];
    [self.webView evaluateJavaScript:imageSrcString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // 取一个头像地址
        NSLog(@"头像抓取结果:%@", result);
    }];
    
    NSString *authorString = [NSString stringWithFormat:@"document.getElementsByClassName('m-text-cut')[0].textContent"];
    [self.webView evaluateJavaScript:authorString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // 自媒体名称
        NSLog(@"自媒体名称抓取结果:%@", result);
    }];

}

//不论是创建还是写入只需调用此段代码即可 如果文件未创建 会进行创建操作
- (void)writeToFileWithTxt:(NSString *)string{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized (self) {
            //获取沙盒路径
            NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            //获取文件路径
            NSString *theFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"testLogs2.text"];
            NSLog(@"-- 文件地址%@", theFilePath);
            //创建文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //如果文件不存在 创建文件
            if(![fileManager fileExistsAtPath:theFilePath]){
                NSString *str = @"日志开始记录\n";
                [str writeToFile:theFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            NSLog(@"所写内容=%@",string);
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:theFilePath];
            [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
            NSData* stringData  = [[NSString stringWithFormat:@"%@\n",string] dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:stringData]; //追加写入数据
            [fileHandle closeFile];
        }
    });
}

@end
