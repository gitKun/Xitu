//
//  UIColor+Hex.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/1.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit

public extension UIColor {

    /// KunTools: Create Color from RGB values with optional transparency.
    ///
    /// - Parameters:
    ///   - red: red component.
    ///   - green: green component.
    ///   - blue: blue component.
    ///   - transparency: optional transparency value (default is 1).
    convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }

    /// KunTools: Create Color from ARGB Hex value
    /// - Parameter hex: ARGB Hex value
    convenience init?(argbHex hex: UInt32) {
        let trans = (hex >> 24) & 0xff
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        let alpha =  255.0 / CGFloat(trans)
      self.init(red: Int(red), green: Int(green), blue: Int(blue), transparency: alpha)
    }
}
