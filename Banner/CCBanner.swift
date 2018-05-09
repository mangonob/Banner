//
//  CCBanner.swift
//  Banner
//
//  Created by Trinity on 2018/5/8.
//  Copyright © 2018年 Trinity. All rights reserved.
//

import UIKit


@objc protocol CCDrawable {
    @objc optional func drawableView(_ view: UIView, atRect rect: CGRect)
}

@objc protocol CCBannerDelegate: CCDrawable {
    @objc optional func banner(_ banner: CCBanner, selectedAtIndex index: Int)
    @objc optional func banner(_ banner: CCBanner, insetOfImageAtIndex index: Int) -> UIEdgeInsets
    @objc optional func banner(_ banner: CCBanner, drawableAtIndex index: Int) -> CCDrawable?
    @objc optional func banner(_ banner: CCBanner, contentModeAtIndex index: Int) -> UIViewContentMode
}

protocol CCBannerDataSource: AnyObject {
    func numberOfImages(inBanner banner: CCBanner) -> Int
    func banner(_ banner: CCBanner, imageAtIndex index: Int) -> CCBannerImage?
}

enum CCBannerImage {
    case memory(UIImage)
    case network(URL)
}

class CCBanner: UIControl, CCDrawable {
    var delegate: CCBannerDelegate? {
        didSet {
            setNeedsDisplay()
            cover.drawable = delegate
        }
    }

    var dataSource: CCBannerDataSource? {
        didSet {
            cachedImages = nil
            reloadBanner()
        }
    }
    
    var imageInsets: UIEdgeInsets = .zero
    var images: [CCBannerImage?]? {
        didSet {
            if dataSource == nil {
                cachedImages = nil
                reloadBanner()
            }
        }
    }
    
    var isCircle: Bool = true {
        didSet {
        }
    }

    var isAutoRuning: Bool = true {
        didSet {
        }
    }
    
    var runningDuration: TimeInterval = 1.5 {
        didSet {
        }
    }

    private lazy var prepareOnce: Void = {
        currentIndex = 0
    }()
    
    private var originalOffset: Int = 0
    
    var progress: Double = 0 {
        didSet {
            guard progress != oldValue else { return }
            setNeedsDisplay()
            
            if progress == -1 || progress == 1 {
                currentIndex += Int(progress)
                withOutObserving {
                    if isCircle {
                        scrollView.contentOffset.x = bounds.width
                        originalOffset = 1
                    } else {
                        if currentIndex == 0 {
                            scrollView.contentOffset = .zero
                            originalOffset = 0
                        } else if currentIndex == numberOfImages - 1 {
                            scrollView.contentOffset.x = bounds.width * 2
                            originalOffset = 2
                        } else {
                            scrollView.contentOffset.x = bounds.width
                            originalOffset = 1
                        }
                    }
                }
            } else if progress == 0 {
                _ = prepareOnce
            }
        }
    }

    fileprivate lazy var cover: CCBannerCoverView = {
        let cover = CCBannerCoverView()
        cover.backgroundColor = .clear
        addSubview(cover)
        cover.isUserInteractionEnabled = false
        cover.drawable = self
        return cover
    }()

    private var numberOfImages: Int {
        return dataSource?.numberOfImages(inBanner: self) ?? images?.count ?? 0
    }
    
    private func imageAtIndex(_ index: Int) -> CCBannerImage? {
        return dataSource?.banner(self, imageAtIndex: index) ?? images?[index]
    }
    
    private func imageInsetsAtIndex(_ index: Int) -> UIEdgeInsets {
        return delegate?.banner?(self, insetOfImageAtIndex: index) ?? imageInsets
    }
    
    private func drawableAtIndex(_ index: Int) -> CCDrawable? {
        return delegate?.banner?(self, drawableAtIndex: index)
    }
    
    private func contentModeAtIndex(_ index: Int) -> UIViewContentMode {
        return delegate?.banner?(self, contentModeAtIndex: index) ?? contentMode
    }

    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: bounds)
        insertSubview(scrollView, at: 0)
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    fileprivate lazy var bannerViews: [CCBannerView] = {
        let bannerViews = (0..<3).map { (_) -> CCBannerView in
            let banner = CCBannerView()
            scrollView.addSubview(banner)
            return banner
        }

        return bannerViews
    }()
    
    var imageViews: [UIImageView] {
        return bannerViews.map { $0.imageView }
    }
    
    private var scrollViewObserving: NSKeyValueObservation!
    
    private var isObserving = true
    private func withOutObserving(handler: () -> Void) {
        objc_sync_enter(isObserving)
        defer { objc_sync_exit(isObserving) }
        
        isObserving = false
        handler()
        isObserving = true
    }
    
    lazy var configureOnce: Void = {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:))))
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.new, .old], context: nil)
        originalOffset = isCircle ? 1 : 0
    }()
    
    private var cachedImages: [CCBannerImage?]!

    private func reloadBanner() {
        if cachedImages == nil {
            cachedImages = (0..<numberOfImages).map { imageAtIndex($0) }
        }
        
        struct Item {
            var viewIndex: Int
            var imageIndex: Int
        }
        
        var items = [Item]()

        if !isCircle && currentIndex == 0 {
            items = [
                Item(viewIndex: 0, imageIndex: currentIndex),
                Item(viewIndex: 1, imageIndex: (currentIndex + 1) % numberOfImages)
            ]
        } else if !isCircle && currentIndex == numberOfImages - 1 {
            items = [
                Item(viewIndex: 1, imageIndex: (currentIndex - 1 + numberOfImages) % numberOfImages),
                Item(viewIndex: 2, imageIndex: currentIndex)
            ]
        } else {
            items = [
                Item(viewIndex: 0, imageIndex: (currentIndex + numberOfImages - 1) % numberOfImages),
                Item(viewIndex: 1, imageIndex: currentIndex),
                Item(viewIndex: 2, imageIndex: (currentIndex + 1) % numberOfImages),
            ]
        }
        
        items.filter { cachedImages[$0.imageIndex] is CCBannerImage }
            .map { (imageViews[$0.viewIndex], cachedImages[$0.imageIndex]!) }
            .forEach { (imageView, image) in
        }
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    private var _currentIndex: Int = 0
    var currentIndex: Int {
        set {
            _currentIndex = newValue
            sendActions(for: .valueChanged)
            reloadBanner()
        }
        get {
            return numberOfImages > 0 ? (_currentIndex % numberOfImages + numberOfImages) % numberOfImages : 0
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard isObserving else { return }
        guard !isBoundsChanging else { return }
        guard numberOfImages > 0 else { return }

        guard let contentOffset = change?[NSKeyValueChangeKey.newKey] as? CGPoint else { return }
        guard let oldValue = change?[NSKeyValueChangeKey.oldKey] as? CGPoint else { return }
        guard contentOffset != oldValue else { return }
        var delta = Double((contentOffset.x - bounds.width * CGFloat(originalOffset)) / bounds.width)
        delta = min(max(delta, -1), 1)

        progress = delta
    }

    @objc private func tapAction(_ sender: Any) {
    }

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
        isBoundsChanging = true
        defer { isBoundsChanging = false }

        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: bounds.width * 3, height: bounds.height)
        
        var divided = CGRect(origin: .zero, size: scrollView.contentSize).divided(atDistance: bounds.width, from: .minXEdge)
        bannerViews.forEach { $0.frame = divided.slice; divided = divided.remainder.divided(atDistance: bounds.width, from: .minXEdge) }
        
        cover.frame = bounds

        scrollView.contentOffset = CGPoint(x: bounds.width * CGFloat(originalOffset), y: 0)
    }
    
    private var isBoundsChanging: Bool = false
    override var bounds: CGRect {
        willSet {
            isBoundsChanging = true
        }
        didSet {
            isBoundsChanging = false
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let drawable: CCDrawable = delegate ?? self
        drawable.drawableView?(self, atRect: rect)
    }
    
    func drawableView(_ view: UIView, atRect rect: CGRect) {
        // Draw anything you want.
        NSAttributedString(string: "Please draw page indicator for me.").draw(at: .zero)
    }
}


class CCBannerView: UIView {
    var drawable: CCDrawable? {
        didSet {
            cover.drawable = drawable
        }
    }
    
    fileprivate lazy var cover: CCBannerCoverView = {
        let cover = CCBannerCoverView()
        cover.backgroundColor = UIColor.clear
        cover.isUserInteractionEnabled = false
        addSubview(cover)
        return cover
    }()
    
    override var contentMode: UIViewContentMode {
        didSet {
            imageView.contentMode = contentMode
        }
    }

    var imageViewInsets: UIEdgeInsets = .zero {
        didSet {
            layoutSubviews()
        }
    }
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        insertSubview(imageView, at: 0)
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        imageView.frame = CGRect(x: imageViewInsets.left,
                                 y: imageViewInsets.right,
                                 width: bounds.width - (imageViewInsets.left + imageViewInsets.right),
                                 height: bounds.height - (imageViewInsets.top + imageViewInsets.bottom))
        cover.frame = bounds
    }
}


fileprivate class CCBannerCoverView: UIView {
    var drawable: CCDrawable? {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawable?.drawableView?(self, atRect: rect)
    }
}
