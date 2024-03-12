# Node 端







# JAVA 端

1，微服务项目中需要添加远程调用Node服务注解

```java
@EnableNodeRegister
```

2，配置启动加载参数，因为该注解是需要几个参数才能运行

```java
--host // 本机IP
--port // 本机端口
--node-reg-host // node 的注册中心IP
--node-reg-port // node 的注册中心端口
```

可以自己在 Idea 启动项去配置，但是后续我们采用的脚本启动，所以这些东西是配置在

`toolchain/deploy/dev/index.js`

找到 `additionalArguments`

在其中添加要配置的微服务参数

以 `invoice` 为例子

```js
invoice: {
  'node-reg-host' : '10.10.5.4',
  'node-reg-port' : 2731
}
```



而本机的 `HOST` 本来是默认配置好的为：'project-h5

由于是本机测试，所以需要改写一下为本机ip 

配置信息放在

```javascript
const SERVICE_HOST = 'project-h5'
```

