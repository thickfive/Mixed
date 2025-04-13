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
    
    func setup() {
#if canImport(KSCrash)
        let installation = CrashInstallationStandard.shared
        installation.url = URL(string: "http://192.168.1.100:8088/uploadCrash")!
        
        // Optional: Add an alert confirmation (recommended for email installation)
        installation.addConditionalAlert(
            withTitle: "Crash Detected",
            message: "The app crashed last time it was launched. Send a crash report?",
            yesAnswer: "Sure!",
            noAnswer: "No thanks"
        )
        
        // Optional: 以 Apple 崩溃日志格式发送
//        let filter = CrashReportFilterAppleFmt.init(reportStyle: AppleReportStyle.symbolicated)
//        installation.addPreFilter(filter)
        
        // Install the crash reporting system
        let config = KSCrashConfiguration()
        config.monitors = [.all] //[.machException, .signal]
        do {
            try installation.install(with: config) // set `nil` for default config
            installation.sendAllReports()
        } catch {
            Log.error(error, tag: .crash)
        }
#endif
    }
}

