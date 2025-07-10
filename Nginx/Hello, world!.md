1、首先在文档根目录`Docroot(/usr/local/var/www)`下创建html目录, 然后在html中放一个index.html

2、配置Nginx文件夹的`nginx.conf`中的server
```nginx
user mengday staff;

http {
    server {
	    # 代理服务器的端口
        listen       80;
        server_name  localhost;
        client_max_body_size 1024M;

        # 默认location，也就是代理资源的访问路径
        location / {
            root   /usr/local/var/www/html;
            index  index.html index.htm;
        }
    }
}
```

3、访问测试

- `http://localhost/` 指向`/usr/local/var/www/index.html`, index.html是安装nginx自带的html
- `http://localhost/test.html` 指向`/usr/local/var/www/html/test.html`

4、指令讲解
- server : 用于定义服务，http中可以有多个server块

- listen : 指定服务器侦听请求的IP地址和端口，如果省略地址，服务器将侦听所有地址，如果省略端口，则使用标准端口

- server_name : 服务名称，用于配置**域名**

- location : 用于配置映射路径uri对应的配置，一个server中可以有多个location, location后面跟一个uri,可以是一个正则表达式, / 表示匹配任意路径, 当客户端访问的路径满足这个uri时就会执行location块里面的代码

- root : 根路径，当访问`http://localhost/test.html`，“/test.html”会匹配到”/”uri, 找到root为`/usr/local/var/www/html`，用户访问的资源物理地址=`root + uri = /usr/local/var/www/html + /test.html=/usr/local/var/www/html/test.html`

- index : 设置首页，当只访问`server_name`时后面不跟任何路径是不走root直接走index指令的；如果访问路径中没有指定具体的文件，则返回index设置的资源，如果访问`http://localhost/html/` 则默认返回index.html