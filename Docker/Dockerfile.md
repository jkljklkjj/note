dockerfile是用来构建docker镜像的文件！命令参数脚本！

构建步骤：  
1. 编写一个dockerfile文件  
2. docker build 构建成为一个镜像  
3. docker run运行镜像  
4. docker push发布镜像（DockerHub、阿里云镜像仓库！）

搭建步骤
1. 每个保留关键字（指令）都是必须是大写字母  
2. 执行从上到下顺序执行  
3. # 表示注释  
4. 每一个指令都会创建提交一个新的镜像层，并提交！
![](https://i-blog.csdnimg.cn/blog_migrate/0338d8b2eed5c1714c42f8850b42da31.png)

#### 命令
```bash
FROM        # 基础镜像，一切从这里开始构建
MAINTAINER    # 镜像是谁写的：姓名+邮箱
RUN            # 镜像构建的时候需要运行的命令
ADD            # 步骤：tomcat镜像，这个tomcat压缩包！添加内容
WORKDIR        # 镜像的工作目录
VOLUME        # 挂载的目录
EXPOSE        # 暴露端口配置
CMD            # 指定这个容器启动的时候要运行的命令，只有最后一个会生效，可被替代
ENTRYPOINT    # 指定这个容器启动的时候要运行的命令，可以追加命令
ONBUILD        # 当构建一个被继承DockerFile这个时候就会运行ONBUILD的指令。触发指令。
COPY        # 类似ADD，将我们文件拷贝到镜像中
ENV            # 构建的时候设置环境变量！
```
![](https://i-blog.csdnimg.cn/blog_migrate/7192340f11caa9cb6e52f49cc8810082.jpeg)

#### 实践
```bash
# 1. 编写dockerfile的文件
FROM centos:7
MAINTAINER sywl<xxx@qq.com>
ENV MYPATH /usr/local
WORKDIR $MYPATH
RUN yum -y install vim
RUN yum -y install net-tools
EXPOSE 80
CMD echo $MYPATH
CMD echo "-----end-----"
CMD /bin/bash
# 2. 通过这个文件构建镜像
# 命令：docker build -f dockerfile文件路径 -t 镜像名:[tag]
docker build -f mydockerfile-centos -t mycentos:0.1 .
Successfully built 285c2064af01
Successfully tagged mycentos:0.1
# 3. 测试运行
```

