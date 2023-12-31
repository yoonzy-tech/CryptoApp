//
//  UIColor+Extensions.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: AppColor, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.rawValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let red = Int(color >> 16) & mask
        let green = Int(color >> 8) & mask
        let blue = Int(color) & mask
        let redFloat   = CGFloat(red) / 255.0
        let greenFloat = CGFloat(green) / 255.0
        let blueFloat  = CGFloat(blue) / 255.0
        self.init(red: redFloat, green: greenFloat, blue: blueFloat, alpha: alpha)
    }
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red * 255)<<16 | (Int)(green * 255)<<8 | (Int)(blue * 255)<<0
        return String(format: "#%06x", rgb)
    }
}
