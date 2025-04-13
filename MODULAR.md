#  基于**CocoaPods**依赖管理的IOS模块化实践

## <Project>工程初始化pod

```shell
// 切换到<Project>工程目录，执行pod初始化
cd <Project>
pod init

// 打开编辑Podfile
platform :ios, '13.0'
workspace '<Project>.xcworkspace'
project '<Project>.xcodeproj'

// pod 安装
pod install
```

## 使用**CocoaPods**创建新模块

### 创建DevPods目录，用来存放模块

```shell
mkdir DevPods
```

### 在DevPods目录下创建模块（以FrameNetwork为例）

```shell
cd DevPods
// 选择Platform: iOS; Language: Swift; Include a Demo App: Yes; Test framework and view based testing we can skip
pod lib create FrameNetwork
```

### xcode会自动打开FrameNetwork的Example工程，进行工程配置

* 设置`In Deployment Info`为`iOS 14.0`
* 设置`Swift Language Version`为`Swift 5`
* 关闭工程，避免和后面<Project>工程打开冲突
* 执行一些生成文件清理

```shell
cd DevPods/FrameNetwork/Example
rm -rf Tests
rm Podfile
rm Podfile.lock
rm -rf Pods
rm -rf FrameNetwork.xcworkspace

cd DevPods/FrameNetwork
rm -rf .git
rm .gitignore
rm .travis.yml
rm _Pods.xcodeproj
```

### 打开<Project>.xcworkspace，编辑Podfile

#### 增加<module_name>_pod

```yaml
def frame_network_pod
    pod 'FrameNetwork', :path => 'DevPods/FrameNetwork'
end
```

#### 将<Project> target中嵌套的test targets移动外层

```yaml
target '<Project>' do
    ...
end

target '<Project>Tests' do
    inherit! :search_paths
end
 
target '<Project>UITests' do
end
```

#### 增加模块 Example target

```yaml
target 'FrameNetwork_Example' do
    use_frameworks!
    project 'DevPods/FrameNetwork/Example/FrameNetwork.xcodeproj'

    frame_network_pod
end
```

### 将<Project>主工程中属于新建模块的文件移动到Pods模块中

#### `cd DevPods/FrameNetwork/FrameNetwork`移除`Assets`和`Assets`文件夹，新建`Module`文件夹

```shell
cd DevPods/FrameNetwork/FrameNetwork
rm -rf Assets
rm -rf Classes
mkdir Module
```

#### 移动主项目文件到Pods模块`Module`文件夹下，不要在xcode中拖拽，使用Folder或mv命令移动

```shell
mv <Project>/Frame/Network/Netwok.swift ./DevPods/FrameNetwork/FrameNetwork/Module/
```

#### 编辑FrameNetwork.podspec

```shell
cd DevPods/FrameNetwork

vim FrameNetwork.podspec
// 编辑FrameNetwork.podspec
s.ios.deployment_target = '14.0'
s.source_files = 'FrameNetwork/Module/**/*.{swift}'
s.resources = 'FrameNetwork/Module/**/*.{xcassets,json,storyboard,xib,xcdatamodeld}'
s.resource_bundles = {
  'FrameNetwork' => ['FrameNetwork/Module/**/*.{xcassets,json,storyboard,xib,xcdatamodeld,lproj/*}']
}
s.dependency 'Alamofire', '~> 5.4'
s.dependency 'Moya/Combine', '~> 15.0'

pod install
```

#### 其他模块依赖FrameNetwork

```yaml
target '<Project>' do
		...
    frame_network_pod
end
```

















