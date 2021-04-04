---
title: synchronized代码块锁字符串无效问题
categories:
  - 并发编程
tags:
  - synchronize
  - string锁对象
  - 锁无效
date: 2021-04-04 22:18:42
---



## Java synchronized代码块锁字符串无效的问题解决方案

**先上结论：使用str.intern()方法即可保证字符串锁对象有效。**



代码解析

```java
//test测试方法，直接锁住字符串，是没有效果的，
    //因为synchronized(str)相当于重新new String(str)一个字符串作为锁住的参数，
    //每个对象的hashcode不同，所以没有效果。
    public static void test(String str) {
        synchronized(str) {
            System.out.println("进来啦" + str);
            try {
                Thread.sleep(10000);
            } catch (Exception e) {
                e.printStackTrace();
            }
            System.out.println("结束啦" + str);
        }
    }

    //test1测试方法，直接锁住字符串，但是后面加了.intern()。
    //由于使用了intern()方法，当第一条线程发现常量池中没有 str，
    //就往常量池中放了一个str，后面的线程发现常量池中有str，就直接取常量池中的str。
    //str.intern()是把字符串转成常量存储
    public static void test1(String str) {
        synchronized(str.intern()) {
            System.out.println("进来啦" + str);
            try {
                Thread.sleep(10000);
            } catch (Exception e) {
                e.printStackTrace();
            }
            System.out.println("结束啦" + str);
        }
    }

    //test2测试方法，和test测试方法是一样的原理，是没有效果的，
    //因为synchronized(str)相当于重新new String(str)一个字符串作为锁住的参数，
    //每个对象的hashcode不同，所以没有效果。
    public static void test2(int val) {
        synchronized(val + "") {
            System.out.println("进来啦" + val);
            try {
                Thread.sleep(10000);
            } catch (Exception e) {
                e.printStackTrace();
            }
            System.out.println("结束啦" + val);
        }
    }

    public static void main(String[] args) {
        //最后的结论是 test1()的方法才是正确的。
        //不过有个问题要注意，一旦锁住了某个字符串常量，程序其他地方也锁住同样的字符串常量时，
        //其他地方的锁住代码块则需要等待当前这个锁住代码块执行完成后才会执行，因为变成串行了。
        for(int i=0; i<5; i++) {
            int b = i;
            new Thread(() -> {
//                test(b + "");
                test1(b + "");
//                test2(b);
            }).start();
            new Thread(() -> {
//                test(b + "");
                test1(b + "");
//                test2(b);
            }).start();
        }
    }


```

