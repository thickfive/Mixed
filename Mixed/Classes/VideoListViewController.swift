//
//  VideoListViewController.swift
//  Mixed
//
//  Created by vvii on 2025/4/11.
//

import UIKit

class VideoListViewController: UIViewController {
    
    private let dataSource: [VideoPlayerController.Type] = [
        VideoPlayerController1.self,
        VideoPlayerController2.self,
        VideoPlayerController3.self,
        VideoPlayerController4.self,
    ]
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .black.withAlphaComponent(0.5)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        VideoPlayer.shared.play(in: self.view)
    }
}

extension VideoListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "VideoListCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoListCell", for: indexPath)
        cell.layer.contents = UIImage(named: "video2")?.cgImage
        cell.contentMode = .scaleAspectFill
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = dataSource[indexPath.item].init()
        vc.sourceView = collectionView.cellForItem(at: indexPath)
        Router.shared.navigationController.delegate = vc
        Router.shared.pushViewController(vc, animated: true)
    }
}
