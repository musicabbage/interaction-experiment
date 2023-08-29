//
//  ColorExtensions.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/5/30.
//

import SwiftUI

extension Color {
    static let button = Color.Button()
    static let checkBox = Color.CheckBox()
    static let text = Color.Text()
    static let background = Color.Background()
    
    struct Button {
        let lightgray = Color("LightGrayButtonBackground")
        let gray = Color("GrayButton")
        let red = Color("RedButton")
    }
    
    struct CheckBox {
        let unchecked = Color("CheckBox_unchecked")
        let checked = Color.blue
    }
    
    struct Text {
        let sectionTitle = Color("SectionTitle")
    }
    
    struct Background {
        let lightgray = Color("LightGrayBackground")
        let lightRed = Color("LightRedBackground")
    }
}
