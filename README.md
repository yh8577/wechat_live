# wechat_live
使用方法 

1. 设置服务器器,直接在聊天窗口输入命令

#服务器192.168.31.1 (这里替换自己的服务器ip)

2.开启命令

#ksp

3.关闭命令

#gsp

4.切换前后摄像头

#hjt

服务器搭建 

服务器系统 Ubuntu 安装 nginx 和 srs 简单配置一下即可 .

nginx直接在github clone 到服务器 
nginx 设置
nginx安装好后在nginx.conf文件中最后加入
```
rtmp {

    server {
        listen 2018;
        application rtmplive {
            live on;
            max_connections 1024;
            
        }
        
        application hls{
        
            live on;
            hls on;
            hls_path /usr/local/var/www/hls;
            hls_fragment 1s;
        }
    }
    
}
```
重启Nginx: nginx -s reload 是配置生效

srs配置
~/srs/trunk/conf 目录新建一个 .conf的文件 配置内容如下
```
listen              2018;

max_connections     1000; 

http_server {

    enabled         on;
    listen          8080;
    dir             ./objs/nginx/html;
    
}

vhost __defaultVhost__ {
    
    hls {
        enabled         on;
        hls_path        ./objs/nginx/html;
        hls_fragment    5;
        hls_window      60;
    }

    http_remux {
        enabled     on;
        mount       [vhost]/[app]/[stream].flv;
        hstrs       on;
    }

    gop_cache       off;
    queue_length    10;
    min_latency     on;
    mr {
        enabled     off;
    }
    mw_latency      100;
    tcp_nodelay     on;

}
```
然后运行命令是配置生效
./objs/srs -c conf/名称.conf

