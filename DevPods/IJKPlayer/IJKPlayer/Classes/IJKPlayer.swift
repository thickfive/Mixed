
import UIKit
import IJKMediaFramework

public class IJKPlayerViewController: UIViewController {
    
    lazy var player: IJKFFMoviePlayerController! = {
//        let url = Bundle.main.url(forResource: "video-no-faststart", withExtension: "mp4")!
        let url = URL(string: "https://transfer-ali-oss.oss-cn-shenzhen.aliyuncs.com/2024/video-faststart.mp4")
        let options = IJKFFOptions.byDefault()
        let player = IJKFFMoviePlayerController(contentURL: url, with: options)
        player?.view.frame = view.bounds
        return player
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(player.view)
        player.shouldAutoplay = true
        IJKFFMoviePlayerController.setLogReport(true)
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_DEBUG)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.prepareToPlay() // shouldAutoplay + prepareToPlay 代替 player.play, 后者可能数据还准备好会导致播放失败
    }
}
