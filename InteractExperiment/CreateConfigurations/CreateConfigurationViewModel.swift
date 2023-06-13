//
//  CreateConfigurationViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation
import SwiftUI
import UIKit

struct ImageInfo: Identifiable {
    let uuid: String = UUID().uuidString
    let image: UIImage
    var id: String { uuid }
}

class ExperimentImages: ObservableObject {
    enum ImageType {
        case familiarisation, stimulus
    }
    
    @Published private(set) var images: [ImageInfo] = []
    private let type: ImageType
    
    init(type: ImageType) {
        self.type = type
    }
    
    func add(image: UIImage) {
        images.append(ImageInfo(image: image))
    }
    
    func remove(indexes: IndexSet) {
        images.remove(atOffsets: indexes)
    }
}

protocol CreateConfigurationViewModelProtocol: ObservableObject {
    var familiarImages: ExperimentImages { get }
    var stimulusImages: ExperimentImages { get }
    
    func append(image: UIImage, type: ExperimentImages.ImageType)
    func deleteImages(indexes: IndexSet, type: ExperimentImages.ImageType)
    func save()
}

@MainActor class CreateConfigurationViewModel: CreateConfigurationViewModelProtocol {
    @Published private(set) var familiarImages: ExperimentImages = ExperimentImages(type: .familiarisation)
    @Published private(set) var stimulusImages: ExperimentImages = ExperimentImages(type: .stimulus)
    
    @Published private var configurations: ConfigurationModel
    
    init(configurations: ConfigurationModel) {
        self.configurations = configurations
        
        setupBindings()
    }
    
    convenience init() {
        self.init(configurations: .init(id: UUID().uuidString))
    }
    
    func append(image: UIImage, type: ExperimentImages.ImageType) {
        switch type {
        case .familiarisation:
            familiarImages.add(image: image)
        case .stimulus:
            stimulusImages.add(image: image)
        }
    }
    
    func deleteImages(indexes: IndexSet, type: ExperimentImages.ImageType) {
        switch type {
        case .familiarisation:
            familiarImages.remove(indexes: indexes)
        case .stimulus:
            stimulusImages.remove(indexes: indexes)
        }
    }
    
    func save() {
    }
}
