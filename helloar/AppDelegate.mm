/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#import "AppDelegate.h"
#include "easyar/utility.hpp"
#include <sys/types.h>
#include <sys/socket.h>
#include <string>
@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)parseMsg:(const struct msghdr *)msg
{
    struct cmsghdr *p_cmsg;
    struct iovec vec;
    p_cmsg = CMSG_FIRSTHDR(msg);
    vec=*(msg->msg_iov);
    size_t len=vec.iov_len;
    char *test=(char*)malloc((len+1)*sizeof(char));
    memcpy(test, vec.iov_base, len);    
    test[len]='\0';
    printf("payload %s\n",test);
    free(test);
}

void senddMsg(int sockfd, const struct msghdr *msg, int flags)
{
    [AppDelegate parseMsg:msg];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /*
    (void)application;
    (void)launchOptions;
    int send_fd=10;
    struct msghdr msg;
    struct cmsghdr *p_cmsg;
    struct iovec vec;
    char cmsgbuf[CMSG_SPACE(sizeof(send_fd))];
    int *p_fds;
    char sendchar = 'K';
    msg.msg_control = cmsgbuf;
    msg.msg_controllen = sizeof(cmsgbuf);
    p_cmsg = CMSG_FIRSTHDR(&msg);
    p_cmsg->cmsg_level = SOL_SOCKET;
    p_cmsg->cmsg_type = SCM_RIGHTS;
    p_cmsg->cmsg_len = CMSG_LEN(sizeof(send_fd));
    p_fds = (int *)CMSG_DATA(p_cmsg);
    *p_fds = send_fd; // 通过传递辅助数据的方式传递文件描述符
    
    msg.msg_name = NULL;
    msg.msg_namelen = 0;
    msg.msg_iov = &vec;
    msg.msg_iovlen = 1; //主要目的不是传递数据，故只传1个字符
    msg.msg_flags = 0;
    
    vec.iov_base = &sendchar;
    vec.iov_len = sizeof(sendchar);
    senddMsg(1,&msg,3);
     */
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    (void)application;
    EasyAR::onPause();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    (void)application;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    (void)application;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    (void)application;
    EasyAR::onResume();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    (void)application;
}

@end
