Create Date: 2021-04-02
Update Date：2022-09-09

## 获取 X天前的日期

``` zsh
# 提前90天前的日期
➜  date -d "90 days ago" +%Y%m%d
20220611
```

## 获取 X天前的时间戳

``` zsh
➜  date -d "90 days ago" +%s
1654930270
```

## 日期转换为时间戳

``` zsh
➜  expire_date="Aug 31 12:00:00 2021 GMT"

# 转换为时间戳
➜  expire_stamp=$(date -d "$expire_date" +%s)
1630411200
```

## 时间戳转化为日期

``` zsh
# 提前10天提醒 的时间戳
➜  alert_stamp=$(($expire_stamp - 10*86400))

# 转换为日期
➜  date -d @$alert_stamp +%Y-%m-%d
2021-08-21
```
