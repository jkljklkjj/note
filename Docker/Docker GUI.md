#### 什么是portainer
Docker图形化界面管理工具！提供一个后台面板供我们操作！
类似于 宝塔面板

#### 安装
```java
docker run -d -p 8088:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock --privileged=true portainer/portainer
```
![[Pasted image 20240917165529.png]]

![[Pasted image 20240917165543.png]]
