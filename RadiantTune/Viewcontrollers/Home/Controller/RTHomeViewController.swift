//
//  RTHomeViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit
import Kingfisher

class RTHomeViewController: RTBaseViewController {

    let kHomeCellID = "RTHomeCollectionViewCell"
    
    @IBOutlet weak var playerWidget: RTPlayerWidgetView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var stations = [Station]()
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerWidget.refreshState(station: nil)
    }
    
    
    fileprivate func setupUI() {
        // collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "RTHomeCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: kHomeCellID)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (kScreenWidth - 20)/3, height: (kScreenWidth - 15)/3)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 5)
        
        // widget View
        playerWidget.delegate = self
        
    }
    
    fileprivate func refreshData() {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        guard let url = URL(string: "https://de1.api.radio-browser.info/json/stations/bycountry/Canada?limit=40") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = session.dataTask(with: request) { data, res, error in
            if let data = data {
                do {
                    self.stations = try JSONDecoder().decode([Station].self, from: data)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
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

//MARK:- CollectionViewDelegate
extension RTHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kHomeCellID, for: indexPath) as! RTHomeCollectionViewCell
        let station = stations[indexPath.row]
        cell.iconImageView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(named: "default_station.jpg"))
        cell.nameLabel.text = station.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let station = stations[indexPath.row]
        pushToPlayingController(station: station)

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
