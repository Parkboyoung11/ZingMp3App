//
//  DeveloperInformation.swift
//  ZingMp3App
//
//  Created by VuHongSon on 8/7/17.
//  Copyright © 2017 VuHongSon. All rights reserved.
//

import UIKit

class DeveloperInformation: UIViewController {
    @IBOutlet weak var lblInformation: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let mes = "Vu Hong Son\nvuhongsonjv11@gmail.com\n+84 971 034 608"
        lblInformation.text = mes
    }
    
}
