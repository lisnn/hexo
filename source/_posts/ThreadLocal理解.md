---
title: ThreadLocal理解
categories:
  - 并发编程
tags:
  - ThreadLocal
date: 2021-04-04 22:18:52
---


## **我理解的ThreadLocal**

ThreadLocal中文名叫线程变量，它底层维护了一个map，key就是当前的ThreadLocal对象（可以理解为当前执行该段代码的线程），value就是你set的值，这个map保证了**各个线程的数据互不干扰**；



```java
//这是ThreadLocal类的set方法源码
    public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            //看这行，精华就在这行
            map.set(this, value);
        else
            createMap(t, value);
    }
    //这是get方法
    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            //精华在这儿，用人话讲就是通过当前线程对象去map里面找对应的entry
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                //entry.value就拿到你set的value啦
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();
    }
```





## **ThreadLocal和Synchonized对比**

Synchonized不用多说，不清楚的请移步 [synchronized底层实现原理](https://blog.csdn.net/qq_33709582/article/details/113572368)而ThreadLocal为解决并发编程提供了新的思路，synchronized是共享线程间的数据，而ThreadLocal是隔离线程间的数据

synchronized是利用锁的机制，使变量或代码块在**某一时该只能被一个线程访问**。而ThreadLocal为每一个线程都提供了变量的副本，使得**每个线程在某一时间访问到的并不是同一个对象**，这样就**隔离**了多个**线程对数据的数据共享**。





## **ThreadLocal使用不当引起的内存泄漏**

ThreadLocal大法虽然好，但是使用不当后果很严重



##### 造成原因：

​	**ThreadLocal没有外部强引用，在发生垃圾回收的时候，ThreadLocal会被当成垃圾给干掉，而ThreadLocal对象又是Map中的key，map的key没了，那对应的entry永远不会被访问到，就无法被回收，进而造成内存泄漏**

##### 解决方案：

- 每次用完ThreadLocal都调用它的remove()方法清除数据
- 将ThreadLocal变量定义成private static，这样就一直存在ThreadLocal的强引用，也就能保证任何时候都能通过ThreadLocal的弱引用访问到Entry的value值，进而被清除



















