//
//  TabBarController.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 2/1/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let mapViewController = MapVC()
    private let scheduleViewController = ScheduleVC()
    private let someotherViewController = ScheduleVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = createImage()
        
        mapViewController.tabBarItem = UITabBarItem(title: "Map", image: image, tag: 0)
        scheduleViewController.tabBarItem = UITabBarItem(title: "Schedule", image: image, tag: 1)
        someotherViewController.tabBarItem = UITabBarItem(title: "More", image: image, tag: 3)
        viewControllers = [mapViewController, scheduleViewController, someotherViewController]
    }
    
    func createImage() -> UIImage? {
        guard  let image = UIImage(named: "bus_icon") else {return nil}
        //resizing image
        let size = CGSize(width: 20, height: 20)
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
             image.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }
    



}
