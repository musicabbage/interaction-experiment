//
//  CreateConfigurationViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import Foundation
import SwiftUI
import UIKit
import Combine

struct ImageInfo: Identifiable {
    let uuid: String = UUID().uuidString
    let image: UIImage
    let imageName: String
    var id: String { uuid }
}

class ExperimentImages: ObservableObject, Equatable {
    enum ImageType {
        case familiarisation, stimulus
    }
    
    @Published private(set) var images: [ImageInfo] = []
    private let type: ImageType
    
    static func == (lhs: ExperimentImages, rhs: ExperimentImages) -> Bool {
        guard lhs.type == rhs.type else {
            return false
        }
        
        let imageSetL = lhs.images.reduce(into: Set<String>()) { $0.formUnion([$1.uuid]) }
        let imageSetR = rhs.images.reduce(into: Set<String>()) { $0.formUnion([$1.uuid]) }
        return imageSetL == imageSetR
    }
    
    init(type: ImageType) {
        self.type = type
    }
    
    func add(image: UIImage) {
        let name: String
        switch type {
        case .familiarisation:
            name = "P\(images.count + 1)"
        case .stimulus:
            name = "S\(images.count + 1)"
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

protocol CreateConfigurationViewModelProtocol {
    var configurations: ConfigurationModel { get }
    var viewState: AnyPublisher<CreateConfigurationViewModel.ViewState, Never> { get }
    var currentViewState: CreateConfigurationViewModel.ViewState { get }
    
    func append(image: UIImage, type: ExperimentImages.ImageType)
    func deleteImages(indexes: IndexSet, type: ExperimentImages.ImageType)
    func update(instruction: String)
    func save(asDraft isDraft: Bool)
}

class CreateConfigurationViewModel: CreateConfigurationViewModelProtocol {
    enum ViewState: Equatable {
        case none
        case draftSaved
        case savedAndContinue
        case updateFamiliarisationImages(ExperimentImages)
        case updateStimulusImages(ExperimentImages)
        
        case error(String)
        
        var message: String {
            switch self {
            case .savedAndContinue, .draftSaved:
                return "Save success"
            case let .error(message):
                return message
            default:
                return ""
            }
        }
    }
    
    private var familiarImages: ExperimentImages = ExperimentImages(type: .familiarisation)
    private var stimulusImages: ExperimentImages = ExperimentImages(type: .stimulus)
    private(set) var configurations: ConfigurationModel
    
    private let viewStateSubject: CurrentValueSubject<CreateConfigurationViewModel.ViewState, Never> = .init(.none)
    let viewState: AnyPublisher<ViewState, Never>
    var currentViewState: ViewState { viewStateSubject.value }
    
    init(configurations: ConfigurationModel) {
        self.configurations = configurations
        self.viewState = viewStateSubject.eraseToAnyPublisher()
    }
    
    convenience init() {
        self.init(configurations: .init())
    }
    
    func append(image: UIImage, type: ExperimentImages.ImageType) {
        switch type {
        case .familiarisation:
            familiarImages.reset()
            familiarImages.add(image: image)
            viewStateSubject.send(.updateFamiliarisationImages(familiarImages))
        case .stimulus:
            stimulusImages.add(image: image)
            viewStateSubject.send(.updateStimulusImages(stimulusImages))
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
    
    func update(instruction: String) {
        configurations.instruction = instruction
    }
    
    func save(asDraft isDraft: Bool = false) {
        do {
            var isDirectory = ObjCBool(false)
            let folderURL = configurations.folderURL
            let fileExisted = FileManager.default.fileExists(atPath: folderURL.path(), isDirectory: &isDirectory)
            if !(fileExisted && isDirectory.boolValue) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
            //save images
            if let familiarisationImage = self.familiarImages.images.first,
               let familiarisationImageData = familiarisationImage.image.pngData() {
                let fileName = "\(familiarisationImage.imageName).png"
                try familiarisationImageData.write(to: folderURL.appending(component: fileName))
                configurations.familiarImages = [fileName]
            }
            var stimulusList: [String] = []
            try stimulusImages.images.forEach { stimulus in
                guard let stimulusImageData = stimulus.image.pngData() else {
                    throw CocoaError(.fileWriteUnknown)
                }
                let fileName = "\(stimulus.imageName).png"
                try stimulusImageData.write(to: folderURL.appending(component: fileName))
                stimulusList.append(fileName)
            }
            configurations.stimulusImages = stimulusList
            
            //encode configurations
            let configurationData = try JSONEncoder().encode(configurations)
            try configurationData.write(to: configurations.configURL)
            
            viewStateSubject.send(isDraft ? .draftSaved : .savedAndContinue)
        } catch {
            viewStateSubject.send(.error("\(error)"))
        }
    }
}
