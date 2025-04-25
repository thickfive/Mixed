## Extension 在 iOS 16 上不显示的原因
- 新建的 Target 并不会跟随主项目设置的系统版本
- 需要在 `Targets - Keyboard - Minimun Deployments` 修改支持最低的系统版本  
⚠️ 没有修改 `Minimun Deployments` 依然能启动调试项目, 并且输出 `Successfully load keyboard extensions`, 什么错误也不给真是离谱

## Extension 文件夹移动后找不到 Info.plist 的问题
在对应 `Target - Build Settings - Info.plist File` 中设置为修改后的路径 `Extensions/Keyboard/Info.plist`


