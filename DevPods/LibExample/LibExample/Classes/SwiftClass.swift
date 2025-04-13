import UIKit

public class SwiftClass: NSObject {
    /// Swift method to call in Objc
    @objc public class func callInObjc() {
        print(self, #function)
    }
    /// Swift method calls Swift method
    @objc public class func callObjc() {
        ObjcClass.callInSwift()
    }
}
