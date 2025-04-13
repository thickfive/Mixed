## 文件目录修改
在 TARGETS - ${PROJECT} - Build Settings 中修改下列文件目录
1. `Info.plist`
2. `${PROJECT}-Bridging-Header` 

## Podfile 修改
```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

## pod lib create LibExample 模版文件用户名与邮箱的来源
```
# security find-internet-password -s github.com | grep acct | sed 's/"acct"<blob>="//g' | sed 's/"//g'
# 这条命令会优先从 KeyChain 中寻找, 优先级高于 git config user.name, 因此想要修改用户名, 需要先修改 KeyChain 存在的用户名
#module Pod
#  class TemplateConfigurator
#    ...
#    #----------------------------------------#
#    def user_name
#      (ENV['GIT_COMMITTER_NAME'] || github_user_name || `git config user.name` || `<GITHUB_USERNAME>` ).strip
#    end
#    
#    def github_user_name
#      github_user_name = `security find-internet-password -s github.com | grep acct | sed 's/"acct"<blob>="//g' | sed 's/"//g'`.strip
#      is_valid = github_user_name.empty? or github_user_name.include? '@'
#      return is_valid ? nil : github_user_name
#    end
#    
#    def user_email
#      (ENV['GIT_COMMITTER_EMAIL'] || `git config user.email`).strip
#    end
#    #----------------------------------------#
#    ...
#  end
#end
```

## pod install 动态库包含静态库的问题
[!] The 'Pods-Mixed' target has transitive dependencies that include statically linked binaries: (/Users/vvii/Desktop/Project/Mixed/DevPods/IJKPlayerFramework/IJKMediaFramework.framework)
问题原因: 多个动态库依赖同一个静态库, 就会导致符号重复, 所以动态库不允许依赖静态库
解决方式1: Podfile 注释掉 use_frameworks! # use_frameworks!
解决方式2: Podfile 修改为 use_frameworks! :linkage => :static [iOS 动态库与静态库基础](https://www.jianshu.com/p/ca94f79c18c8)
解决方式3: use_frameworks! 不变, 同时依赖静态库的 pod 都设置为 s.static_framework = true, 这样就能不分打包为静态库, 其他的还是动态库
编译: 静态库编译后, 不论 use_frameworks! 与否, 体积都会缩减, 因为实际上并没有用到所有函数
打包: 动态库最终以文件的形式直接拷贝进应用程序的 Frameworks 目录中, 静态库直接编译链接进了可执行文件
体积对比: 可执行文件 + 动态库 >≈ 可执行文件(包含静态库), 两者差别不大, 动态库比静态库稍微大一点

## 编译失败问题
'Build Settings' -> 'ENABLE_USER_SCRIPT_SANDBOXING' = NO
[Solved this on my project. In Build Settings, make sure ENABLE_USER_SCRIPT_SANDBOXING is set to NO.](https://github.com/CocoaPods/CocoaPods/issues/12073#issuecomment-1737821281)

## Symbolic Breakpoint 获取返回值
参数名可以用 $arg1 (self), $arg2 (cmd), $arg3 (第一个参数) ... 代替
Condition: BOOL($arg3 != nil)

### 1.打印汇编寄存器返回值
``` swift
断点进入方法内部: [_UINavigationParallaxTransition transitionDuration:]  
> si (重复多次或者直接断点到函数返回 ret 之前)  
> register read/f d0
// 输出: d0 = 0.34999999999999998
```

### 2.强制方法调用
``` swift
断点进入方法内部: [UIViewControllerBuiltinTransitionViewAnimator transitionDuration:]  
强制转换参数类型: (UIViewControllerBuiltinTransitionViewAnimator *)$arg1, (_UIViewControllerTransitionContext *)$arg3  
通过 @exp@ = expression 执行后输出返回值 

Action - Log Message: 😄 %B @[(UIViewControllerBuiltinTransitionViewAnimator *)$arg1 transitionDuration:(_UIViewControllerTransitionContext *)$arg3]@
// 输出: 😄 [UIViewControllerBuiltinTransitionViewAnimator transitionDuration:] 0.40000000000000002

如果不清楚参数的类型, 可以通过同样的方法拿到: @[(NSObject *)$arg1 class]@
```
## XCode修改工程名(完美版)
https://www.cnblogs.com/grimm/p/14831481.html

## 列出所有历史大文件
```
git rev-list --objects --all |
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
  awk '/^blob/ {printf "%s %s\n", $3, $4}' |
  sort -n -k1 |
  tail -n 20
```

## git clone 忽略 LFS
https://stackoverflow.com/questions/42019529/how-to-clone-pull-a-git-repository-ignoring-lfs
```
Configuring the git-lfs smudge:

git config --global filter.lfs.smudge "git-lfs smudge --skip -- %f"
git config --global filter.lfs.process "git-lfs filter-process --skip"    
git clone SERVER-REPOSITORY

To undo this configuration, execute:

git config --global filter.lfs.smudge "git-lfs smudge -- %f"
git config --global filter.lfs.process "git-lfs filter-process"
```
