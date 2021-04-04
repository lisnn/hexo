---
title: java静态内部类的加载时机.md
categories:
  - java基础
tags:
  - 内部类
  - 静态内部类
  - 加载时机
date: 2021-04-04 21:59:16
---


- **外部类初次加载，会初始化静态变量、静态代码块、静态方法，但不会加载内部类和静态内部类。**
- **实例化外部类，调用外部类的静态方法、静态变量，则外部类必须先进行加载，但只加载一次。**
- **直接调用静态内部类时，外部类不会加载。**
- **想要加载非静态内部类，必须先实例化外部类。**
- **类总是在第一次用到时，才会触发加载。**



## **类的变量，方法加载顺序**

**类的初始化顺序如下：**

- 父类静态变量
- 父类静态块
- 子类静态变量
- 子类静态块
- 父类变量
- 父类普通块
- 父类构造函数(子类实例化时先要调用父类构造函数)
- 子类变量
- 子类普通块
- 子类构造函数

## Java 静态内部类的加载时机

### **前言：**

​	在看单例模式的时候，在网上找帖子看见其中有一种（IoDH） 实现单例的方式，其中用到了静态内部类，文章中有写到当jvm加载外部类的时候，并没有加载静态内部内这和之前自己想的不一样，特意在网上找了一些帖子总结一下。

### **一、学习前千的疑问：**

​	稍微了解Java虚拟机内的加载过程的步骤，都很清楚，一个类的静态资源、一些常量都是在类加载的时候就被加载金内存中分配空间了，所以我一开始理所当然的以为静态内部类中的静态变量同样属于静态资源，也应该在在内加载的时候被加载，然而实际情况却不是这样的，带着这个问题我上网找了几篇博客查找原因。

### **二、探究的过程：**

​	在这里我们直接上一段代码，在这里我们分别进行三次测试来：

```java
public class StaticClass {
    public static long OUTER_DATE = System.currentTimeMillis();

    static {
        System.out.println("外部类静态块加载时间：" + System.currentTimeMillis());
    }


    public StaticClass() {
        System.out.println("外部类构造函数时间：" + System.currentTimeMillis());
    }

        // 静态内部类
    static class InnerStaticClass {
        public static long INNER_STATIC_DATE = System.currentTimeMillis();
        static{
            System.out.println("静态内部类静态块加载时间：" + System.currentTimeMillis());
        }
    }

    // 非静态内部类
    class InnerClass {
        public long INNER_DATE = 0;
        public InnerClass() {
            INNER_DATE = System.currentTimeMillis();
        }
    }

    /**
     * 当外部内静态变量被调用
     *
     * 结果：
     * 外部类静态块加载时间：1608605541560
     * 外部类构造函数时间：1608605541560
     * 外部类静态变量加载时间：1608605541560
     * @param args
     */
    public static void main(String[] args) {
        StaticClass outer = new StaticClass();
        System.out.println("外部类静态变量加载时间：" + outer.OUTER_DATE);
    }

    /**
     * 非静态内部类变量调用时
     *
     * 结果：
     * 外部类静态块加载时间：1608605417253
     * 外部类构造函数时间：1608605417254
     * 非静态内部类加载时间1608605417255
     * @param args
     */
//    public static void main(String[] args) {
//        StaticClass outer = new StaticClass();
//        System.out.println("非静态内部类加载时间"+outer.new InnerClass().INNER_DATE);
//    }

    /**
     * 静态内部类中的变量被调用时
     *
     * 结果：
     * 外部类静态块加载时间：1608605511337
     * 静态内部类静态块加载时间：1608605511338
     * 静态内部类加载时间：1608605511338
     * @param args
     */
//    public static void main(String[] args) {
//        System.out.println("静态内部类加载时间："+InnerStaticClass.INNER_STATIC_DATE);
//    }

}
```

#### 1、当外部内静态变量被调用

```java
public static void main(String[] args) {
    StaticClass outer = new StaticClass();
    System.out.println("外部类静态变量加载时间：" + outer.OUTER_DATE);
}
```

打印结果：

```tex
外部类静态块加载时间：1556088212487
外部类构造函数时间：1556088212487
外部类静态变量加载时间：1556088212487
```

从控制台打印的结果我们可以看到：

​	<font color=blue>外部静态变量调用时，外部类进行了加载</font> <font color=red>（注：静态代码块在类被加载时执行）</font> <font color=blue>并且执行了初始化操作</font><font color=red>（注：构造方法被调用）</font>，<font color=blue>而静态内部类并没有被加载</font><font color=red>（注：静态内部类中的静态代码块没有执行）</font>，<font color=blue>且类的加载顺序必定会在初始化的前面，所有看到先执行了静态代码块中的代码，其次执行了构造方法中的代码，完成上面两部后最后才打印出了静态变量</font>



#### 2、非静态内部类变量调用时

```java
public static void main(String[] args) {
        StaticClass outer = new StaticClass();
        System.out.println("非静态内部类加载时间"+outer.new InnerClass().INNER_DATE);
    }
```

打印结果：

```
外部类静态块加载时间：1556088682706
外部类构造函数时间：1556088682706
非静态内部类加载时间1556088682707
```

从控制台打印的结果我们可以看到：

​	<font color=blue>非静态内部类变量被调用时的执行结果和外部静态变量被调用的结果一样，并且静态内部类也没有被加载，出现这种情况也在预料之中，因为非静态内部类的初始化不许依赖于外部类，如果想实例化一个非静态内部类，则必须先实例化外部类，所以我们就看到了上面的结果</font>



#### 3、静态内部类中的变量被调用时

```java
public static void main(String[] args) {
        System.out.println("静态内部类加载时间："+InnerStaticClass.INNER_STATIC_DATE);
    }
```

测试结果：

```
外部类静态块加载时间：1556089480349
静态内部类静态块加载时间：1556089480352
静态内部类加载时间：1556089480352
```

从控制台打印的结果我们可以看到：

​	<font color=blue>静态内部类的变量被调用时，我们可以看出外部类进行了加载 <font color=red>（注：外部类中的静态代码块中的代码执行了）</font> ，但是并没有被初始化 <font color=red>（注：外部类的构造方法并没有执行）</font> ，且静态内部类也完成了加载</font>





### **三、得出结论：**

**有上面我们进行的测试可以得出结论，静态内部类和非静态内部类一样，都不会因为外部类的加载而加载，同时静态内部类的加载不需要依附外部类，在使用时才加载，不过在加载静态内部类的过程中也会加载外部类。**

