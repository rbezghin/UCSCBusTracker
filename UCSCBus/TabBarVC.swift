//
//  TabBarController.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 2/1/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {
    
    private let mapViewController = MapVC()
    private let scheduleViewController = ScheduleVC()
    private let someotherViewController = ScheduleVC()
    private let busIconImage: UIImage = {
        let image = UIImage(named: "bus_icon")
        let size = CGSize(width: 20, height: 20)
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
            image?.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewController.tabBarItem = UITabBarItem(title: "Map", image: busIconImage, tag: 0)
        scheduleViewController.tabBarItem = UITabBarItem(title: "Schedule", image: busIconImage, tag: 1)
        someotherViewController.tabBarItem = UITabBarItem(title: "More", image: busIconImage, tag: 3)
        viewControllers = [mapViewController, scheduleViewController, someotherViewController]
    }
}
