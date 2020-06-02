//
//  CornerBorderButton.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/1.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit

class CornerBorderButton: UIButton {

  private lazy var borderLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    return layer
  }()

//  private lazy var cornerLayer: CAShapeLayer = {
//    let layer = CAShapeLayer()
//    return layer
//  }()

  var borderColor: UIColor? = UIColor(argbHex: 0xFF66C200) {
    didSet {
      setNeedsLayout()
    }
  }

  var borderWidth: CGFloat = 0 {
    didSet {
      setNeedsLayout()
    }
  }

  var cornerRaius: CGFloat = 0 {
    didSet {
      setNeedsLayout()
    }
  }

  var innerInset: UIEdgeInsets = .zero {
    didSet {
      setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if let containts = layer.sublayers?.contains(borderLayer), !containts {
      layer.addSublayer(borderLayer)
    }
    let radius = max(0, cornerRaius)
    let width = borderWidth
    if let color = borderColor, width > 0 {
      let pathRect = bounds.innerInsetRect(innerInset)
      let path = cornerPath(rect: pathRect, radius: radius)
      borderLayer.path = path.cgPath
      borderLayer.fillColor = UIColor.clear.cgColor
      borderLayer.lineWidth = width
      borderLayer.strokeColor = color.cgColor
    } else {
      borderLayer.path = nil
    }
  }
}
