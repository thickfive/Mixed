
public class LibExampleModule: NSObject {
    public class func test() {
        LibExampleClass.test()
    }
}

public class LibExampleClass: NSObject {
    class func test() {
        let cls = String(self.description())
        print(#function, #file, cls)
    }
}
