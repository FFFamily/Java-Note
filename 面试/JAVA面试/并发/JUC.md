# JUC

## Queue

### ArrayBlockingQueue

基于数组实现，保证并发的安全性是基于 ReetrantLock 和 Condition 实现的。其中有两个重要的成员变量putindex 和 takeindex,这两个需要搞懂，putindex 就是指向数组中上一个添加完元素的位置的下一个地方，比如刚在 index=1 的位置添加完，那么 putindex 就是 2，其中有一点特别注意的就是当index=数组的长度减一的时候，意味着数组已经到了满了，那么需要将 putindex 置位0，原因是数组在被消费的也就是取出操作的时候，是从数组的开始位置取得，所以最开始的位置容易是空的，所以把要添加的位置置位 0；takeindex 也是一样的，当 takeindex 到了数组的长度减一的时候，也需要将 takeindex 置为 0。

add offer put
add 调用了 offer 方法 add 方法数组满了则抛出异常
offer 方法：用 ReetracLock 加锁，首先判断数组是否满了，数组满了则返回 false，数组不满的话直接入队，也就是将 putindex 索引处的值置为新要加入的数，如果加入以后发现 putindex++ =数组的长度，那么说明后面的全部已经填满了，因此 putindex 置为 0，因为前面的可能出队的过程空出来了， 所以变为 0，最后一步就是执行 notEmpty.signal 去唤醒消费的执行了 take 的线程，只有可能是执行了 take 的方法的线程，因为执行了其它方法 remove,poll 不会产生线程的挂起操作。

put:首先是 ReetrantLock 加锁，然后判断是否满了，队列满了，则执行 notFull.await()操作挂起，等待 notFull.signal(）唤醒。没满，则直接进行入队，入队和 offer 操作一样，也就是将 putindex索引处的值置为新要加入的数，如果加入以后发现 putindex++ = 数组的长度，那么说明后面的全部已经填满了，因此 putindex 置为 0，因为前面的可能出队的过程空出来了，所以变为 0，最后一步就是执行 notEmpty()去唤醒消费的执行了 take 的线程

remove,poll,take

poll 首先加锁 ReetranLock ,然后判断队列是否为空，不为空，则将 putindex 出的值用副本 copy,然后置位 null,然后去执行唤醒 notFull()操作，也就是唤醒调用了 put 操作的线程，唤醒操作并不一定总是发生。
take 操作，先加锁，然后如果队列空则 notEmpty.await()方法，不为空，则执行和poll 一样的出队
操作：则将 putindex 出的值用副本 copy,然后置位 null,然后去执行唤醒 notFull()操作



### LinkedBlockingQueue

基于链表实现，有 takelock 和 putlock，也就是说可以同时在首尾两端进行操作，因此吞吐量比ArrayBlockingQueue 大，同时由于首尾两端都可以进行操作，所以当在进行添加的操作的过程可以一直去添加，直到没有被阻塞的添加线程为止，然后才去执行消费的线程。

1.add,offer,put
add 调用 offer,满了抛出异常offer 方法 putlock 锁，然后不满则加入，同时获取一个 c 值，c 值代表本次队列增加前的队列的数目（一开始长度 2，增加 1，现在长度是 3，那么 c 就是 2），然后判断如果不满则继续去唤醒notFull.signl，去唤醒添加线程去添加（添加过程是直接 last 节点指向下一个，简单的节点后增加一个节点，然后 last 指向最后一个节点），上述过程结束，然后去判断 c==0(c 代表了之前的队列长度，如果添加之前队列长度是 0 那么说明可能有挂起的消费线程，需要从队列取元素，但队列长度为 0 没有元素；判断c>0 没有意义，因为添加之前队列不为空，说明不存在挂起的消费线程，挂起的原因是因为队列为空， 所以不存在因此源码是判断 c==0） ，c 如果等于 0 那么去唤醒阻塞的notEmpty 上的条件等待线程。put 操作就是满了则挂起，不满则执行，同时添加完一个后，发现没满继续去唤醒挂起的添加线程

2.poll take反之，一样的逻辑poll 则获取 takelcok 然后不为空则出队一个元素，也就是链表的删除头结点操作，通过是如果队列不为空，那么继续去唤醒被挂起的消费线程（消费线程就是执行了队列的 take 操作的线程），直到没有消费线程或者队列为空，结束，然后如果 c（也是队列消费一个头节点的元素后，没消费之前的长度，没发生删除的时候队列的长度），如果 c 的长度已经是队列的长度，则去唤醒被挂起的执行了put 方法的线程，然后释放 takelock 锁take 方法一样的道理，为空则挂起，不为空一直消费，唤起消费线程一直消费，直到条件不满足，那么去尝试判断 c 的值，c 是队列长度减一，那么去唤醒执行了 put 方法的被挂起的线程。





### 两者迥异

通过上述的分析，对于 LinkedBlockingQueue 和 ArrayBlockingQueue 的基本使用以及内部实现

原理我们已较为熟悉了，这里我们就对它们两间的区别来个小结队列大小有所不同，ArrayBlockingQueue 是有界的初始化必须指定大小，而LinkedBlockingQueu e 可以是有界的也可以是无界的(Integer.MAX_VALUE)，对于后者而言，当添加速度大于移除速度时， 在无界的情况
下，可能会造成内存溢出等问题。数据存储容器不同，ArrayBlockingQueue 采用的是数组作为数据存储容器，而LinkedBlockingQueue 采用的则是以 Node 节作为连接对象的链表。由于ArrayBlockingQueue 采用的是数组的存储容器，因此在插入或删除元素时不会产生或销毁任何额外的对象实例，而 LinkedBlockingQueue 则会生成一个额外的 Node 对象。这可能在长时间内需要高效并发地处理大批量数据的时，对于 GC 可能存在较大影响。两者的实现队添加或移除的锁不一样，ArrayBlockingQueue 实现的队列中的锁是没有分离的，即添加操作和移除操作采用的同一个 ReenterLock 锁，而 LinkedBlockingQueue 实现的队列中的锁是分离的，其添加采用的是 putLock，移除采用的则是 takeLock，这样能大大提高队列的吞吐量，也意味着在高并发的情况下生产者和消费者可以并行地操作队列中的数据，以此来提高整个队列的并发性能。