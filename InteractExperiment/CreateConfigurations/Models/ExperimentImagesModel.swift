//
//  ExperimentImagesModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/17.
//

import UIKit

class ExperimentImagesModel: ObservableObject, Equatable, Identifiable {
    enum ImageType: Equatable {
        case familiarisation, stimulus, custom(String)
    }
    
    @Published var name: String = ""
    @Published var allowMultipleImages: Bool = false
    @Published private(set) var images: [ImageInfo] = []
    
    private let type: ImageType
    
    static func == (lhs: ExperimentImagesModel, rhs: ExperimentImagesModel) -> Bool {
        guard lhs.type == rhs.type else {
            return false
        }
        
        let imageSetL = lhs.images.reduce(into: Set<String>()) { $0.formUnion([$1.uuid]) }
        let imageSetR = rhs.images.reduce(into: Set<String>()) { $0.formUnion([$1.uuid]) }
        return imageSetL == imageSetR
    }
    
    init(type: ImageType) {
        self.type = type
        switch type {
        case .familiarisation:
            name = "Familiarisation"
            allowMultipleImages = false
        case .stimulus:
            name = "Stimulus"
            allowMultipleImages = true
        case let .custom(customName):
            name = customName
            allowMultipleImages = true
        }
    }
    
    func add(image: UIImage) {
        let name: String
        switch type {
        case .familiarisation:
            name = "P\(images.count + 1)"
        case .stimulus:
            name = "S\(images.count + 1)"
        case let .custom(prefix):
            name = prefix + "\(images.count + 1)"
        }
        images.append(ImageInfo(image: image, imageName: name))
    }
    
    func remove(indexes: IndexSet) {
        images.remove(atOffsets: indexes)
    }
    
    func reset() {
        images.removeAll()
    }
}

extension ExperimentImagesModel {
    static var mock: ExperimentImagesModel {
        let mockImages = ExperimentImagesModel(type: .stimulus)
        mockImages.images = [.init(image: UIImage(systemName: "bolt.heart.fill")!, imageName: "mock_image_1"),
                             .init(image: UIImage(systemName: "bolt.heart")!, imageName: "mock_image_2")]
        mockImages.allowMultipleImages = true
        return mockImages
    }
}
