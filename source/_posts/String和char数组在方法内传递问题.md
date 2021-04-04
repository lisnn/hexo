---
title: String和char数组在方法内传递问题
categories:
  - java基础
tags:
  - char
  - string
  - 方法传递
date: 2021-04-04 21:59:55
---


### 结论

- **java字符串在方法中传递不会改变原值，只在方法内生效。**
- **char[]传递的是数组对象，方法内如果修改，那么修改的就是对象本身。**
- **char，int等在方法内传递是值传递，不会改变原值，只在方法内生效。**
- **Integer，Long等包装类（被final修饰）在方法内传递是值传递，不会改变原值，只在方法内生效。**





### 上代码

```java
@Data
@AllArgsConstructor
class Person{
    private String name;
}
/**
* 字符串和char[]在方法上的传递问题   字符串和char数组在方法上的传递问题
* 字符串传递的是复制过去的一份副本（方法内修改就在方法内生效，方法外部就无效果），char数组传递的是复制的一个自身引用过去。
首先要知道，数组类型也是一个对象，参数ch 是 成员变量ch 的拷贝也就是说 参数ch 也是一个对象的引用，也就是说 参数ch 和 成员变量ch 指向的是同一个数组对象。
*/
class TestQ {
    String str = new String("hello");
    char[] ch = {'a','b','c'};


    public void fun(String str, char ch[]){
        str = "world";
        ch[0] = 'd';
    }
    public void fun1(Person p){
        p.setName("lisi");
    }


    public static void main(String[] args) {
        TestQ qqq = new TestQ();
        qqq.fun(qqq.str, qqq.ch);
        System.out.println(qqq.str + " and " );
        System.out.println(qqq.ch);


        Person person = new Person("zhangsan");
        qqq.fun(person.getName(), qqq.ch);
        System.out.println(person.getName());


        qqq.fun1(person);
        System.out.println(person.getName());
    }
}
```

### 输出内容

```
hello and
dbc
zhangsan
lisi
```

### 分析

- 字符串在方法调用中传递， 字符串 是没有改变原来的值， 只不过是重新复制了一份字符串过去；
- char数组是数组对象，传递过去的是对象引用地址，方法内部改了，char数组就改变了；
- Person对象传递过去也是传递的对象，改的也是对象本身；
- qqq.fun(person.getName(), qqq.ch)这里只是传递字符串，而字符串是Person的name，和第一种情况一样的。