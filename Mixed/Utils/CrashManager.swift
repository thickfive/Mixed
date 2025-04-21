//
//  CrashReport.swift
//  Mixing
//
//  Created by vvii on 2024/9/3.
//

import Foundation

#if canImport(KSCrash)
import KSCrash
#endif

/** CrashManager
 *  在 release 模式下崩溃日志没有 debug 详细, 关键信息缺失, 可能是内联函数优化导致的
 *  用 @inline(never) 修饰可能出问题的函数, 可以输出更多细节
 */
class CrashManager {
    static let shared = CrashManager()
    
#if canImport(KSCrash)
    func setup() {
        // 遇到系统调用显示为 <redacted> 如何处理
        // https://github.com/kstenerud/KSCrash/issues/86#issuecomment-185243609
        // https://github.com/Zuikyo/iOS-System-Symbols
        // 1. Build Settings - Debug Infomation Format - 设置为 DWARF with dSYM File，这样才能在编译产物目录拿到 dSYM 文件。Debug/Release 模式可以根据具体需要分别设置
        // 2. 以 Apple 格式发送崩溃日志
        // 3. 用 dSYM 文件和 Apple 格式崩溃日志手动解析即可
        
        setupCrashInstallation(crashInstallationEmail())
    }
    
    /// 不同的 CrashInstallation 有各自默认的 filters 设置方式，不能随意添加
    /// - Parameter installation: CrashInstallation
    func setupCrashInstallation(_ installation: CrashInstallation) {
        // Optional: Add an alert confirmation (recommended for email installation)
        installation.addConditionalAlert(
            withTitle: "Crash Detected",
            message: "The app crashed last time it was launched. Send a crash report?",
            yesAnswer: "Sure!",
            noAnswer: "No thanks"
        )

        // Install the crash reporting system
        let config = KSCrashConfiguration()
        config.monitors = [.all] //[.machException, .signal]
        do {
            try installation.install(with: config) // set `nil` for default config
            installation.sendAllReports()
        } catch {
            Log.error(error, tag: .crash)
        }
    }
    
    func crashInstallationEmail() -> CrashInstallationEmail {
        let installation = CrashInstallationEmail.shared
        installation.recipients = ["email@xxx.com"]
        installation.setReportStyle(.apple, useDefaultFilenameFormat: true)
        return installation
    }
    
    func crashInstallationStandard() -> CrashInstallationStandard {
        let installation = CrashInstallationStandard.shared
        installation.url = URL(string: "http://192.168.1.100:8088/uploadCrash")!
        // Optional: 以 Apple 格式发送崩溃日志
        let filter = CrashReportFilterAppleFmt.init(reportStyle: AppleReportStyle.symbolicated)
        installation.addPreFilter(filter)
        return installation
    }
#else
    func setup() {
        //
    }
#endif
}

