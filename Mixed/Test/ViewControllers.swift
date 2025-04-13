//
//  ViewController.swift
//  Mixed
//
//  Created by vvii on 2024/1/27.
//

import UIKit


class ViewController1: UIViewController {
    
    var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        title = "VC-1"
        
        imageView = UIImageView(image: UIImage(named: "image"))
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Router.shared.pushViewController(TranstionViewController())
    }
}

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .green
        title = "VC-2"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Router.shared.present(vc: PresentedViewController(), style: .overTabBarController)
    }
}

class PresentedViewController: UIViewController {

    let btn1 = UIButton()
    let btn2 = UIButton()
    let btn3 = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .purple
        title = "Presented"
        
        btn1.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        btn1.backgroundColor = .systemBlue
        btn1.addTarget(self, action: #selector(click1), for: .touchUpInside)
        view.addSubview(btn1)
        
        btn2.frame = CGRect(x: 100, y: 300, width: 100, height: 100)
        btn2.backgroundColor = .systemCyan
        btn2.addTarget(self, action: #selector(click2), for: .touchUpInside)
        view.addSubview(btn2)
        
        btn3.frame = CGRect(x: 100, y: 500, width: 100, height: 100)
        btn3.backgroundColor = .systemYellow
        btn3.addTarget(self, action: #selector(click3), for: .touchUpInside)
        view.addSubview(btn3)
    }
    
    @objc func click1() {
        Router.shared.pushViewController(PresentedViewController())
    }
    
    @objc func click2() {
        Router.shared.present(vc: PresentedViewController(), style: .overCurrentContext(self))
    }
    
    @objc func click3() {
        Router.shared.popToRootViewController()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
}

class Presented2: UIViewController {
    
    let btn1 = UIButton()
    let btn2 = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .cyan
        title = "Presented2"
        
        btn1.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        btn1.backgroundColor = .systemBlue
        btn1.addTarget(self, action: #selector(click1), for: .touchUpInside)
        view.addSubview(btn1)
        
        btn2.frame = CGRect(x: 100, y: 300, width: 100, height: 100)
        btn2.backgroundColor = .systemCyan
        btn2.addTarget(self, action: #selector(click2), for: .touchUpInside)
        view.addSubview(btn2)
    }
    
    @objc func click1() {
        dismiss(animated: true)
    }
    
    @objc func click2() {
        Router.shared.pushViewController(PushedViewController())
    }
}

class PushedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .blue
        title = "Pushed"
    }
}


