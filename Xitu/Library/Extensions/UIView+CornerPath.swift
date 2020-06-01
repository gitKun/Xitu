//
//  UIView+CornerPath.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/1.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit

public extension UIView {

  /// 获取指定rect内的圆角路径
  /// - Parameters:
  ///   - rect: rect
  ///   - cornerTyle: 圆角
  ///   - radius: 半径
  ///   - inset: 内敛范围
  /// - Returns: 路径
  func cornerPath(
    rect: CGRect,
    cornerTyle: UIRectCorner = .allCorners,
    radius: CGFloat = 4,
    inset: UIEdgeInsets = .zero) -> UIBezierPath {
    let rect = rect.innerInsetRect(inset)
    let width = rect.width
    let height = rect.height
    let radius = max(0, min(radius, min(width, height) * 0.5))
    guard cornerTyle != .allCorners else {
      return UIBezierPath(roundedRect: rect, cornerRadius: radius)
    }
    fatalError("暂未实现! ____#")
  }
}

