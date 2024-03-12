Spring Boot官方推荐优先使用带有-spring的文件名作为你的日志配置（如使用 logback-spring.xml，而不是 logback.xml），命名为 logback-spring.xml 的日志配置文件，将 xml 放至 src/main/resource 下面。



在讲解log'back-spring.xml之前我们先来了解三个单词：**Logger, Appenders and Layouts（记录器、附加器、布局）：Logback基于三个主要类：Logger，Appender和Layout。这三种类型的组件协同工作，使开发人员能够根据消息类型和级别记录消息，并在运行时控制这些消息的格式以及报告的位置。首先给出一个基本的xml配置如下**