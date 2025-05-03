//
//  Stream.swift
//  Mixed
//
//  Created by vvii on 2024/9/9.
//

import UIKit

extension Stream.Status: @retroactive CustomStringConvertible {

    public var description: String {
        switch self {
        case .notOpen:      return "notOpen"
        case .opening:      return "opening"
        case .open:         return "open"
        case .reading:      return "reading"
        case .writing:      return "writing"
        case .atEnd:        return "atEnd"
        case .closed:       return "closed"
        case .error:        return "error"
        @unknown default:   return "@unknown default"
        }
    }
}

struct Streams {
    let input: InputStream
    let output: OutputStream
}

// https://developer.apple.com/documentation/foundation/url_loading_system/uploading_streams_of_data?changes=_7&language=objc
//
// 2024-09-09T15:23:00.920Z POST /stream {
//   host: '192.168.1.100:8088',
//   'content-type': 'application/x-www-form-urlencoded',
//   'transfer-encoding': 'Chunked',
//   accept: '*/*',
//   'user-agent': 'Mixed/1 CFNetwork/1399 Darwin/22.1.0',
//   'accept-language': 'zh-CN,zh-Hans;q=0.9',
//   'accept-encoding': 'gzip, deflate',
//   connection: 'keep-alive'
// }
//
class StreamViewController: UIViewController {
    
    var canWrite: Bool = false
    
    lazy var session: URLSession = {
        let session = URLSession(configuration: .default,
                                                  delegate: self,
                                                  delegateQueue: .main)
        session.configuration.timeoutIntervalForRequest = 15
        session.configuration.timeoutIntervalForResource = 60
        return session
    }()
    
    var boundStreams: Streams!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // initial
        createBoundStreams()
        createUploadTask()
        createTimer()
        // start
        startUploadTask()
    }
    
    func createUploadTask() {
        let url = URL(string: "http://192.168.1.100:8088/stream")!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 15)
        request.httpMethod = "POST"
        let uploadTask = session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
    }
    
    func createBoundStreams() {
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: 4096,
                               inputStream: &inputOrNil,
                               outputStream: &outputOrNil)
        guard let input = inputOrNil, let output = outputOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
        }
        // configure and open output stream
        output.delegate = self
        output.schedule(in: .current, forMode: .default)
        output.open()
        boundStreams = Streams(input: input, output: output)
    }
    
    func createTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] timer in
            guard let self = self else { return }

            if self.canWrite {
                let message = "*** \(Date())\r\n"
                guard let messageData = message.data(using: .utf8) else { return }
                let messageCount = messageData.count
//                let bytesWritten: Int = messageData.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) in
//                    self.canWrite = false
//                    return self.boundStreams.output.write(buffer, maxLength: messageCount)
//                }
                let bytesWritten: Int = messageData.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                    self.canWrite = false
                    let buffer = buffer.bindMemory(to: UInt8.self).baseAddress!
                    return self.boundStreams.output.write(buffer, maxLength: messageCount)
                }
                if bytesWritten < messageCount {
                    // Handle writing less data than expected.
                    // bytesWritten = min(withBufferSize, messageCount)
                    // 结果是消息会被截断
                }
            }
        }
    }
    
    func startUploadTask() {
        timer.fire()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        boundStreams.output.close() // 结束上传
        timer.invalidate()
    }
}

// 这里必须是子协议 URLSessionTaskDelegate, 而不是 URLSessionDelegate, 否则不生效
extension StreamViewController: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        completionHandler(boundStreams.input)
    }
}

extension StreamViewController: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream == boundStreams.output else {
            return
        }
        if eventCode.contains(.hasSpaceAvailable) {
            canWrite = true
        }
        if eventCode.contains(.errorOccurred) {
            // Close the streams and alert the user that the upload failed.
        }
        Log.debug(aStream.streamStatus)
    }
}

