//
//  ViewController.swift
//  Banner
//
//  Created by Trinity on 2018/5/8.
//  Copyright © 2018年 Trinity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var banner: CCBanner!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        banner.dataSource = self
        banner.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController: CCBannerDelegate {
}

extension ViewController: CCBannerDataSource {
    func numberOfImages(inBanner banner: CCBanner) -> Int {
        return 5
    }
    
    func banner(_ banner: CCBanner, imageAtIndex index: Int) -> CCBannerImage? {
        var images = [#imageLiteral(resourceName: "image1"), #imageLiteral(resourceName: "image2"), #imageLiteral(resourceName: "image3"), #imageLiteral(resourceName: "image4"), #imageLiteral(resourceName: "image5")].map({ CCBannerImage.memory($0)})
        return images[index]
    }
}

