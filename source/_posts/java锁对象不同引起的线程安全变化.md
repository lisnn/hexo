---
title: java锁对象不同引起的线程安全变化
categories:
  - 并发编程
tags:
  - 锁对象
  - 多线程
  - 线程安全
date: 2021-04-04 22:18:31
---



下面是相关代码：

```java
private Object lockFile=new Object();
private Hashtable<Long ,Integer> lockparam=new Hashtable<>();
   /**
    * 使得同一秒内，只有30个线程（用户）能进行下载操作，其余用户等待下一秒才能有下载资格，如果接下来一秒的线程（用户）数大于30，继续等待下一秒
    * @return
    */
   private boolean limit() {
       synchronized (lockFile) {
           Date time = new Date();
           long s = time.getTime() / 1000;
           int cnt = 0;
           if (lockparam.containsKey(s)) {
               cnt = lockparam.get(s);
           }
           cnt++;
           lockparam.put(s, cnt);
           if (lockparam.size() > 1) {
               List<Long> list = new ArrayList();
               for (Long l : lockparam.keySet()) {
                   if (l < s)
                       list.add(l);
               }
               for (Long l : list) {
                   lockparam.remove(l);
               }
           }
           if (cnt > 30) {
               log.info(Thread.currentThread().getName() + "无法下载");
               return true;
           }
           log.info(Thread.currentThread().getName() + "正在下载");
           return false;
       }
   }
   /**
    * 限流下载
    * @param logid
    */
   public void lock(String logid) {
       while (limit()) {
           try {
               log.info("file:" + logid);
               Thread.sleep(1000);
           } catch (InterruptedException e) {
               e.printStackTrace();
           }
       }
   }

    // 主方法
   public static void main(String[] args) {
        FileController fileController = new FileController();
       for (int i = 0; i < 40; i++) {
           final int id = i;
           new Thread(() -> {
               fileController.lock("123456");
           }, "线程"+id).start();
       }
   }
```



**1.**主方法中开启40个线程，调用lock方法，lock中使用while循环，使用limit方法的返回值进行判断循环是否结束。

在limit方法中，使用了synchronized锁，锁对象是lockFile，因为是同一个fileController对象，所以 lockFile对象也是同一个，线程锁住这个对象时其他线程便无法获取到这个锁进入方法执行，可以实现这个方法线程安全 	<font color=red>（为什么这个方法需要线程安全：虽然线程内使用的是lockparam[hashtable]这个线程安全的对象，但是这个方法内使用了多次put，remove等方法，如果将方法锁住，会造成lockparam数据错乱）</font>。

在这里锁对象可以改成 this ，也可以改成 FileController.class 这两个对象，都可以实现线程安全。



**2.**但是如果将主方法修改

把 FileController fileController = new FileController(); 对象放到for循环内部，会造成每次循环产生的线程调用的对象都不一致，limit方法中锁住的对象也不一致，lockparam（hashtable）对象也不一致，造成线程都可以进入这个limit方法执行，synchronized没有起到作用。

```java
public static void main(String[] args) {
    for (int i = 0; i < 40; i++) {
        FileController fileController = new FileController();
        final int id = i;
        new Thread(() -> {
            fileController.lock("123456");
        }, "线程"+id).start();
    }
}
```



**3.**如果接着上面再将limit方法中的 synchronized锁对象换成 this也是一样的情形。

但是如果锁对象换成 FileController.class 就不一样了，因为 fileController 对象始终是由 FileController.class 产生的，所以即使是多个fileController 调用这个limit方法，synchronized也能锁住这个方法，虽然能锁住这个方法，但是lockparam（hashtable）对象是非静态成员变量，它是从属于 fileController 对象的，因为是多个 fileController 对象，所以这个 lockparam（hashtable）对象也是多个，方法内部执行用到了lockparam（hashtable）判断，而lockparam（hashtable）不是同一个对象，这样还是会造成问题，无法正常运行结束。



**4.**再接着上面的改动，将lockparam(hashtable)改为静态成员变量，情况又将不同

```java
private static Hashtable<Long ,Integer> lockparam=new Hashtable<>();
```

因为<font color=red>lockparam(hashtable)</font>是静态变量了，所以它是从属于<font color=red>FileController类（FileController.class）</font>的，limit方法锁住了 <font color=red>FileController.class 对象</font>，可以保证limit方法的线程安全性，这样虽然有多个<font color=red>fileController 对象</font>调用limit方法，limit方法内部执行用到了<font color=red>lockparam（hashtable）</font>判断，但是<font color=red>lockparam(hashtable)</font>是唯一的，依然可以保证判断不会出问题，这样方法能正常运行结束。

























