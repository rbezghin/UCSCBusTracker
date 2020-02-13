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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let busImage = createImage(named: "bus_icon")
        let scheduleImage = createImage(named: "schedule_icon")
        let menuImage = createImage(named: "menu_icon")
        
        mapViewController.tabBarItem = UITabBarItem(title: "Map", image: busImage, tag: 0)
        scheduleViewController.tabBarItem = UITabBarItem(title: "Schedule", image: scheduleImage, tag: 1)
        someotherViewController.tabBarItem = UITabBarItem(title: "More", image: menuImage, tag: 3)
        viewControllers = [mapViewController, scheduleViewController, someotherViewController]
    }
    
    func createImage(named: String) -> UIImage? {
        guard  let image = UIImage(named: named) else {return nil}
        //resizing image
        var size = CGSize()
        if(named == "schedule_icon"){
            size = CGSize(width: 30, height: 30)
        }else{
            size = CGSize(width: 20, height: 20)
        }
        
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
             image.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }
    



}
