//
//  RTHomeViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit

class RTHomeViewController: RTBaseViewController {

    let kHomeCellID = "RTHomeCollectionViewCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    
    fileprivate func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RTHomeCollectionViewCell.self, forCellWithReuseIdentifier: kHomeCellID)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (kScreenWidth - 20)/3, height: (kScreenWidth - 15)/3)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 5)
    }

}

extension RTHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kHomeCellID, for: indexPath) as! RTHomeCollectionViewCell

        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    
}
