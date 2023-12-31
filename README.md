# merlin_ddnspod

ddnspod supported ipv4 & ipv6 for merlin koolshare

## 为避免服务器因访问过于频繁而限制，程序增加了本地验证，不要手动将服务器的解析设置成一个不正确的地址来验证插件是否正确工作！

对于K3来说，tb梅林380.70-X7.9.1就是380终极版。本人认为也是最好用的版本！各种384、386虽然各有好处，但大都不稳定。

软件中心自带原ddnspod 0.1.6只有ipv4解析，所以自己动手改一个出来用。改动如图：

![29761FA9](https://github.com/alal001/merlin_ddnspod/assets/39854347/ad69d012-8fa8-41d6-a5a7-4b0b8f472fa7)

一、使用方法：

    1、先安装原koolshare软件中心的ddnspod 0.1.6

    2、将本仓库中的ddnspod.sh 上传到路由 /koolshare/ddnspod/ 目录覆盖原文件

    3、将本仓库中的Module_ddnspod.asp 上传到路由 /koolshare/webs/ 目录覆盖原文件

    4、按说明填写信息即可

二、注意事项

    1、程序以自用为目的，未经严格测试，不对其造成的任何后果负责！
    
    2、本人对shell语言并不熟悉，对koolshare软件某些动作机制也不了解，bug再所难免！
    
    3、本程序在原0.1.6基础上改的，主要改动shell逻辑代码，只少量改动asp网页，未改koolshare交互代码。

    4、未删除原0.1.6版本的任何标志标识，如造成侵权请告知，收到后第一时间整改或删除本库。
    
    5、试用本程序虽不会冒烟着火，但你得有最坏可能恢复出厂设置的准备，请做好jffs、插件及系统设置备份！

三、更新说明

    2023.12.19：（version 0.1.7）
        1、修改原用户名输入框为ipv6子域名输入
        2、修改原密码输入框为ipv4子域名输入
        3、修改原全域名输入框为主域名输入
        4、在原基础上加入ipv6域名解析功能
        5、修改原本机ipv4的获取方式，改从本机获取
        6、修改域名解析的ip获取方式为从官方API获取
        7、增加记录类型识别
    
    2023.12.20：（version 0.1.8）
        1、增加本地验证ip解析，大幅提高验证频率，可以每五分钟验证一次（原一小时一次）
        2、修改网页刷新页面，改成以分钟计时
        3、修复上一版已知bug

    2023.12.21：（version 0.1.9）
        1、增加更新解析后，重启dnsmasq
        2、修复上一版已知bug
        3、改进更新逻辑，可能已经能正常使用了，至少不太可能造成系统崩溃

    2023.12.26：（version 0.2.0）
        1、改进start 逻辑，可能不会再出莫名奇妙的乱更新

    2023.12.28：（version 0.3.0）
        1、改进程序逻辑，尽量避免用户填写不正确引发错误
        2、支持双栈配置，可同时为ipv4子域名配置ipv6的同名解析