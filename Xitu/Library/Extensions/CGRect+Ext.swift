//
//  CGRect+Ext.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/1.
//  Copyright © 2020 kun. All rights reserved.
//

import Foundation

public extension CGRect {

  /// 获取inset后的rect
  /// - Parameter inset: inset
  /// - Returns: 结果
  func innerInsetRect(_ inset: UIEdgeInsets) -> CGRect {
    let pointX = minX + inset.left
    let pointY = minY + inset.top
    let outputWidth = width - inset.left - inset.right
    let outputHeihgt = height - inset.top - inset.bottom
    guard outputWidth > 0, outputHeihgt > 0 else { return self }
    return CGRect(x: pointX, y: pointY, width: outputWidth, height: outputHeihgt)
  }
}
