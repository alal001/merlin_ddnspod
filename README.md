# merlin_ddnspod
ddnspod supported ipv4 & ipv6 for merlin koolshare

对于K3来说，tb梅林380.70-X7.9.1就是380终极版。本人认为也是最好用的版本！各种384、386虽然各有好处，但大都不稳定。

软件中心自带原ddnspod 0.1.6只有ipv4解析，所以自己动手改一个出来用。改动如图：

![29761FA9](https://github.com/alal001/merlin_ddnspod/assets/39854347/fa3b40d1-3c70-4916-89ac-aea7843fa7e0)

一、使用方法：

    1、先安装原koolshare软件中心的ddnspod 0.1.6

    2、将本仓库中的ddnspod.sh 上传到路由 /koolshare/ddnspod/ 目录覆盖原文件

    3、将本仓库中的Module_ddnspod.asp 上传到路由 /koolshare/webs/ 目录覆盖原文件

    4、按说明填写信息即可

二、注意事项

    1、程序以自用为目的，未经严格测试，不对其造成的任何后果负责！
    
    2、本人对shell语言并不熟悉，对koolshare软件某些动作机制也不了解，bug再所难免！
    
    3、本程序在原0.1.6基础上改的，虽然代shell逻辑代码改得可以说是面目全非，但asp网页和koolshare交互代码却只做了极少数改动。

    4、未删除原0.1.6版本的任何标志标识，如造成侵权请告知，收到后第一时间整改或删除本库。
    
    5、暂时定义为0.1.8版本，品质不保证！冒险试用虽不会因此软件冒烟着火，但你得有最坏可能恢复出厂设置的准备。

    6、请做好jffs、各插件以及系统设置的备份！
