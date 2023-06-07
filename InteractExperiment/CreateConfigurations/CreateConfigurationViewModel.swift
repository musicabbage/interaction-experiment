//
//  CreateConfigurationViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation
import SwiftUI

struct ImageInfo: Identifiable {
    enum ImageType {
        case familiarization, stimulus
    }
    
    let type: ImageType
    let uuid: String = UUID().uuidString
    let image: Image
    var id: String { uuid }
}

protocol CreateConfigurationViewModelProtocol: ObservableObject {
    var familiarImages: [ImageInfo] { get }
    var stimulusImages: [ImageInfo] { get }
    
    func appendFamiliarization(image: Image)
    func appendStimulus(image: Image)
    func deleteFamiliarization(indexes: [Int])
    func deleteStimulus(indexes: [Int])
}

@MainActor class ViewModel: CreateConfigurationViewModelProtocol {
    @Published var familiarImages: [ImageInfo] = []
    @Published var stimulusImages: [ImageInfo] = []
    
    @Published private var configurations: ConfigurationModel
    
    init(configurations: ConfigurationModel) {
        self.configurations = configurations
    }
    
    convenience init() {
        self.init(configurations: .init(id: UUID().uuidString))
    }
    
    //
    func appendFamiliarization(image: Image) {
        let newImage = ImageInfo(type: .familiarization, image: image)
        familiarImages.append(newImage)
    }
    
    func appendStimulus(image: Image) {
        let newImage = ImageInfo(type: .stimulus, image: image)
        stimulusImages.append(newImage)
    }
    
    func deleteFamiliarization(indexes: [Int]) {
        
    }
    
    func deleteStimulus(indexes: [Int]) {
        
    }
}
