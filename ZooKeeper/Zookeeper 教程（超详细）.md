
#### 文章目录

## 1. Zookeeper 入门

### 1.1 概述

 Zookeeper 是一个开源的分布式的，为分布式应用提供协调服务的 Apache 项目。

 Zookeeper 从设计模式角度来理解：是一个基于观案者模式设计的分布式服务管理框架，它负责存储和管理大家都关心的数据，然后接受观察者的注册，一旦这些数据的状态发生变化，Zookeeper 就将负责通知已经在 Zookeeper 上注册的那些观察者做出相应的反应。

![](https://i-blog.csdnimg.cn/blog_migrate/b5b6b34fa9bb1e9511a71397ffa8f6d5.png)

### 1.2 特点

![](https://i-blog.csdnimg.cn/blog_migrate/f2a86367fd2f822a5a6e4ecee6d91e0b.png)

 1. Zookeeper：一个领导者（Leader） ，多个跟随者（Follower）组成的集群。
 1. 集群中只要有半数以上节点存活，Zookeeper 集群就能正常服务。
 1. 全局数据一致：每个 Server 保存一份相同的数据副本，Client 无论连接到哪个 Server，数据都是一致的。
 1. 更新请求顺序进行，来自同一个 Client 的更新请求按其发送顺序依次执行。
 1. 数据更新原子性，一次数据更新要么成功，要么失败。
 1. 实时性，在一定时间范围内，Client 能读到最新数据。

### 1.3 数据结构

  ZooKeeper 数据模型的结构与 Unix 文件系统很类似，整体上可以看作是一棵树，每个节点称做一个 ZNode。每一个 ZNode 默认能够存储 1 MB 的数据，每个 ZNode 都可以通过其路径唯一标识。 ![](https://i-blog.csdnimg.cn/blog_migrate/a32dde6e06892208eb5a036e20fc4441.png#pic_center)

### 1.4 应用场景

  提供的服务包括：统一命名服务、统一配置管理、统一集群管理、服务器节点动态上下线、软负载均衡等。

 1.  **统一命名服务** 在分布式环境下，经常需要对应用/服务进行统一命名 ，便于识别。例如：IP 不容易记住，而域名容易记住。 ![](https://i-blog.csdnimg.cn/blog_migrate/67d1c105a03bf16f393fc31f54f44faf.png) 
 1.  **统一配置管理** （1）分布式环境下，配置文件同步非常常见。   ① 一般要求一个集群中，所有节点的配置信息是一致的，比如 Kafka 集群。   ② 对配置文件修改后，希望能够快速同步到各个节点上。 （2）配置管理可交由 ZooKeeper 实现。   ① 可将配置信息写入 ZooKeeper 上的一个 Znode 。   ② 各个客户端服务器监听这个 Znode。   ③ 一旦 Znode 中的数据被修改，ZooKeeper 将通知各个客户端服务器。 ![](https://i-blog.csdnimg.cn/blog_migrate/45984ebf76a404fa7af18d38bab1129b.png) 
 1.  **统一集群管理** （1）分布式环境中，实时掌握每个节点的状态是必要的。   可根据节点实时状态做出一些调整。 （2）ZooKeeper 可以实现实时监控节点状态变化   ① 可将节点信息写入Z ooKeeper 上的一个 ZNode。   ② 监听这个 ZNode 可获取它的实时状态变化。 ![](https://i-blog.csdnimg.cn/blog_migrate/633825e96e1fc139478bd07907da2bfd.png) 
 1.  **服务器动态上下线** ![](https://i-blog.csdnimg.cn/blog_migrate/756616753b36ce5a031c97016e8846b7.png) 
 1.  **软负载均衡** 在 Zookeeper 中记录每台服务器的访问数，让访问数最少的服务器去处理最新的客户端请求。 ![](https://i-blog.csdnimg.cn/blog_migrate/8ed5429dc46ad84c212e066c6aa2a512.png) 

## 2. Zookeeper 安装

### 2.1 下载地址

### 2.2 本地模式安装部署

 1.  **准备工作** ① 拷贝 Zookeeper 安装包到 Linux 系统下（apache-zookeeper-3.5.6-bin.tar.gz） ② 解压到指定目录 

```bash
tar -zxvf apache-zookeeper-3.5.6-bin.tar.gz -C /hadoop/
```

    ③ 重命名

```bash
mv apache-zookeeper-3.5.6-bin/ zookeeper-3.5.6
```

 1.  **修改配置** ① 将 /hadoop/zookeeper-3.5.6/conf 这个路径下的 zoo_sample.cfg 修改为 zoo.cfg 

```bash
mv zoo_sample.cfg zoo.cfg
```

    ② 打开 zoo.cfg 文件，修改 dataDir 路径

```bash
dataDir=/hadoop/zookeeper-3.5.6/zkData
```

    ③ 在 /hadoop/zookeeper-3.5.6/ 这个目录上创建 zkData 文件夹

```bash
mkdir zkData
```

 1.  **修改环境变量** ① 打开配置文件 

```bash
vim /etc/profile
```

    ② 在配置文件中添加以下内容

```bash
#ZOOKEEPER
export ZOOKEEPER_HOME=/hadoop/zookeeper-3.5.6
export PATH=$PATH:$ZOOKEEPER_HOME/bin
```

    ③ 使配置文件生效

```bash
source /etc/profile
```

 1.  **操作 Zookeeper** ① 启动 Zookeeper 

```bash
zkServer.sh start
```

    ② 查看进程是否启动

```bash
jps
```

![](https://i-blog.csdnimg.cn/blog_migrate/c65e4e50488d5159096931dae583d777.png) 
    ③ 查看状态

```bash
zkServer.sh status
```

    ④ 启动客户端

```bash
zkCli.sh
```

    ⑤ 退出客户端

```bash
quit
```

    ⑥ 停止 Zookeeper

```bash
zkServer.sh stop
```

### 2.3 分布式安装部署

 1.  **集群规划** 在 master、slave1 和 slave2 三个节点上部署 Zookeeper。 
 1.  **解压安装** ① 解压 Zookeeper 安装包到 /hadoop/ 目录下 

```bash
tar -zxvf apache-zookeeper-3.5.6-bin.tar.gz -C /hadoop/
```

    ③ 重命名

```bash
mv apache-zookeeper-3.5.6-bin/ zookeeper-3.5.6
```

    ③ 同步 /hadoop/zookeeper-3.5.6 目录内容到 slave1、slave2

```bash
 xsync zookeeper-3.5.6/
```

 1.  **配置服务器编号** ① 在 /hadoop/zookeeper-3.5.6/ 这个目录下创建 zkData 

```bash
mkdir zkData
```

    ② /hadoop/zookeeper-3.5.6/zkData 目录下创建一个 myid 的文件

```bash
 touch myid
```

    ③ 编辑 myid 文件

```bash
vim myid
```

     在文件中添加与 server 对应的编号：

```bash
0
```

    ④ 分发到其他机器上

```bash
xsync myid
```

     并分别在 slave1、slave2 上修改 myid 文件中内容为 1、2

 1.  **配置 zoo.cfg 文件** ① 将 /hadoop/zookeeper-3.5.6/conf 这个路径下的 zoo_sample.cfg 修改为 zoo.cfg 

```bash
mv zoo_sample.cfg zoo.cfg
```

    ② 打开 zoo.cfg 文件，修改 dataDir 路径

```bash
dataDir=/hadoop/zookeeper-3.5.6/zkData
```

    增加如下配置

```
server.0=master:2888:3888
server.1=slave1:2888:3888
server.2=slave2:2888:3888
```

    ③ 同步 zoo.cfg 配置文件

```bash
xsync zoo.cfg
```

 1.  **修改环境变量** ① 打开配置文件 

```bash
vim /etc/profile
```

    ② 在配置文件中添加以下内容

```
#ZOOKEEPER
export ZOOKEEPER_HOME=/hadoop/zookeeper-3.5.6
export PATH=$PATH:$ZOOKEEPER_HOME/bin
```

    ③ 同步配置文件

```bash
xsync /etc/profile
```

    ④ 使配置文件生效（三台机器）

```bash
source /etc/profile
```

 1.  **集群操作** ① 三台机器分别启动 Zookeeper 

```bash
zkServer.sh start
```

    ② 三台机器分别关闭 Zookeeper

```bash
zkServer.sh stop
```

 1.  **编写 Zookeeper 的群起群关脚本** ① 在 /usr/local/bin 目录下创建 zk 文件 

```bash
vim zk
```

     在文件中输入以下内容：

```bash
#!/bin/bash

case $1 in
"start"){
   <!-- -->
  for i in master slave1 slave2
    do
      echo "****************** $i *********************"
      ssh $i "source /etc/profile &amp;&amp; zkServer.sh start"
    done
};;

"stop"){
   <!-- -->
  for i in master slave1 slave2
    do
      echo "****************** $i *********************"
      ssh $i "source /etc/profile &amp;&amp; zkServer.sh stop"
    done
};;

esac

```

    ② 修改脚本 zk 具有执行权限

```bash
chmod 777 zk
```

    ③ 调用脚本形式：<mark>zk start</mark> 或 <mark>zk stop</mark>

### 2.4 配置参数解读

  Zookeeper 中的配置文件 zoo.cfg 中参数含义解读如下：

 1.  **tickTime =2000：通信心跳数，Zookeeper 服务器与客户端心跳时间，单位毫秒** Zookeeper 使用的基本时间，服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个tickTime 时间就会发送一个心跳，时间单位为毫秒。它用于心跳机制，并且设置最小的 session 超时时间为两倍心跳时间。(session 的最小超时时间是 2*tickTime） 
 1.  **initLimit =10：LF 初始通信时限** 集群中的 Follower 跟随者服务器与 Leader 领导者服务器之间初始连接时能容忍的最多心跳数（tickTime的数量），用它来限定集群中的 Zookeeper 服务器连接到 Leader 的时限。 
 1.  **syncLimit =5：LF 同步通信时限** 集群中 Leader 与 Follower 之间的最大响应时间单位，假如响应超过 syncLimit * tickTime，Leader 认为 Follwer 死掉，从服务器列表中删除 Follwe
