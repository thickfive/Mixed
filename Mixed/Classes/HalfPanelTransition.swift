//
//  HalfPanelTransition.swift
//  Mixed
//
//  Created by vvii on 2024/7/22.
//

import UIKit

// ScrollView 半弹窗效果
// ❌ 不要监听代理 scrollViewDidScroll, 在代理里面修改位置导致递归调用, 位置跳动不连续
// ✅ 监听其自带的 PanGestureRecognizer 相对于屏幕的位置, 修改 ScrollView.contentOffset 和 frame.y 即可
class HalfPanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HalfPanelProtocol {
    
    weak var delegate: HalfPanelViewDelegate?
    
    lazy var tableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .blue.withAlphaComponent(0.8)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.clipsToBounds = true
        return tableView
    }()
    
    lazy var textField = UITextField()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red.withAlphaComponent(0.2)
        tableView.frame = CGRect(x: 0, y: sh - PresentationHeight, width: sw, height: PresentationHeight)
        view.addSubview(tableView)
        tableView.panGestureRecognizer.addTarget(self, action: #selector(_handlePan(_:)))
        let curve = CubicBezierCurve(
            p0: CGPoint(x: 0, y: 0),
            p1: CGPoint(x: 0.0, y: 0.0),
            p2: CGPoint(x: 1.0, y: 1.0),
            p3: CGPoint(x: 1, y: 1)
        )
        delegate?.onHalfPanelViewOriginChanged(y: sh - PresentationHeight, animationDuration: 0.50, curve: curve)
        
        textField.center = view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("CACurrentMediaTime", CACurrentMediaTime())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("CACurrentMediaTime", CACurrentMediaTime())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("CACurrentMediaTime", CACurrentMediaTime())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("CACurrentMediaTime", CACurrentMediaTime())
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.configurationUpdateHandler = { (cell, state) in
            cell.textLabel?.text = "Item - \(indexPath.item)"
        }
        cell.backgroundColor = .random.withAlphaComponent(0.5)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Router.shared.pushViewController(EmptyViewController())
    }
    
    // MARK: - HalfPannelProtocol
    var startY: CGFloat!
    
    var originY: CGFloat {
        return sh - PresentationHeight
    }
    
    var scrollView: UIScrollView {
        return tableView
    }
    
    var containerView: UIView {
        return self.tableView
    }
    
    @objc func _handlePan(_ ges: UIPanGestureRecognizer) {
        handlePan(ges)
    }
}

protocol HalfPanelViewDelegate: NSObjectProtocol {
    func onHalfPanelViewOriginChanged(y: CGFloat, animationDuration: Double, curve: CubicBezierCurve)
}

protocol HalfPanelProtocol: NSObjectProtocol {
    var delegate: HalfPanelViewDelegate? { get set }
    var scrollView: UIScrollView { get }
    var containerView: UIView { get }
    var startY: CGFloat! { get set }
    var originY: CGFloat { get }
    func handlePan(_ ges: UIPanGestureRecognizer)
}

// pan
extension HalfPanelProtocol where Self: UIViewController {
    
    func handlePan(_ ges: UIPanGestureRecognizer) {
        let currY = ges.location(in: view).y
        switch ges.state {
        case .changed:
            if scrollView.contentOffset.y < 0 {
                if startY == nil {
                    startY = currY // 记录第一次整体移动的位置
                }
                scrollView.contentOffset.y = 0   // 1. 整体下移
                containerView.frame.origin.y = originY + max(currY - startY, 0) // 1. 整体下移
                delegate?.onHalfPanelViewOriginChanged(y: containerView.frame.origin.y, animationDuration: 0, curve: .linear)
            } else {
                if containerView.frame.origin.y > originY {
                    scrollView.contentOffset.y = 0 // 2. 整体上移
                    containerView.frame.origin.y = originY + max(currY - startY, 0) // 2. 整体上移
                    delegate?.onHalfPanelViewOriginChanged(y: containerView.frame.origin.y, animationDuration: 0, curve: .linear)
                } else {
                    // 正常滚动
                }
            }
        case .cancelled, .ended:
            let isCancel = containerView.frame.origin.y == originY || containerView.frame.origin.y + ges.velocity(in: view).y * 0.2 < originY + 300
            if isCancel {
                let this = self
                UIView.animate(withDuration: 0.2) {
                    this.containerView.frame.origin.y = this.originY // 3. 取消/完成动画
                    this.delegate?.onHalfPanelViewOriginChanged(y: this.originY, animationDuration: 0.2, curve: .easeInOut)
                } completion: { _ in
                    
                }
            } else {
                delegate?.onHalfPanelViewOriginChanged(y: sh, animationDuration: 0.05, curve: .easeInOut)
                self.dismiss(animated: true)
            }
        default:
            startY = nil
        }
    }
}

