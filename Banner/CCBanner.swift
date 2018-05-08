//
//  CCBanner.swift
//  Banner
//
//  Created by Trinity on 2018/5/8.
//  Copyright © 2018年 Trinity. All rights reserved.
//

import UIKit


@objc protocol CCDrawable {
    func drawableView(_ view: UIView, atRect rect: CGRect)
}

@objc protocol CCBannerDelegate: CCDrawable {
    @objc func banner(_ banner: CCBanner, selectedAtIndex index: Int)
    @objc func banner(_ banner: CCBanner, insetOfImageAtIndex: Int)
}

protocol CCBannerDataSource: AnyObject {
    func numberOfImages(inBanner banner: CCBanner) -> Int
    func banner(_ banner: CCBanner, imageAtIndex: Int) -> CCBannerImage?
}

enum CCBannerImage {
    case memory(UIImage)
    case network(URL)
}

class CCBanner: UIControl, CCDrawable {
    var delegate: CCBannerDelegate?
    var dataSource: CCBannerDataSource?
    var imageInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: bounds)
        addSubview(scrollView)
        bannerViews.forEach { scrollView.addSubview($0) }
        return scrollView
    }()
    
    let bannerViews: [CCBannerView] = (0..<3).map { _ in CCBannerView() }

    lazy var configureOnce: Void = {
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = configureOnce
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _ = configureOnce
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let drawable: CCDrawable = delegate ?? self
        drawable.drawableView(self, atRect: rect)
    }
    
    func drawableView(_ view: UIView, atRect rect: CGRect) {
        // Draw anything you want.
        NSAttributedString(string: "mangonob").draw(at: .zero)
    }
}


class CCBannerView: UIImageView {
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        addSubview(imageView)
        return imageView
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}

