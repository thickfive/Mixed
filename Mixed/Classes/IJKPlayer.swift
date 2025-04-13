//
//  IJKPlayer.swift
//  Mixed
//
//  Created by vvii on 2024/8/27.
//

#if canImport(IJKPlayer)
import IJKPlayer
let IJKPlayerViewControllerClass = IJKPlayerViewController.self

extension IJKPlayerViewController: AutorotateProtocol {
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeRight, .portrait]
    }
}
#else
let IJKPlayerViewControllerClass = CannotImportViewController.self
#endif

#if canImport(IJKMediaFramework)
// 本地编译 default 配置 IJKMediaFramework, 303.7 MB (arm64, x86_64), 应用程序 58.6M
// Cocoapods IJKMediaFramework, 197.2 MB (i386 armv7 x86_64 arm64), 应用程序 49M
// 应用程序的大小与静态库有关, 但不是简单的完全复制进去
// 如果 pod 没有 IJKMediaFramework, 这里需要注释掉, 它会从本地路径搜索, 导致编译缺少相关依赖报错
//import IJKMediaFramework
//func test_IJKMediaFramework() {
//    let _ = IJKFFMoviePlayerController(contentURL: nil, with: IJKFFOptions.byDefault())
//}
#endif
