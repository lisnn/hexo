---
title: String比较
categories:
  - java基础
tags:
  - string
  - equal
date: 2021-04-04 21:59:46
---

# 字符串的==比较

```java
String s1 = new String("zs");
String s2 = new String("zs");
System.out.println(s1 == s2); // false
String s3 = "zs";
String s4 = "zs";
System.out.println(s3 == s4); //  true
System.out.println(s3 == s1); // false
String s5 = "zszs";
String s55 = "zs" + "zs";
String s6 = s3+s4;   // 这里相当于 String s6 = new String(s3+s4); 使用了新的地址
System.out.println(s5 == s6); // false
System.out.println(s5 == s6.intern());// true，调用了intern()方法，相当于将这个字符串放进了常量池
System.out.println(s5 == s55);// true

final String s7 = "zs";    // 加上final，这个字符串就是常亮
final String s8 = "zs";
String s9 = s7+s8;    // 这里相当于 String s9 = "zs"+"zs";
System.out.println(s5 == s9); // true
final String s10 = s3+s4;    // 相当于 final String s10 = new String(s3+s4);
System.out.println(s5 == s10); // false
```

