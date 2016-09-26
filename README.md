## 简介
用于抓取运行时崩溃日志，展示相关错误信息，项目简单，可快速集成到项目中。

## 使用
可下载 `Demo` 运行 `pod install`以添加 `Masonry`库（或直接把少部分适配的代码注释掉）查看；

必要：
往项目中添加必要类 `FRCrashException.h` 和 `FRCrashException.m` 文件，在每次启动app时添加方法

```
[FRCrashException setCrashExceptionHandler];//设置CrashException回调
```

非必要：页面 `FRDebugViewController` 展示了崩溃日志列表，便于直接查看，可选择性添加。

## 最后
参考链接：

## 协议
被许可在 MIT 协议下使用。