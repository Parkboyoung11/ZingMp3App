//
//  DesignableSlider.swift
//  ZingMp3App
//
//  Created by VuHongSon on 8/8/17.
//  Copyright © 2017 VuHongSon. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableSlider: UISlider {
    @IBInspectable var thumbImage: UIImage? {
        didSet{
            setThumbImage(thumbImage, for: .normal)
        }
    }
    
    @IBInspectable var thumbHighlightImage: UIImage? {
        didSet{
            setThumbImage(thumbHighlightImage,for: .highlighted)
        }
    }
}
