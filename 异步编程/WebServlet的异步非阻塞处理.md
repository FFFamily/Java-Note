# Servlet

Servlet是一个基于Java技术的Web组件，由容器管理，生成动态内容。像其他基于Java技术的组件一样，Servlet是与平台无关的Java类格式，它们被编译为与具体平台无关的字节码，可以被基于Java技术的Web Server动态加载并运行。容器（有时称为Servlet引擎）是Web服务器为支持Servlet功能扩展的部分。客户端通过Servlet容器实现请求/应答模型与Servlet交互。Servlet容器是Web Server或Application Server的一部分，其提供基于请求/响应模型的网络服务，解码基于MIME的请求，并且格式化基于MIME的响应。Servlet容器也包含了管理Servlet生命周期的能力，Servlet是运行在Servlet容器内的。Servlet容器可以嵌入宿主的Web Server中，或者通过Web Server的本地扩展API单独作为附加组件安装。Servelt容器也可能内嵌或安装到包含Web功能的Application Server中。



所有Servlet容器必须支持基于HTTP协议的请求/响应模型，并且可以选择性支持基于HTTPS协议的请求/应答模型。容器必须实现的HTTP协议版本包含HTTP/1.0和HTTP/1.1。Servlet容器应该使Servlet执行在一个安全限制的环境中。在Java平台标准版（J2SE, v.1.3或更高）或者Java平台企业版(Java EE, v.1.3或更高)的环境下，这些限制应该被放置在Java平台定义的安全许可架构中。比如，为了保证容器的其他组件不受负面影响，高端的Application Server可能会限制Thread对象的创建。常见的比较经典的Servlet容器实现有Tomcat和Jetty。



# Servlet 3.0

Web应用程序中提供异步处理最基本的动机是处理需要很长时间才能完成的请求。这些比较耗时的请求可能是一个缓慢的数据库查询，可能是对外部REST API的调用，也可能是其他一些耗时的I / O操作。这种耗时较长的请求可能会快速耗尽Servlet容器线程池中的线程并影响应用的可伸缩性。在Servlet3.0规范前，Servlet容器对Servlet都是以每个请求对应一个线程这种1 : 1的模式进行处理的



每当用户发起一个请求时，Tomcat容器就会分配一个线程来运行具体的Servlet。在这种模式下，当在Servlet内执行比较耗时的操作，比如访问了数据库、同步调用了远程rpc，或者进行了比较耗时的计算时，当前分配给Servlet执行任务的线程会一直被该Servlet持有，不能及时释放掉后供其他请求使用，而Tomcat内的容器线程池内线程是有限的，当线程池内线程用尽后就不能再对新来的请求进行及时处理了，所以这大大限制了服务器能提供的并发请求数量。



为了解决上述问题，在Servlet 3.0规范中引入了异步处理请求的能力



 请求被Servlet容器接收，然后从Servlet容器(例如Tomcat)中获取一个线程来执行，请求被流转到Filter链进行处理，然后查找具体的Servlet进行处理。● Servlet具体处理请求参数或者请求内容来决定请求的性质。● Servlet内使用“req.startAsync(); ”开启异步处理，返回异步处理上下文Async-Context对象，然后开启异步线程（可以是Tomcat容器中的其他线程，也可以是业务自己创建的线程）对请求进行具体处理（这可能会发起一个远程rpc调用或者一个数据库请求）；开启异步线程后，当前Servlet就返回了（分配给其执行的容器线程也就释放了），并且不对请求方产生响应结果。● 异步线程对请求处理完毕后，会通过持有的AsyncContext对象把结果写回请求方。



SpringBoot中新增一个Servlet时，如何设置其为异步处理



```java
        //1．标识为Servlet
        @WebServlet(urlPatterns = "/test")
        public class MyServlet extends HttpServlet {
            @Override
            protected void service(HttpServletRequest req, HttpServletResponse resp)
    throws ServletException, IOException {

            System.out.println("---begin servlet----");
            try {
                // 2．执行业务逻辑
                Thread.sleep(3000);

                // 3．设置响应结果
                resp.setContentType("text/html");
                PrintWriter out = resp.getWriter();
                out.println("<html>");
                out.println("<head>");
                out.println("<title>Hello World</title>");
                out.println("</head>");
                out.println("<body>");
                out.println("<h1>welcome this is my servlet1! ! ! </h1>");
                out.println("</body>");
                out.println("</html>");

            } catch (Exception e) {
                System.out.println(e.getLocalizedMessage());
            } finally {
            }
            // 4．运行结束，即将释放容器线程
            System.out.println("---end servlet----");
        }
    }
```

改造为异步处理

```java
        //1．开启异步支持
        @WebServlet(urlPatterns = "/test", asyncSupported = true)
        public class MyServlet extends HttpServlet {
            @Override
            protected void service(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

                // 2．开启异步，获取异步上下文
                System.out.println("---begin serlvet----");
                final AsyncContext asyncContext = req.startAsync();

                // 3．提交异步任务
                asyncContext.start(new Runnable() {

                    @Override
                    public void run() {
                        try {
                            // 3.1执行业务逻辑
                            System.out.println("---async res begin----");
                            Thread.sleep(3000);

                            // 3.2设置响应结果
                            resp.setContentType("text/html");
                            PrintWriter out = asyncContext.getResponse().getWriter();
                            out.println("<html>");
                            out.println("<head>");
                            out.println("<title>Hello World</title>");
                            out.println("</head>");
                            out.println("<body>");
                            out.println("<h1>welcome this is my servlet1! ! ! </h1>");
                            out.println("</body>");
                            out.println("</html>");
                            System.out.println("---async res end----");
        } catch (Exception e) {
            System.out.println(e.getLocalizedMessage());
        } finally {
            // 3.3异步完成通知
            asyncContext.complete();
        }
    }
});

// 4．运行结束，即将释放容器线程
System.out.println("---end servlet----");
}
}
```



