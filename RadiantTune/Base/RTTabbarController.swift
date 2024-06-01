//
//  RTTabbarController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit

class RTTabbarController: UITabBarController {
    

    var vcArray = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize controller from storyboard
        let homeVC = UIStoryboard(name: "RTHomeViewController", bundle: nil).instantiateInitialViewController()!
        let favoriteVC = UIStoryboard(name: "RTFavoriteViewController", bundle: nil).instantiateInitialViewController()!
        let settingVC = UIStoryboard(name: "RTSettingViewController", bundle: nil).instantiateInitialViewController()!
        
        // set item config
        addChild(homeVC, title: "Home", normalImage: "live-n", selectedImage: "live-p")
        addChild(favoriteVC, title: "Favorite", normalImage: "found-n", selectedImage: "found-p")
        addChild(settingVC, title: "Setting", normalImage: "mine-n", selectedImage: "mine-p")
        viewControllers = vcArray
        
        // tabbar config
        if #available(iOS 15.0, *) {
            // for iOS15
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        if #available(iOS 13.0, *) {
            // for iOS13
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor.red
            UITabBar.appearance().standardAppearance = tabBarAppearance
        }
    }
    
}

//MARK:- private M
extension RTTabbarController {
    func addChild(_ childController: UIViewController, title: String, normalColor: UIColor = .black, selectedColor: UIColor = .red, normalImage: String, selectedImage: String, hasNavigationbar: Bool = true) {
        let item = UITabBarItem(title: title, image: UIImage(named: normalImage)?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: selectedImage)?.withRenderingMode(.alwaysOriginal))
        childController.title = title
        childController.tabBarItem = item
        if hasNavigationbar {
            // has navigation bar
            let navigationVC = RTBaseNavigationViewController(rootViewController: childController)
            vcArray.append(navigationVC)
        } else {
            // no navigation bar
            vcArray.append(childController)
        }
    }
}
