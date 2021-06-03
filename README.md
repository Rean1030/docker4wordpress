# docker4wordpress
docker compose for wordpress with nginx

# docker环境部署

## linux安装

建议CentOS7，安装方法略。

## docker环境安装

### docker安装
1. 安装yum-utils：

  ```shell
  yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
  ```

2. 为yum源添加docker仓库位置：

  ```shell
  yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
  ```

3. 安装docker:

  ```shell
  yum install docker-ce
  ```

4. 启动docker:


  ```shell
  systemctl start docker
  systemctl enable docker
  ```

5. 安装上传下载插件：

  ```shell
  yum -y install lrzsz
  ```
### Docker Registry 2.0搭建

```shell
docker run -d -p 5000:5000 --restart=always --name registry2 registry:2
```

如果遇到镜像下载不下来的情况，需要修改 /etc/docker/daemon.json 文件并添加上 registry-mirrors 键值，然后重启docker服务：

```json
{
    "registry-mirrors": ["https://registry.docker-cn.com"]
}
```

### Docker开启远程API

#### 用vim编辑器修改docker.service文件

```shell
vim /usr/lib/systemd/system/docker.service
```

需要修改的部分：

```shell
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

修改后的部分：

```shell
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
```

#### 让Docker支持http上传镜像

```shell
echo '{ "insecure-registries":["10.2.33.155:5000"] }' > /etc/docker/daemon.json
```

*注：ip为自己服务器的。也可直接修改daemon.json文件`vim /etc/docker/daemon.json`如下：*

```json
{
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "https://hub-mirror.c.163.com",
        "https://dockerhub.azk8s.cn", 
        "http://10.2.33.155:5000"
    ],
 
    "insecure-registries": [
        "localhost:5000",
        "10.2.33.155:5000"
    ],
    
    "data-root": "/data/docker" # 指定docker数据目录，用于挂载数据盘时
}
```

#### 修改配置后需要使用如下命令使配置生效

```shell
systemctl daemon-reload
```

#### 重新启动Docker服务

```shell
systemctl restart docker
```

#### 开启防火墙的Docker构建端口

```shell
firewall-cmd --zone=public --add-port=2375/tcp --permanent
firewall-cmd --reload
```

### docker compose安装

1. 下载地址：https://github.com/docker/compose/releases 
2. 安装地址：/usr/local/bin/docker-compose

   命令如下：

```shell
curl -L https://get.daocloud.io/docker/compose/releases/download/1.28.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
```

2. 设置为可执行：

```shell
sudo chmod +x /usr/local/bin/docker-compose
```

3. 测试是否安装成功：

```shell
docker-compose --version
```

### 可视化管理工具

> Portainer 是一款轻量级的应用，它提供了图形化界面，用于方便的管理Docker环境，包括单机环境和集群环境，下面我们将用Portainer来管理Docker容器中的应用。

- 官网地址：https://github.com/portainer/portainer

- 获取Docker镜像文件：

```shell
docker pull portainer/portainer
```

- 使用docker容器运行Portainer：

```shell
docker run -p 9000:9000 -p 8000:8000 --name portainer \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /data/portainer/data:/data \
-d portainer/portainer
```

- 放开端口：

```shell
firewall-cmd --zone=public --add-port=9000/tcp --permanent
firewall-cmd --reload
```

- 查看Portainer的DashBoard信息：http://10.2.33.155:9000

# 运行安装wordpress
 