//
//  XTImageContentView.swift
//  AppWithRxSwift
//
//  Created by DR_Kun on 2020/5/24.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

typealias ImageViewTapInfo = (sourceView: UIImageView, models: [PictureItem]?, selsctIndex: Int?)

class XTImageContentView: UIView {

  private lazy var imageItems: [PictureItem] = []

  private var showHeight: CGFloat = 0 {
    didSet {
      invalidateIntrinsicContentSize()
      setNeedsUpdateConstraints()
    }
  }

  private lazy var imageViews: [UIImageView] = (0..<9).map { _ in
    let imgView = UIImageView.init(frame: .zero)
    imgView.clipsToBounds = true
    imgView.contentMode = .scaleAspectFill
    imgView.isHidden = true
    return imgView
  }

  private(set) var imageViewTapStream: Driver<ImageViewTapInfo>!

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initialTapGesture()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialTapGesture()
  }

  // MARK: 自适应高度
  override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.size.width, height: showHeight)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: size.width, height: showHeight)
  }

  deinit {
    print("\(Self.self) \(#function) ____#")
  }
}

// MARK: Public
extension XTImageContentView {
  func reloadImages(picItems: [PictureItem]) {
    self.imageItems = picItems
    updateImageView()
  }
}

// MARK: Core (更新图片和高度)
private extension XTImageContentView {
  func updateImageView() {
    // 清空原有的
    self.imageViews.forEach { imgView in
      imgView.isHidden = true
    }
    // 没有图片
    if imageItems.isEmpty {
      showHeight = 0
      return
    }
    let count = imageItems.count
    // 只有一个 根据 items 的宽高布局 image
    if count == 1 {
      onlyUpateFirstImageView()
      return
    }
    // 更新高度 和 image
    updateMutilpImageView()
  }
  /// 只更新一张
  func onlyUpateFirstImageView() {
    if let firstItem = imageItems.first {
      let maxImgSize: CGFloat = 215
      let width = firstItem.width
      let height = firstItem.height
      let imgView = imageViews[0]
      var imgFarme = imgView.frame
      let radio = width / height
      if radio > 1 {
        imgFarme.size.width = min(width, maxImgSize)
        imgFarme.size.height = imgFarme.width / radio
      } else {
        imgFarme.size.height = min(height, maxImgSize)
        imgFarme.size.width = imgFarme.height * radio
      }
      imgFarme.origin = CGPoint(x: 0, y: 5)
      showHeight = imgFarme.height + 10
      imgView.frame = imgFarme
      imgView.isHidden = false
      imgView.image = UIImage(named: firstItem.actUrl)
    }
  }
  /// 更新多张图片
  func updateMutilpImageView() {
    var items = imageItems
    if items.count > 9 {
      items = Array(items[0..<9])
    }
    var current = 0
    let space: CGFloat = 5
    let width: CGFloat = {
      let sWidth = UIScreen.main.bounds.width
      let eachWidth = floor((sWidth - (12 + space) * 2) / 3)
      return eachWidth
    }()
    // 每行3个
    let colum = 3
    for item in items {
      let pointX = ceil(CGFloat(current % colum) * (width + space))
      let pointY = ceil(CGFloat(current / colum) * (width + space) + space)
      let frame = CGRect(x: pointX, y: pointY, width: width, height: width)
      let imgView = imageViews[current]
      imgView.isHidden = false
      imgView.frame = frame
      imgView.image = UIImage(named: item.actUrl)
      current += 1
    }
    let row = ceil(CGFloat(current) / CGFloat(colum))
    showHeight = row * (width + space) + 10
  }
}

// MARK: 初始化
private extension XTImageContentView {
  func initialTapGesture() {
    var tmpArray: [Driver<ImageViewTapInfo>] = []
    imageViews.forEach { imgView in
      let tapG = UITapGestureRecognizer()
      imgView.isUserInteractionEnabled = true
      let stream = tapG.rx.event.asDriver()
        .throttle(.seconds(2), latest: false)
        .flatMapFirst { [weak self] tapG -> Driver<ImageViewTapInfo> in
          guard let imageView = tapG.view as? UIImageView else {
            return Driver.just((UIImageView(frame: .zero), self?.imageItems, 0))
          }
          return Driver.just((imageView, self?.imageItems, self?.imageViews.firstIndex(of: imageView)))
        }
      tmpArray.append(stream)
      imgView.addGestureRecognizer(tapG)
      addSubview(imgView)
    }
    imageViewTapStream = Driver.from(tmpArray).merge()
  }
}
