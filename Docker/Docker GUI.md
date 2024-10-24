#### 什么是portainer
Docker图形化界面管理工具！提供一个后台面板供我们操作！
类似于 宝塔面板

#### 安装
```java
docker run -d -p 8088:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock --privileged=true portainer/portainer
```

![](https://i-blog.csdnimg.cn/blog_migrate/fb377d03db72fc9529b6d5b2d2273ffa.png)

![](https://i-blog.csdnimg.cn/blog_migrate/b85df53e368680c439603d4f05c875e4.png)

![](https://i-blog.csdnimg.cn/blog_migrate/73e489b8505443a1902cebae98aad9ba.png)
