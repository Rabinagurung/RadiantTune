//
//  RTBaseNavigationViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit

class RTBaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // set navigatonbar background color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    }

}
