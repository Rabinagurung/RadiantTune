//
//  RTHomeViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit

class RTHomeViewController: RTBaseViewController {

    let kHomeCellID = "RTHomeCollectionViewCell"
    
    @IBOutlet weak var playerWidget: RTPlayerWidgetView!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    fileprivate func setupUI() {
        // collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RTHomeCollectionViewCell.self, forCellWithReuseIdentifier: kHomeCellID)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (kScreenWidth - 20)/3, height: (kScreenWidth - 15)/3)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 60, left: 5, bottom: 0, right: 5)
        
        // widget View
        playerWidget.delegate = self
        
    }

}

//MARK:- CollectionViewDelegate
extension RTHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kHomeCellID, for: indexPath) as! RTHomeCollectionViewCell

        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        guard let url = URL(string: "https://de1.api.radio-browser.info/json/stations/bycountry/Canada?limit=40") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = session.dataTask(with: request) { data, res, error in
            if let data = data {
                do {
                    let stations = try JSONDecoder().decode([Station].self, from: data)
                    let station = stations[indexPath.row]
                    DispatchQueue.main.async {
                        self.pushToPlayingController(station: station)
                    }
                } catch {
                    
                }

            }
            
            if let error = error {
                print(error)
            }
        }
        
        task.resume()
    }
    
    
}

//MARK:- RTPlayingViewControllerDelegate
extension RTHomeViewController: RTPlayingViewControllerDelegate {
    func controllerDidClosed(station: Station?) {
        playerWidget.station = station
        playerWidget.refreshState(station: station)
    }
}

//MARK:- RTPlayerWidgetViewDelegate
extension RTHomeViewController: RTPlayerWidgetViewDelegate {
    func clickIconImageView(station: Station?) {
        guard let station = station else { return }
        pushToPlayingController(station: station)
    }
}

//MARK:- private M
extension RTHomeViewController {
    fileprivate func pushToPlayingController(station: Station) {
        let playingVC = UIStoryboard.init(name: "RTPlayingViewController", bundle: nil).instantiateInitialViewController() as! RTPlayingViewController
        playingVC.station = station
        playingVC.delegate = self
        playingVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(playingVC, animated: true)
    }
}
