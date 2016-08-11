//
//  AppDelegate.m
//  DaJiaZhuangXiu
//
//  Created by 有为iOS on 15/9/8.
//  Copyright (c) 2015年 有为iOS. All rights reserved.
//fang
/**
 *  11
 *
 *  @param AppDelegate <#AppDelegate description#>
 *
 *  @return <#return value description#>
 */

/**
 *  2
 *
 *  @param AppDelegate <#AppDelegate description#>
 *
 *  @return <#return value description#>
 */

#import "AppDelegate.h"
#import "UMSocial.h"
#import "MobClick.h"
#import "UMSocialWechatHandler.h"

#import "UMSocialSinaSSOHandler.h"


#import "UMSocialQQHandler.h"

#import "UMCheckUpdate.h"
#import "DJMainTabBarController.h"

#import "DJNavigationController.h"

#import "DJPushController.h"
#import "DJPushModel.h"
#import "MJExtension.h"
#import "DJTabItemBadgeValue.h"

#import "BadgeValueLocal.h"

#import "DJNewSetPushBadge.h"
#import "WeiboSDK.h"

#import "TuSDK/TuSDK.h"
#import "SVProgressHUDMessage.h"


#define SplashVersionKey @"splashVersionKey"
#define SplashImagePath  [NSHomeDirectory() stringByAppendingString:@"/Documents/splash.png"]

#define DWVersionKey @"current_version"
#define DWUserDefaults [NSUserDefaults standardUserDefaults]



// for mac
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

// for idfa
#import <AdSupport/AdSupport.h>
#import <ALBBSDK/ALBBSDK.h>


#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>

#import "DJNewGuideViewController.h"
#import "EMSDK.h"
#import "EaseUI.h"

@interface AppDelegate ()<UIAlertViewDelegate, WXApiDelegate>

/**
 *  进度信息提示！！！！！！！！！！！！！！！！这里很重要！！！！！！！！！！！！！！！！！！
 */
@property (nonatomic, retain) id<TuSDKICMessageHubInterface> messageHub;
// 返回遮罩
@property(nonatomic,strong)UIView *animationView;
@property(nonatomic,strong)UIAlertView *commentAlertView;
@property(nonatomic,strong)UIAlertView *upDataAlertView;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"develop";
#else
    apnsCertName = @"product";
#endif

    [[EaseSDKHelper shareHelper] hyphenateApplication:application
                        didFinishLaunchingWithOptions:launchOptions
                                               appkey:HuanXinIMAppKey
                                         apnsCertName:apnsCertName
                                          otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
  
//
    [DJUser setAdjustTimeIsExist:@(0)];

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSUserDefaults* ds =  [NSUserDefaults standardUserDefaults];
    [ds setObject:@"433fd9c4458061fef9a5fa9538faae52" forKey:SplashVersionKey];
    [ds synchronize];

    
    [TuSDK initSdkWithAppKey:@"888c1ecb53b6b2fd-03-w7txo1"];
    
    [TuSDK setLogLevel:lsqLogLevelDEBUG];//发布应用时请关闭日志
    
    [TuSDK shared].messageHub = [[SVProgressHUDMessage alloc]init];
    
    [self configUMAPPKeyAndID:launchOptions];// 配置推送和友盟等参数
  
    [self configUMTrack]; // 配置友盟监控
    
    UIApplication *app = [UIApplication sharedApplication];
    app.statusBarStyle = UIStatusBarStyleLightContent;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //设置根控制器
    DJMainTabBarController *mainTabBar = [[DJMainTabBarController alloc]init];
    self.window.rootViewController = mainTabBar;
    [self.window makeKeyAndVisible];
    
   
    [self addAnimationBeforeShow];
    
    
    [self judgeVersion];// 判断版本号及启动图
    
    [self addALBBSDK]; //阿里百川
    
    // 开启网络监听
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    return YES;
}

-(void)addALBBSDK{

//    [[ALBBSDK sharedInstance] setDebugLogOpen:YES]; // 打开debug日志
    [[ALBBSDK sharedInstance] setUseTaobaoNativeDetail:YES]; // 优先使用手淘APP打开商品详情页面，如果没有安装手机淘宝，SDK会使用H5打开
//    [[ALBBSDK sharedInstance] setViewType:ALBB_ITEM_VIEWTYPE_TAOBAO];// 使用淘宝H5页面打开商品详情
    [[ALBBSDK sharedInstance] setISVCode:@"my_isv_code"]; //设置全局的app标识，在电商模块里等同于isv_code
    [[ALBBSDK sharedInstance] asyncInit:^{ // 基础SDK初始化
        NSLog(@"init success");
    } failure:^(NSError *error) {
        NSLog(@"init failure, %@", error);
    }];
}


// 过节期间添加的显示图
-(void)addAnimationBeforeShow{
    
    NSUserDefaults* ds =  [NSUserDefaults standardUserDefaults];
    
    NSString * version = [ds objectForKey:SplashVersionKey];
  
    if (version!=nil) {// 此处判断用户偏好是否存在图片来添加
        
        UIImage *image =  [[UIImage alloc]initWithContentsOfFile:SplashImagePath];
        
        if (image!=nil) {
            
            
            [self addAnimation2Screen:image];
            
        }else{
            
            NSString *curVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
            // 获取上一次保证的最新版本号
            NSString *oldVersion = [DWUserDefaults objectForKey:DWVersionKey];
            if ([curVersion isEqualToString:oldVersion]) {
                float scale = [UIScreen mainScreen].scale; //获取当前屏幕分辨率倍数
                if ( scale >=3 ) {
                    [self addAnimation2Screen:[UIImage imageNamed:@"splash_pic@3x.jpg"]];

                } else {
                    [self addAnimation2Screen:[UIImage imageNamed:@"splash_pic@2x.jpg"]];

                }
            }else{
                
                [self blankAnimation1Screen];
                
            }
            
        }
        
    }else{
        
        float scale = [UIScreen mainScreen].scale;
        if ( scale >=3 ) {
            [self addAnimation2Screen:[UIImage imageNamed:@"splash_pic@3x.jpg"]];
            
        } else {
            [self addAnimation2Screen:[UIImage imageNamed:@"splash_pic@2x.jpg"]];
            
        }
        
    }
    
    
}
-(void)blankAnimation1Screen{

    
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];//self.animationView.bounds
    image.contentMode  =UIViewContentModeScaleAspectFill;
    image.image = [UIImage imageNamed:@"Default-568h@2x.png"];

    
    [[UIApplication sharedApplication].keyWindow addSubview:image];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        image.layer.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT+1);
        
    } completion:^(BOOL finished) {
        
        [NSThread sleepForTimeInterval:0.8];
        [image removeFromSuperview];
        
    }];

}
// 启动页完成后添加动画展示
-(void)addAnimation2Screen:(UIImage *)animaImage{
    
    float imageH = 133.3;
    
    if (IS_IPHONE_6Plus) {
        
        imageH = 133.3;
        
    }else if (IS_IPHONE_6) {
        
        imageH = 121.0;
        
    }else{
        
        imageH = 121.0;
    }
    
    self.animationView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-imageH)];//self.animationView.bounds
    image.contentMode  =UIViewContentModeScaleAspectFill;
    [self.animationView addSubview:image];
    image.image = animaImage;//[UIImage imageNamed:@"splash_pic"];//换成别的图
    
    
    UIImageView *image2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-imageH, kSCREEN_WIDTH, imageH)];
    
    image2.backgroundColor = [UIColor whiteColor];
    
    image2.image = [UIImage imageNamed:@"splash_bottom_label"];
    
    image2.contentMode  =UIViewContentModeCenter;
    
    [self.animationView  addSubview:image2];
    
    float scale = 15.0;
    float scale2 = 38/27.0;
    
    if (kSCREEN_WIDTH == 320.0&&kSCREEN_HEIGHT==480.0) {
        
        scale2 = 30/27.0;// 适配4s的放大
        
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.animationView];
    
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        image.layer.frame = CGRectMake(-scale, -scale, kSCREEN_WIDTH+2*scale, kSCREEN_WIDTH*scale2+2.5*scale);
        
    } completion:^(BOOL finished) {
        
        [NSThread sleepForTimeInterval:0.8];
        [self.animationView removeFromSuperview];
        
    }];
    
    
}
#pragma mark - 配置友盟的参数等

-(void)configUMAPPKeyAndID:(NSDictionary *)launchOptions {
    
    //**---------------------个推设置-------------------------------------*//
    // 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    
    if ([DJUser isLogin]) {
        [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];

    }
    
    NSString *curVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    
    // 获取上一次保证的最新版本号
    NSString *oldVersion = [DWUserDefaults objectForKey:DWVersionKey];
    
    if ([curVersion isEqualToString:oldVersion]) { //
        
        // 注册APNS
        [self registerUserNotification];
    }
    
    [self receiveNotificationByLaunchingOptions:launchOptions];
    
    // 处理远程通知启动APP
    
    [WeiboSDK enableDebugMode:YES];
    //**----------------------------------------------------------*//
    
    
    
    
    [UMCheckUpdate checkUpdateWithAppkey:@"5621bb36e0f55a642c009565" channel:@""];
    
    // 设置友盟检测版本
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];// 这样设置就会取到version号
    
    [MobClick startWithAppkey:@"5621bb36e0f55a642c009565" reportPolicy:BATCH   channelId:@""];
    [UMSocialData setAppKey:@"5621bb36e0f55a642c009565"];
    
    
    // 配置友盟分享微信
    [UMSocialWechatHandler setWXAppId:@"wx728ee6a241de0135" appSecret:@"c89c08f94611772038c3a4287a53a0f4" url:@"http://meijiaapp.com"];
    
    // 配置友盟分享QQ
    [UMSocialQQHandler setQQWithAppId:@"1104692351" appKey:@"b4yaTONkg9Ct3eoq" url:@"http://meijiaapp.com"];
    [UMSocialQQHandler setSupportWebView:YES];
    
    // 配置友盟分享新浪微博
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"3439592097"
                                              secret:@"065d4e2c3aefd76e97ae9d8168054f21"
                                         RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [WeiboSDK registerApp:@"3439592097"];
    
    
   
    // 商户APP工程中引入微信lib库和头文件，调用API前，需要先向微信注册您的APPID，代码如下：
    [WXApi registerApp:@"wx728ee6a241de0135" withDescription:@"DaJiaZhuangXiu.app"];
    
    
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url absoluteString] isEqualToString:@"tbopen23254348://"]) {
        BOOL isHandledByALBBSDK=[[ALBBSDK sharedInstance] handleOpenURL:url];//处理其他app跳转到自己的app，如果百川处理过会返回YES
        NSLog(@"%@",[NSNumber numberWithBool:isHandledByALBBSDK]);
        
        return isHandledByALBBSDK;
        
    }
    
    if ([url.host isEqualToString:@"safepay"]) {
        
        // 跳转支付宝钱包进行支付，处理支付结果 app被杀死支付走的方法
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSNotification * alipayNotification = [NSNotification notificationWithName:@"AliPayNotification" object:resultDic];
            [[NSNotificationCenter defaultCenter] postNotification:alipayNotification];
            
        }];
    }
    
    if ([url.host isEqualToString:@"pay"]) {
        
        return [WXApi handleOpenURL:url delegate:self];
        
    }

    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    if ([url.host isEqualToString:@"safepay"]) {
        
        // 跳转支付宝钱包进行支付，处理支付结果 app被杀死支付走的方法
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSNotification * alipayNotification = [NSNotification notificationWithName:@"AliPayNotification" object:resultDic];
            [[NSNotificationCenter defaultCenter] postNotification:alipayNotification];
            
        }];
        
    }
    
    if ([url.host isEqualToString:@"pay"]) {
        
        return [WXApi handleOpenURL:url delegate:self];
        
    }
   
    if ([[url absoluteString] isEqualToString:@"tbopen23254348://"]) {
           BOOL isHandledByALBBSDK=[[ALBBSDK sharedInstance] handleOpenURL:url];//处理其他app跳转到自己的app，如果百川处理过会返回YES
        NSLog(@"%@",[NSNumber numberWithBool:isHandledByALBBSDK]);
        
        return isHandledByALBBSDK;
        
    }
    
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    
    
    if ([url.host isEqualToString:@"safepay"]) {
        
        // 跳转支付宝钱包进行支付，处理支付结果 app被杀死支付走的方法
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSNotification * alipayNotification = [NSNotification notificationWithName:@"AliPayNotification" object:resultDic];
            [[NSNotificationCenter defaultCenter] postNotification:alipayNotification];
            
        }];
        
    }

    if ([url.host isEqualToString:@"pay"]) {
    
        return [WXApi handleOpenURL:url delegate:self];

    }

    return  [UMSocialSnsService handleOpenURL:url];

}

-(void) onResp:(BaseResp*)resp
{
    
    if ([resp isKindOfClass:[PayResp class]])
    {

        PayResp *response = (PayResp *)resp;
        
        /*
         * 从微信回调回来之后,发一个通知,让请求支付的页面接收消息,并且展示出来,或者进行一些自定义的展示或者跳转
         */
        NSNotification * notification = [NSNotification notificationWithName:@"WXPayNotification" object:response];
        [[NSNotificationCenter defaultCenter] postNotification:notification];

    }

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //    [self judgeVersion];
    
}

-(void)judgeVersion{// 判断版本号
 
    NSUserDefaults *defaulets = [NSUserDefaults standardUserDefaults];
    if ([defaulets objectForKey:@"initial_tab"] == nil) {
        [defaulets setObject:@"TAB_BUY_BY_PIC" forKey:@"initial_tab"];

    }
    [defaulets setObject:@"yes" forKey:@"suibianguang"];
    
    [defaulets synchronize];
    
    // 检查版本号
    NSUInteger lastestCancleTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"CancleUpdate"];
    
    NSUInteger recordTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"lastestCancleTime:%lu--recordTime:%lu",(unsigned long)lastestCancleTime,(unsigned long)recordTime);
    
    NSInteger a = recordTime - lastestCancleTime;
 
    if (lastestCancleTime==0) {//如果没有取消更新过，说明没被提示过更新或者直接更新了-需要去判断最新版本
        
        [self severVersionInfo];
        
    }else{// 被提示过更新，并被取消更新，二十四小时后去判断最新版本
        
        if (a>86400) {// 超过二十四小时了 86400 s==24 hour
            
            [self severVersionInfo];
            
        }// 假如先取消，二十四小时后更新了-还是需要去判断新版本
    }
    
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //    application.applicationIconBadgeNumber = 0;
    // 每次进入前台都去看看有没有新消息--进行标记，因为从后台到前台时，不进入控制器生命周期所以无法去刷新红点
    
    if ([DJUser isLogin]) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"HomePayLose" object:nil];

        
        // 发送通知刷新发布选择图片界面  用户可能增减图片，删除的话点击会导致崩溃
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ReloadPublishImages" object:nil];
        
        
        DJMainTabBarController *tab1 = (DJMainTabBarController*)[[UIApplication sharedApplication] keyWindow].rootViewController;
        
        if ([tab1 isKindOfClass:[DJMainTabBarController class]]&&tab1!=nil&&tab1 !=NULL&&![tab1 isEqual:[NSNull null]]) {
            
            if ([tab1 respondsToSelector:@selector(selectedIndex)]) {
                NSInteger index = tab1.selectedIndex;
                
                if (index==3) {
                    
                    NSString *notiName = @"ReloadTableViewData";
                    [[NSNotificationCenter defaultCenter]postNotificationName:notiName object:nil];
                    
                }
                
            }
            
            
        }
        
        [DJNewSetPushBadge messageUnreadCount];
        
        
        // 监控网络状态
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        NSInteger netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetWorkStatus" object:@(netStatus)];
        
//        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    }
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // 将校正时间置为不存在
    [DJUser setAdjustTimeIsExist:@(0)];
    
    
}

#pragma mark - 处理内存警告
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    
    // 1.取消正在下载的操作
    [mgr cancelAll];
    
    // 2.清除内存缓存
    [mgr.imageCache clearMemory];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


//**********************************个推方法**************************************//
#pragma mark - 用户通知(推送) _自定义方法

/** 注册用户通知 */
- (void)registerUserNotification {
    
    
    /*
     注册通知(推送)
     申请App需要接受来自服务商提供推送消息
     */
    
    // 判读系统版本是否是“iOS 8.0”以上
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ||
        [UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        
        // 定义用户通知设置
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        // 注册用户通知 - 根据用户通知设置
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else {      // iOS8.0 以前远程推送设置方式
        // 定义远程通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIRemoteNotificationType myTypes =  UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        
        // 注册远程通知 -根据远程通知类型
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    
    
}

/** 自定义：APP被“推送”启动时处理推送消息处理（APP 未启动--》启动）*/
- (void)receiveNotificationByLaunchingOptions:(NSDictionary *)launchOptions {
    if (!launchOptions) return;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    /*
     通过“远程推送”启动APP
     UIApplicationLaunchOptionsRemoteNotificationKey 远程推送Key
     */
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
//        NSLog(@"\n>>>[Launching RemoteNotification]:%@",userInfo);
    }
}


#pragma mark - 用户通知(推送)回调 _IOS 8.0以上使用

/** 已登记用户通知 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];

}

#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
        NSLog(@"%@",deviceToken);
        
    });
    
    NSLog(@"deviceToken %@\n\n",deviceToken);
    NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    myToken = [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [GeTuiSdk registerDeviceToken:myToken];
    
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n",myToken);
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [GeTuiSdk registerDeviceToken:@""];
    
    // 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
//    NSLog(@"\n>>>[DeviceToken Error]:%@\n\n",error.description);
}

#pragma mark - APP运行中接收到通知(推送)处理

/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;        // 标签
//    NSLog(@"\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"title"
//                                                    message:@"后台"
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                          otherButtonTitles:nil];
//    [alert show];
    NSLog(@"========按时开关打开哈哈就上班卡大家好");
    
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
        application.applicationIconBadgeNumber = 0;        // 标签
    // 处理APN
//    NSLog(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n",userInfo);

    
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
//        NSLog(@"处在活跃状态");
        
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
        
        
//        NSLog(@"处在后台状态跳转--%@",userInfo);// 已读和未读状态的修改--无效是因为后边的方法又赋值了，后边方法走了两遍
        //        NSInteger msgtype = [DJPushController msgType:userInfo[@"msg_type"]];
        //        switch (msgtype) {
        //            case 0:
        //                [BadgeValueLocal reduceReplyBadgeValue];
        //                break;
        //            case 1:
        //                [BadgeValueLocal reducePraiseBadgeValue];
        //
        //                break;
        //            case 2:
        //                [BadgeValueLocal reduceLikeBadgeValue];
        //                break;
        //            case 3:
        //                [BadgeValueLocal reduceSystemBadgeValue];
        //
        //                break;
        //            case 10:
        //
        //                break;
        //
        //            default:
        //                break;
        //        }
        
        DJPushModel *model = [DJPushModel objectWithKeyValues:userInfo];
        
        
        [DJPushController  rootController:nil pushModel:model];
        
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        
        
//        NSLog(@"处在未启动状态？");// 后台先到此一游
        
        
    }
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    
    if ([DJUser isLogin]) {
        NSString *userID =  [DJUser getUid];
        
        [GeTuiSdk bindAlias:userID];
        
        
    }
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *iosVersion = [NSString stringWithFormat:@"ios_%@",appVersion];
    [GeTuiSdk setTags:@[appVersion,@"ios",iosVersion]];// 绑定标签
//    BOOL sucess = [GeTuiSdk setTags:@[appVersion,@"ios",iosVersion]];// 绑定标签
//    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
//    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}


/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    
    // [4]: 收到个推消息
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes length:payload.length encoding:NSUTF8StringEncoding];
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:payload options:NSJSONReadingMutableContainers error:nil];
    
    
    //    NSInteger msgtype = [DJPushController msgType:dic[@"msg_type"]];
    
    //    if (msgtype==0||msgtype==1||msgtype==2||msgtype==3) {
    //
    //        [DJTabItemBadgeValue setBadgeValue:@"0" atTabIndex:3];//只有这几个类型推送才会有提醒
    //
    //    }
    //    switch (msgtype) {
    //
    //        case 0:
    //
    //            [BadgeValueLocal setReplyBadgeValue:NO];// NO代表不清零，去累加
    //
    //            break;
    //        case 1:
    //
    //            [BadgeValueLocal setLikeBadgeValue:NO];// 喜欢
    //
    //
    //            break;
    //        case 2:
    //
    //            [BadgeValueLocal setPraiseBadgeValue:NO];// 赞
    //
    //            break;
    //        case 3:
    //
    //            [BadgeValueLocal setSystemBadgeValue:NO];
    //            break;
    //
    //        case 10:// 不是要显示的类型消息
    //
    //            break;
    //        default:
    //            break;
    //    }
    //
//    NSLog(@"字典个推%@",dic);
    
    
    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    [GeTuiSdk sendFeedbackMessage:90001 taskId:taskId msgId:aMsgId];
}

#pragma mark -本地的通知处理
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {


    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
        //        NSLog(@"处在活跃状态");
        
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
        
        NSDictionary *userInfo = @{@"f":@(10000),@"t":@(20000)};
        
        
        DJPushModel *model = [DJPushModel objectWithKeyValues:userInfo];
        
        
        [DJPushController  rootController:nil pushModel:model];
        
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        
        
    }
   
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
//    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
//    NSLog(@"\n>>>[GexinSdk DidSendMessage]:%@\n\n",msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
//    NSLog(@"\n>>>[GexinSdk SdkState]:%u\n\n",aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
//        NSLog(@"\n>>>[GexinSdk SetModeOff Error]:%@\n\n",[error localizedDescription]);
        return;
    }
    
    NSLog(@"\n>>>[GexinSdk SetModeOff]:%@\n\n",isModeOff?@"开启":@"关闭");
}

//*************去请求最新版本号***************//

-(void)severVersionInfo{
    
    NSString *url = ADJUSTTIMEURL;
    [DJNetRequestGet GET:url parameters:nil success:^(id responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"启动的数据--%@",dic);
        
        if ([dic[@"code"] integerValue]==10000) {

            // 校正时间差
            long long recordTime = [[NSDate date] timeIntervalSince1970];
            long long time = [dic[@"data"][@"server_time"] longLongValue];
            [DJUser setDiffTime:time - recordTime];

            
            // 启动图
            NSString *newSplashVersion = dic[@"data"][@"mobile_splash_version"];
            NSString *splashUrl =  dic[@"data"][@"mobile_splash"];
            
            NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
            NSString *oldSplashVersion = [defaults objectForKey:SplashVersionKey];
            
            if (![oldSplashVersion isEqualToString:newSplashVersion]&&![newSplashVersion isEqualToString:@""]) {
                
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:splashUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    
                    [UIImagePNGRepresentation(image) writeToFile:SplashImagePath atomically:YES];
                    [defaults setObject:newSplashVersion forKey:SplashVersionKey];
                    [defaults synchronize];
                    
                }];
                
            }
            
            
            
            //  版本比较 是否更新提示
            NSString *latestVersion =  dic[@"data"][@"ios_latest_version"];
            
            NSString *localVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            // NSString *localVersion = [@"1.3.0" stringByReplacingOccurrencesOfString:@"." withString:@""];
            latestVersion = [latestVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            NSInteger c =  latestVersion.integerValue-localVersion.integerValue;
            
            
            if (c>0) {
                
                
                [self addUpDataAlertView];
                
            }else{
                
                NSString *isNeedComment =  dic[@"data"][@"ios_version_need_comment"];
                if (isNeedComment.integerValue==0) {
                    
                    // 不需要提示去评论
                    return ;
                    
                }else{
                    
                    // 提示去评论
                    
                    NSString *localVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]stringByReplacingOccurrencesOfString:@"." withString:@""];
                    
                    NSInteger hasUpdate = [[NSUserDefaults standardUserDefaults]integerForKey:localVersion];
                    
                    NSInteger nextWeek = [[NSUserDefaults standardUserDefaults]integerForKey:@"nextWeekCall"];
                    
                    NSInteger nextDay = [[NSUserDefaults standardUserDefaults]integerForKey:@"nextDayCall"];
                    
                    UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
                    
                    
                  
                    
                    if (hasUpdate==0 ) {// 如果是本版本第一次进 不弹框----优先级1
                        
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:localVersion];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        return ;
                    }
                    
                    if (hasUpdate > 1) {// 如果>1代表本版本点了去打分了->存储了时间戳--优先级2
                        
                        return;
                    }
                    
                    if (nextDay > 0&&(recordTime-nextDay)<86400*1) {// 不到三天--优先级3 //
                        
                        return ;
                    }
                    if (nextWeek > 0&&(recordTime-nextWeek)<86400*7) {// 不到一周---优先级3
                        
                        return;
                    }
                    
                    
                    
                    [self performSelector:@selector(addCommentAlertView:) withObject:dic afterDelay: 10];

                }
                
            }
            
//            NSLog(@"**%@--%@***",latestVersion,localVersion);
            
        }
        
    } failure:^(NSError *error) {
        
        
    }];
    
}
-(void)addCommentAlertView:(NSDictionary *)dic{
    
    NSDictionary *data = dic[@"data"];

    NSDictionary *cancelDic = data[@"ios_comment_buttons"];
    
    if (cancelDic.count>0) {
        if (IOS_VERSION<8) {
            
            self.commentAlertView = [[UIAlertView alloc]initWithTitle:data[@"ios_comment_title"] message:data[@"ios_comment_desc"] delegate:self cancelButtonTitle:cancelDic[@"happy"] otherButtonTitles:cancelDic[@"next"], cancelDic[@"anger"],nil];
            
            [_commentAlertView show];
        }else{

            
            UIAlertController *CommentAlertController = [UIAlertController alertControllerWithTitle:data[@"ios_comment_title"] message:data[@"ios_comment_desc"] preferredStyle:UIAlertControllerStyleAlert];
            UInt64 recordTime = [[NSDate date] timeIntervalSince1970];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelDic[@"anger"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                拒绝
                // 本版本不再提示--所以要存版本号
                NSString *localVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]stringByReplacingOccurrencesOfString:@"." withString:@""];
                [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:localVersion];
                
            }];
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:cancelDic[@"happy"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                赞
//                NSLog(@"赞！ 好评！");
                
                [self goEvaluation];
                
                // 本版本不再提示--所以要存版本号
                NSString *localVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]stringByReplacingOccurrencesOfString:@"." withString:@""];
                [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:localVersion];

                
            }];
            UIAlertAction *nextAction = [UIAlertAction actionWithTitle:cancelDic[@"next"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                下次
//                NSLog(@"下次再说");
                
                [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:@"nextDayCall"];
                
            }];
            
            [CommentAlertController addAction:nextAction];
            [CommentAlertController addAction:cancelAction];
            [CommentAlertController addAction:OKAction];
            
            UIViewController *vc = [UIApplication sharedApplication].windows[0].rootViewController;

            
            [vc presentViewController:CommentAlertController animated:YES completion:nil];

            
        }
        
      
    }
    
   
    
}



#pragma mark alertView代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView == _upDataAlertView) { //更新的提醒
        
        if (buttonIndex == 0) {
            
            UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
            
            [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:@"CancleUpdate"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else{
//            NSLog(@"去更新");
            
            [self outerOpenAppWithIdentifier:@"1044916912"];
            
        }
        
    }
    
    if (alertView == _commentAlertView) { // 评论的提醒
        
        UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
        
        if (buttonIndex==1) {
            // 取消
//            NSLog(@"下次再说");
            
            [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:@"nextDayCall"];
            
        }else if(buttonIndex== 0){
            // 打赏
//            NSLog(@"赞！ 好评！");
            
            [self goEvaluation];
            
            // 本版本不再提示--所以要存版本号
            NSString *localVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]stringByReplacingOccurrencesOfString:@"." withString:@""];
            [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:localVersion];
            
            
        }else if (buttonIndex==2){
            // 下次
//            NSLog(@"残忍拒绝");
            
            // 本版本不再提示--所以要存版本号
            NSString *localVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]stringByReplacingOccurrencesOfString:@"." withString:@""];
            [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:localVersion];
            
            
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -- 添加更新提醒
-(void)addUpDataAlertView{
    
    if (IOS_VERSION<8) {
        self.upDataAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"美家有新版本了" delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"去更新", nil];
        [_upDataAlertView show];
        
    }else{
    
        UIAlertController *upDataAlertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"美家有新版本了" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
            
            [[NSUserDefaults standardUserDefaults] setInteger:recordTime forKey:@"CancleUpdate"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            NSLog(@"去更新");
            
            [self outerOpenAppWithIdentifier:@"1044916912"];
        }];
        
        
        
        [upDataAlertController addAction:OKAction];
        [upDataAlertController addAction:cancelAction];
        if ([DJUser isLogin]) {
            UIViewController *vc = [UIApplication sharedApplication].windows[0].rootViewController;
            [vc presentViewController:upDataAlertController animated:YES completion:nil];
        }else{
        
            DJNewGuideViewController *guideVC = [DJNewGuideViewController shareDJNewGuideViewController];
            [guideVC presentViewController:upDataAlertController animated:YES completion:nil];
            
        }
       

    }
}


#pragma mark -- 去评价
- (void)goEvaluation{
    
    NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",@"1044916912"];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];
    
}


// 打开应用商店
- (void)outerOpenAppWithIdentifier:(NSString *)appId {
    
    NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8", appId];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];
    
}



#pragma mark - 配置友盟监控
- (void)configUMTrack {
    
    NSString *appKey = @"5621bb36e0f55a642c009565";
    NSString *deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *mac = [self macString];
    NSString *idfa = [self idfaString];
    NSString *idfv = [self idfvString];
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@",appKey, deviceName, mac, idfa, idfv];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] delegate:nil];
    
}

#pragma mark - 获取mac
- (NSString *)macString {
    
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5]=if_nametoindex("en0")) == 0 ) {
        
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",*ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);

    return macString;
    
}

#pragma mark - 获取idfa
- (NSString *)idfaString {
    
    NSBundle *addSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [addSupportBundle load];
    
    if (addSupportBundle == nil) {
        return @"";
    } else {
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        if (asIdentifierMClass == nil) {
            return @"";
        } else {
     
            // for arc
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            if (asIM == nil) {
                return @"";
            }else {
                if (asIM.advertisingTrackingEnabled) {
                    return [asIM.advertisingIdentifier UUIDString];
                }else {
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
            
        }
        
    }
   
    
//    return nil;
}

#pragma mark - 获取idfv
- (NSString *)idfvString {
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    return @"";
}



@end
