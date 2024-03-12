# SkyWalking

SkyWalking是一个开源监控平台，用于从服务和云原生基础设施收集、分析、聚合和可视化数据。

SkyWalking提供了一种简单的方法来维护分布式系统的清晰视图，甚至可以跨云查看。它是一种现代APM，专门为云原生、基于容器的分布式系统设计。

SkyWalking从三个维度对应用进行监视：service（服务）, service instance（实例）, endpoint（端点）

服务和实例就不多说了，端点是服务中的某个路径或者说URI



安装使用

可以选择两种数据源：一种是 H2 一种是 ES

配置 ES 就需要 启动 监听于 9200 端口的 ES，才能配合 SkyWalking 使用，当然也可以在配置中修改



启动UI Docker 命令

```shell
docker run \
--name skywalking-ui \
--restart no \
-p 8081:8080 -d \
--privileged=true \
--link oap:skywalking-oap \
-e TZ=Asia/Shanghai \
-e SW_OAP_ADDRESS=127.0.0.1:12800 \
-v /etc/localtime:/etc/localtime:ro \
apache/skywalking-ui:8.6.0
```





```shell
docker run --name oap-ui -p 8080:8080 --restart no apache/skywalking-ui:8.8.0
```





```
docker run --name oap-ui --restart no -d -e SW_OAP_ADDRESS=http://127.0.0.1:12800 apache/skywalking-ui
```