**通过日志排除，发现问题根源解决问题**

如果1台或者几台服务器，我们可以通过 linux命令，`tail、cat，通过grep、awk等`过滤去查询定位日志查问题

但是如果几十台、甚至几百台。通过这种方式肯定不现实。



## 市场上的产品

> 基于上述思路，于是许多产品或方案就应运而生了

- 简单的 Rsyslog，Syslog-ng

- 商业化的 Splunk

- 开源的

- - FaceBook 公司的 Scribe，
  - Apache 的 Chukwa，
  - Linkedin 的 Kafak，
  - Cloudera 的 Fluentd，
  - ELK

`Splunk`是一款非常优秀的产品，但是它是商业产品，价格昂贵，让许多人望而却步





## ELK 协议栈介绍及体系结构

`ELK`其实并不是一款软件，而是一整套解决方案，是三个软件产品的首字母缩写，`Elasticsearch`，`Logstash` 和 `Kibana`。这三款软件都是开源软件，通常是配合使用，而且又先后归于 Elastic.co 公司名下，故被简称为`ELK`协议栈



![img](https://pic1.zhimg.com/80/v2-243ba2bd5691d8189f139526ad4805d4_720w.webp)

一、ELK介绍
ELK是Elasticsearch,logash,kibana的结合。
Elasticsearch的功能：

1.搜索
2.全文检索
3.分析数据
4.处理海量数据PB,对海量数据进行近实时的处理(ES可以自动将海量数据分散到多台服务器上去存储和检索)
5.高可用高性能分布式搜索引擎数据库

Elasticsearch的应用场景：

1.网页搜索
2.新闻搜索
3.商品标签
4.日志收集分析展示



### Logstash

`Logstash` 是一个具有实时渠道能力的数据收集引擎。使用 JRuby 语言编写。其作者是世界著名的运维工程师乔丹西塞 (JordanSissel)

**主要特点**

- 几乎可以访问任何数据
- 可以和多种外部应用结合
- 支持弹性扩展

***它由三个主要部分组成\***，见图 4：

- Shipper－发送日志数据
- Broker－收集数据，缺省内置 Redis
- Indexer－数据写入



### Beats 作为日志搜集器

这种架构引入 `Beats` 作为日志搜集器。目前 `Beats`包括四种：

- `Packetbeat`（搜集网络流量数据）；
- `Topbeat`（搜集系统、进程和文件系统级别的 CPU 和内存使用情况等数据）；
- `Filebeat`（搜集文件数据）；
- `Winlogbeat`（搜集 Windows 事件日志数据）。

> `Beats` 将搜集到的数据发送到 `Logstash`，经 `Logstash` 解析、过滤后，将其发送到 `Elasticsearch`存储，并由 `Kibana` 呈现给用户。



### 基于 Filebeat 架构的配置部署详解

前面提到 Filebeat 已经完全替代了 Logstash-Forwarder 成为新一代的日志采集器，同时鉴于它轻量、安全等特点，越来越多人开始使用它。这个章节将详细讲解如何部署基于 Filebeat 的 ELK 集中式日志解决方案，具体架构见图 5。



Beats 还不支持输出到消息队列，所以在消息队列前后两端只能是 Logstash 实例。这种架构使用 Logstash 从各个数据源搜集数据，然后经消息队列输出插件输出到消息队列中。目前 Logstash 支持 Kafka、Redis、RabbitMQ 等常见消息队列。然后 Logstash 通过消息队列输入插件从队列中获取数据，分析过滤后经输出插件发送到 Elasticsearch，最后通过 Kibana 展示。详见图 4。



我的配置





用户名：elastic

密码：haZh8ZhV7F_xJQUvptIo



elastic 密码： D0wsD7BRbGLssin+K39S





docker cp  /Users/tujunjie/Desktop/IdeaProject/my/Maven_Demo/ELKService/src/main/resources/elasticsearch.yml   778c865b92a4:/usr/share/elasticsearch/config



docker cp dbf08f18b542:/usr/share/kibana/config/kibana.yml /Users/tujunjie/Desktop/IdeaProject/my/Maven_Demo/ELKService/src/main/resources





docker cp  /Users/tujunjie/Desktop/IdeaProject/my/Maven_Demo/ELKService/src/main/resources/kibana.yml b8548bba720a:/usr/share/kibana/config 

















# 9款日志采集和管理工具对比，选型必备！

小哈学Java *2023-04-18 09:02* *发表于安徽*

***\**\*点击关注公众号，Java干货\*\*\*\*及时送达\*\**\**\*👇\****

![图片](https://mmbiz.qpic.cn/sz_mmbiz_png/knmrNHnmCLHOSmVqujIhvPvP2xXM3sMd2ssfOZJgYibcxKTgCA6wPga8Ds3Jr5QoZRca9eYicP0Mal64TdlS45cg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)来源：blog.csdn.net/xcswswswws/article/details/122558274

- 1、Filebeat
- 2、Graylog
- 3、LogDNA
- 4、Elasticsearch, Logstash and Kibana （ELK stack or Elastic Stack）
- 5、Grafana Loki
- 6、Datadog
- 7、Logstash
- 8、Fluentd
- 9、Splunk

------

**简介**

对于日志管理当前网络上提供了大量的日志工具，今天就给大家分析总结一下这些常用工具的特点，希望对你们在选型时有所帮助，如果有用记得一键三连。

## ***\*1、Filebeat\****

Filebeat是用于转发和集中日志数据的轻量级传送程序。作为服务器上的代理安装，Filebeat监视您指定的日志文件或位置，收集日志事件，并将它们转发到Elasticsearch或Logstash进行索引。

Filebeat的工作方式如下：启动Filebeat时，它将启动一个或多个输入，这些输入将在为日志数据指定的位置中查找。对于Filebeat所找到的每个日志，Filebeat都会启动收集器。每个收集器都读取一个日志以获取新内容，并将新日志数据发送到libbeat，libbeat会汇总事件并将汇总的数据发送到您为Filebeat配置的输出。

![图片](https://mmbiz.qpic.cn/sz_mmbiz_png/knmrNHnmCLHOSmVqujIhvPvP2xXM3sMdIzfBhTcia8AXiamJxiaxQdIW9TUiaTib4VSGEWmNNGLcaopIWfcyutZEv8Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

图片

#### 1.1 主要特点

- 轻量级并且易使用
- 模块可用于常见用例（例如 Apache 访问日志）。您可以使用它们来设置 Filebeat、Ingest 和 Kibana 仪表板，只需几个命令

#### 1.2 价格

免费开源

#### 1.3 优点

- 资源使用率低
- 良好的性能

#### 1.4 缺点

有限的解析和丰富功能

## ***\*2、Graylog\****

Graylog是一个开源的日志聚合、分析、审计、展现和预警工具。功能上和ELK类似，但又比ELK要简单，依靠着更加简洁，高效，部署使用简单的优势很快受到许多人的青睐。

![图片](https://mmbiz.qpic.cn/sz_mmbiz_png/knmrNHnmCLHOSmVqujIhvPvP2xXM3sMdbZFZV9ZNeMRJSpzFpFycuZlpNEGfxul4h2LTUzXXYlDNflavPbAB2w/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

图片

#### 2.1 主要特点

- 一个包含日志处理所有要素的软件包：收集、解析、缓冲、索引、搜索、分析。
- 开源 ELK 堆栈无法提供的其他功能，例如基于角色的访问控制和警报

#### 2.2 价格

免费和开源，不过也有企业版(根据要求提供价格)

#### 2.3 优点

- 在一个软件包中满足大多数集中式日志管理用例的需求
- 轻松扩展存储 (Elasticsearch) 和获取通道

#### 2.4 缺点

- 可视化能力是有限的，至少与ELK的Kibana相比是如此
- 不能使用整个ELK生态系统，因为他们不能直接访问Elasticsearch API。相反，Graylog有自己的API

## ***\*3、LogDNA\****

LogDNA是日志管理领域的新成员。LogDNA可作为SaaS和内部使用，提供所有日志基础:通过syslog和HTTP(S)以及全文搜索和可视化，提供基于代理和无代理的日志收集，并提供清晰且具有竞争力的价格。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

图片

#### 3.1 主要特点

- 用于在组织外部共享日志的嵌入式视图
- 自动解析常用日志格式

#### 3.2 价格

- 免费：无存储
- 收费：付费计划起价为每月每GB 1.50 美元，保留 7 天

#### 3.3 优点

- 用于搜索日志的简单 UI，类似于 Papertrail
- 易于理解的计划

#### 3.4 缺点

- 可视化能力有限
- 保留期取决于计划（从 7 天到 30 天）。用户数量也是如此（最便宜的计划只允许 5 个）

## ***\*4、Elasticsearch, Logstash and Kibana (ELK stack or Elastic Stack)\****

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

图片

#### 4.1 主要特点

ELK堆栈包含了日志管理解决方案所需的大多数工具:

- Log shippers：如Logstash和Filebeat
- Elasticsearch是一个可扩展的搜索引擎
- Kibana作为搜索日志或构建可视化的UI

它在集中日志方面非常流行，有很多关于如何在网络上使用它的教程。有一个庞大的工具生态系统，您可以在基本设置之上使用这些工具，通过警报、基于角色的访问控制等来增强它。我们将在这篇博文中详细介绍这些额外的附加功能，我们将在其中讨论 Elastic Stack 功能的替代方案。

- Elasticsearch默认情况下对每个字段进行索引，使搜索速度更快
- 通过API和Kibana实现实时可视化
- 索引前的数据解析和充实

#### 4.2 价格

- 免费和开源。一些公司提供托管 ELK 的形式，见上文。
- 还有 Elastic Cloud，它是云中 ELK 的一种纯粹形式，您主要需要自己管理。

#### 4.3 优点

- 可扩展的搜索引擎作为日志存储
- 成熟的log shippers
- Kibana 中的 Web UI 和可视化

#### 4.4 缺点

- 在规模上，它可能变得难以维护。这就是 Sematext 提供 ELK 堆栈咨询、生产支持和培训的原因
- ELK Stack 的开源版本缺少一些功能，例如基于角色的访问控制和警报。您可以通过商业“Elastic Stack 功能”或其替代品或 Visa Open Distro for Elasticsearch 获得这些功能。

## ***\*5、Grafana Loki\****

Loki 及其生态系统是 ELK 堆栈的替代方案，但它做出了不同的权衡。通过仅索引某些字段（标签），它可以具有完全不同的架构。也就是说，主要的写入组件（Ingester）会将大量日志保存在内存中，从而使最近的查询速度更快。

随着块变老，它们被写入两个地方：用于标签的键值存储（例如 Cassandra）和用于块数据的对象存储（例如 Amazon S3）。当您添加数据时，它们都不需要后台维护（例如 Elasticsearch/Solr 需要合并）。

如果您查询较旧的数据，您通常会按标签和时间范围进行过滤。这限制了必须从长期存储中检索的块的数量。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

图片

#### 5.1 主要特点

- 同一 UI 中的日志和指标 (Grafana)
- Loki 标签可以与 Prometheus 标签保持一致

#### 5.2 价格

- 免费：免费开源
- 收费：还有Grafana Cloud，提供Loki的SaaS服务(也有内部部署的选项)。价格从49美元起，包括100GB的日志存储(30天保留)和3000个度量系列

#### 5.3 优点

- 与 ELK 相比，摄取速度更快：索引更少，无需合并
- 小存储占用：较小的索引，数据只写入一次到长期存储（通常具有内置复制）
- 使用更便宜的存储（例如 AWS S3）

#### 5.4 缺点

- 与 ELK 相比，较长时间范围内的查询和分析速度较慢
- 与 ELK 相比，log shippers选项更少（例如 Promtail 或 Fluentd）
- 不如 ELK 成熟（例如更难安装）

## ***\*6、Datadog\****

Datadog 是一种 SaaS，最初是作为监控 (APM) 工具，后来还添加了日志管理功能。您可以通过 HTTP(S) 或 syslog，通过现有的日志传送器（rsyslog、syslog-ng、Logstash 等）或通过 Datadog 自己的代理发送日志。

它的特点是 Logging without Limits™，这是一把双刃剑：更难预测和管理成本，但您可以获得即用即付定价（见下文）以及您可以存档和从存档中恢复的事实。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

图片

#### 6.1 主要特点

- 用于解析和丰富日志的服务器端处理管道
- 自动检测常见的日志模式
- 可以将日志归档到 AWS/Azure/Google Cloud 存储并在以后重新使用它们

#### 6.2 价格

- 处理起价为每月每GB 0.10 美元（例如 1GB 每天 3 美元）
- 处理也适用于从档案中获取，尽管这里的数据是压缩的
- 100 万个事件的存储起价为 1.59 美元，为期 3 天（例如，47.7 美元，1GB/天，每个 1K，存储 3 天）

#### 6.3 优点

- 容易搜索，良好的自动完成(基于facet)
- 与DataDog指标和跟踪的集成
- 负担得起，特别是对于短期保留和/或如果你依靠存档进行一些搜索

#### 6.4 缺点

- 现场不可用。一些用户抱怨成本失控（由于定价灵活）。虽然您可以设置每日处理配额

## ***\*7、Logstash\****

Logstash 是一个日志收集和处理引擎，它带有各种各样的插件，使您能够轻松地从各种来源摄取数据，将其转换并转发到定义的目的地。它与 Elasticsearch 和 Kibana 一起是 Elastic Stack 的一部分，这就是为什么它最常用于将数据传送到 Elasticsearch。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

图片

#### 7.1 主要特点

- 许多内置的输入、过滤/转换和输出插件
- 灵活的配置格式:您可以添加内联脚本，包括其他配置文件等

#### 7.2 价格

- 免费开源

#### 7.3 优点

- 容易开始和移动到复杂的配置
- 灵活:Logstash用于各种日志记录用例，甚至用于非日志记录数据
- 写得很好的文档和大量的操作指南

#### 7.4 缺点

- 与其他日志shippers相比，资源使用率高
- 与替代品相比，性能较低

## ***\*8、Fluentd\****

作为一个很好的 Logstash 替代品，Fluentd 是 DevOps 的最爱，特别是对于 Kubernetes 部署，因为它具有丰富的插件库。与 Logstash 一样，它可以将数据结构化为 JSON，并涉及日志数据处理的所有方面：收集、解析、缓冲和输出跨各种来源和目的地的数据。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

图片

#### 8.1 主要特点

- 与库和Kubernetes的良好集成
- 大量的内置插件，很容易编写新的

#### 8.2 价格

- 免费开源

#### 8.3 优点

- 良好的性能和资源使用
- 良好的插件生态系统
- 易于使用的配置
- 良好的文档

#### 8.4 缺点

- 解析前没有缓冲，可能会导致日志管道出现背压
- 对转换数据的支持有限，就像您可以使用 Logstash 的 mutate 过滤器或 rsyslog 的变量和模板一样

## ***\*9、Splunk\****

Splunk 是最早的商业日志集中工具之一，也是最受欢迎的。典型的部署是本地部署 (Splunk Enterprise)，尽管它也作为服务提供 (Splunk Cloud)。您可以将日志和指标发送到 Splunk 并一起分析它们。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

图片

#### 9.1 主要特点

- 用于搜索和分析的强大查询语言
- 搜索时字段提取（在摄取时解析之外）
- 自动将经常访问的数据移动到快速存储，将不经常访问的数据自动移动到慢速存储

#### 9.2 价格

- 免费：每天 500MB 数据
- 付费计划可应要求提供，但常见问题解答建议 1GB 的起价为 150 美元/月

#### 9.3 优点

- 成熟且功能丰富
- 对于大多数用例来说，良好的数据压缩(假设有有限的索引，正如推荐的那样)
- 日志和度量在一个屋檐下

#### 9.4 缺点

- 贵
- 对于较长的时间范围，查询速度较慢(建议使用有限的索引)
- 用于度量存储的效率低于专注于监控的工具

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

\1. [Spring 6 正式“抛弃”feign](http://mp.weixin.qq.com/s?__biz=MzU4MDUyMDQyNQ==&mid=2247514536&idx=1&sn=85d2b4c269fca40b618624dccd9764e3&chksm=fd57692eca20e0383725d61bc14589913cd8cb2316a0420d1cb95a3a0d10e36a461cd3680ff3&scene=21#wechat_redirect)

\2. [Jenkins 真得很牛逼！只是大部分人不会用而已~(保姆级教程)](http://mp.weixin.qq.com/s?__biz=MzU4MDUyMDQyNQ==&mid=2247514520&idx=1&sn=665987053073567a150bfee403dd0f61&chksm=fd57691eca20e008cac5448fd0a6cff814352fb0f1069a30dbb6e2a394f37bcd1ce2463349b8&scene=21#wechat_redirect)

\3. [17 个方面，综合对比 Kafka、RabbitMQ、RocketMQ、ActiveMQ 四个分布式消息队列](http://mp.weixin.qq.com/s?__biz=MzU4MDUyMDQyNQ==&mid=2247514494&idx=1&sn=5c4c4c472f7842c73d72e0ccb94c1d05&chksm=fd5769f8ca20e0eeba4dc2b3bf1af49884e9c74673603b3228b561ae7bd53bd39b5d384cff2b&scene=21#wechat_redirect)

\4. [网站上线了一款在线小工具~](http://mp.weixin.qq.com/s?__biz=MzU4MDUyMDQyNQ==&mid=2247514481&idx=1&sn=051c3e9996372b2c42393e1b7091d042&chksm=fd5769f7ca20e0e1353cc08f8780ef70867507555a277e5f0edb3631cbcab431f020f0bf984e&scene=21#wechat_redirect)

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

```
最近面试BAT，整理一份面试资料《Java面试BATJ通关手册》，覆盖了Java核心技术、JVM、Java并发、SSM、微服务、数据库、数据结构等等。获取方式：点“在看”，关注公众号并回复 Java 领取，更多内容陆续奉上。
PS：因公众号平台更改了推送规则，如果不想错过内容，记得读完点一下“在看”，加个“星标”，这样每次新文章推送才会第一时间出现在你的订阅列表里。点“在看”支持小哈呀，谢谢啦
```

阅读 2037







## Mac 安装 ELK

ES

校验ES是否正常运行

```sh
curl --cacert $ES_HOME/config/certs/http_ca.crt -u elastic https://localhost:9200 
```

所以我的目录就是

```
curl --cacert /Users/tujunjie/Downloads/ELK/elasticsearch-8.7.0/config/certs/http_ca.crt -u elastic https://localhost:9200 
```

密码： zpk1Hqg-mlQyHK0zthqu





K

​	





测试 L

```
bin/logstash -e 'input { stdin { } } output { stdout {} }'
```

