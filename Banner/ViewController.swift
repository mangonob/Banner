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
        var images = [#imageLiteral(resourceName: "image1"), #imageLiteral(resourceName: "image2"), #imageLiteral(resourceName: "image3"), #imageLiteral(resourceName: "image4"), #imageLiteral(resourceName: "image5")].map({ CCBannerImage.memory($0)})
        images.append(.network(URL(string: "https://www.baidu.com/img/bd_logo1.png")!))
        images.insert(.network(URL(string: "https://www.baidu.com/img/bd_logo1.png")!), at: 0)
        banner.images = images
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController: CCBannerDelegate {
    func banner(_ banner: CCBanner, insetOfImageAtIndex index: Int) -> UIEdgeInsets {
        let margin = CGFloat((index + 1) * 10)
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    func banner(_ banner: CCBanner, contentModeAtIndex index: Int) -> UIViewContentMode {
        return UIViewContentMode.scaleAspectFit
    }
    
    func banner(_ banner: CCBanner, drawableAtIndex index: Int) -> CCDrawable? {
        return Drawable(index)
    }
}

extension ViewController: CCBannerDataSource {
    func numberOfImages(inBanner banner: CCBanner) -> Int {
        return 7
    }
    
    func banner(_ banner: CCBanner, imageAtIndex index: Int) -> CCBannerImage? {
        var images = [#imageLiteral(resourceName: "image1"), #imageLiteral(resourceName: "image2"), #imageLiteral(resourceName: "image3"), #imageLiteral(resourceName: "image4"), #imageLiteral(resourceName: "image5")].map({ CCBannerImage.memory($0)})
        images.append(.network(URL(string: "https://www.baidu.com/img/bd_logo1.png")!))
        images.insert(.network(URL(string: "https://www.baidu.com/img/bd_logo1.png")!), at: 0)
        return images[index]
    }
}


class Drawable: NSObject, CCDrawable {
    var index: Int
    
    init(_ index: Int) {
        self.index = index
        super.init()
    }
    
    func drawableView(_ view: UIView, atRect rect: CGRect) {
        NSAttributedString(string: "\(index)", attributes: [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 42),
            NSAttributedStringKey.foregroundColor: UIColor.red
            ]).draw(at: .zero)
    }
}
