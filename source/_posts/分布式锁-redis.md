---
title: 分布式锁-redis
categories:
  - 分布式
tags:
  - 分布式锁
  - redis
date: 2021-04-04 22:23:44
---



# 用redis可以作为分布式锁



## 1.创建maven工程

![Image](Image-21.png)



**主要的类，这里主要就是用到了redis的一些原子性操作。**

```java
@Component
public class RedisLock {
    private String lockKey = "lock";
    @Autowired
    private StringRedisTemplate stringRedisTemplate;
    /**
     * 尝试获取锁
     * @param rid
     * @param expireTime
     * @return
     */
    public boolean tryGetLock(String rid, int expireTime){
        while (true){
            if (stringRedisTemplate.boundValueOps(lockKey).setIfAbsent(rid, expireTime, TimeUnit.SECONDS)) {
                return true;
            }
        }
    }
    /**
     * 释放锁
     * @param rid
     * @return
     */
    public boolean releaseLock(String rid){
        // 使用lua脚本 保证原子性
        String script  = "if redis.call('get', KEYS[1]) == ARGV[1] then " +
                "return redis.call('del',  KEYS[1]) " +
                "else return 0 end";
        DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>(script, Long.class);
        Long execute = stringRedisTemplate.execute(redisScript, Collections.singletonList(lockKey), rid);
        return new Long(1).equals(execute);
    }
    public Thread createLifeThread (int time, String rid){
        return new Thread(()->{
            while (true){
                try {
                    //判断是否被中断
                    if(Thread.currentThread().isInterrupted()){
                        //处理中断逻辑
                        break;
                    }


                    TimeUnit.SECONDS.sleep(time*2/3);
                    String script = "if redis.call('get', KEYS[1]) == ARGV[1] then " +
                            "return redis.call('expire', KEYS[1],ARGV[2]) " +
                            "else return 0 end";
                    ArrayList<Object> args = new ArrayList<>();
                    args.add(rid);
                    args.add(time);
                    DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>(script, Long.class);
                    stringRedisTemplate.execute(redisScript, Collections.singletonList(lockKey), args);
                } catch (Exception e) {
                    //判断是否被中断
                    if(Thread.currentThread().isInterrupted()){
                        //处理中断逻辑
                        break;
                    }
                    e.printStackTrace();
                }
            }
        });
    }


}


@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {


    @Override
    @Transactional
    public long updateNum() {
        QueryWrapper<User> w = new QueryWrapper<>();
        User one = getOne(w);
        int number = one.getNumber() + 1;
        User user = new User();
        user.setNumber(number);
        UpdateWrapper<User> wrapper = new UpdateWrapper<>();
        this.update(user, wrapper);
        return number;
    }


}


@RestController
@Slf4j
@RequestMapping("user")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private RedisLock redisLock;

    @RequestMapping(method = RequestMethod.GET, value = "/test")
    public ResponseEntity<HashMap> create() {
        HashMap<Object, Object> map = new HashMap<>();
        long num = 0;
        int time = 10;
        String requestId = UUID.randomUUID().toString().replaceAll("-", "") + (Thread.currentThread().getId());
        // 尝试获取锁
        redisLock.tryGetLock(requestId, time);
        // 启动子线程续命
//        Thread t1 = redisLock.createLifeThread(time, requestId);
        try {
//            t1.setDaemon(true);// 守护线程
//            t1.start();
            map.put("num", userService.updateNum());
            map.put("tid", requestId);
        } finally {
            // 停止续命线程
//            t1.interrupt();
            // 释放锁
            redisLock.releaseLock(requestId);
        }
        return ResponseEntity.status(HttpStatus.OK).body(map);
    }


}



@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@TableName("t_user")
public class User implements Serializable {
    private static final long serialVersionUID = -1840831686851699943L;
    /**
     * 次数
     */
    private int number;
}

```



## 2.数据库表

只有一个字段，int类型

![Image](Image-22.png)



## 3.打包

打包好3份jar，使用不同端口启动 ，分别在8081、8091、8099端口启动项目



## 4.使用nginx来做请求转发

修改nginx配置文件：这里nginx对外访问端口为8989

```
upstream 192.168.1.7{
                server 192.168.1.7:8081 weight=10;
                server 192.168.1.7:8091 weight=10;
                server 192.168.1.7:8099 weight=10;
                }
    server {
        listen       8989;
        server_name  192.168.1.7;


        location / {
            #root   html;
            #index  index.html index.htm;
                proxy_pass http://192.168.1.7;
                proxy_set_header Host 192.168.1.7:8989;
                proxy_set_header X-Real-IP $remote_addr;#保留代理之前的真实客户端ip
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header HTTP_X_FORWARDED_FOR $remote_addr;#在多级代理的情况下，记录每次代理之前的客户端真实ip
                proxy_set_header X-Forwarded-Proto $scheme; #表示客户端真实的协议（http还是https）
        }


        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
```



## 5.使用Jmeter测试

下载并解压好jmeter，运行bin目录下的jmeter.bat，等待启动完成。

创建线程组测试，测试前先把数据库该字段值改为0。设置500个线程，轮询10次，也就是5000次请求，执行完成之后数据库字段值应该是5000。

![Image](Image-24.png)

![Image](Image-25.png)

![Image](Image-26.png)



## 6.观察结果

这里我用jmeter执行了两次，得到数据库字段值结果为10000，正确。

![Image](Image-27.png)





## 7.注意

**这只是一个简单的redis单机版本实现的分布式锁，只是测试使用，不要用于线上，有更牛逼的redission框架使用，这个是官方推荐的开源redis分布式锁实现。**