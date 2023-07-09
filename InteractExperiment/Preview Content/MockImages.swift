//
//  MockImages.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/8.
//

import UIKit

extension UIImage {
    static var mockFamiliarisationImage: UIImage {
        UIImage(named: "Familiarisation") ?? UIImage(systemName: "questionmark.circle.fill")!
    }
}
