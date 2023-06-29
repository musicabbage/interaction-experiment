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
    
    func reset() {
        images.removeAll()
    }
}

protocol CreateConfigurationViewModelProtocol: ObservableObject {
    var familiarImages: ExperimentImages { get }
    var stimulusImages: ExperimentImages { get }
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
        case error(String)
        
        var message: String {
            switch self {
            case .none:
                return ""
            case .savedAndContinue, .draftSaved:
                return "Save success"
            case let .error(message):
                return message
            }
        }
    }
    
    @Published private(set) var familiarImages: ExperimentImages = ExperimentImages(type: .familiarisation)
    @Published private(set) var stimulusImages: ExperimentImages = ExperimentImages(type: .stimulus)
    @Published private(set) var configurations: ConfigurationModel
    
    private let viewStateSubject: CurrentValueSubject<CreateConfigurationViewModel.ViewState, Never> = .init(.none)
    let viewState: AnyPublisher<ViewState, Never>
    var currentViewState: ViewState { viewStateSubject.value }
    
    init(configurations: ConfigurationModel) {
        self.configurations = configurations
        self.viewState = viewStateSubject.eraseToAnyPublisher()
    }
    
    convenience init() {
        self.init(configurations: .init(id: UUID().uuidString))
    }
    
    func append(image: UIImage, type: ExperimentImages.ImageType) {
        switch type {
        case .familiarisation:
            familiarImages.reset()
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
                try familiarisationImageData.write(to: folderURL.appending(component: familiarisationImage.uuid))
                configurations.familiarImages = [familiarisationImage.uuid]
            }
            var stimulusList: [String] = []
            try stimulusImages.images.forEach { stimulus in
                guard let stimulusImageData = stimulus.image.pngData() else {
                    throw CocoaError(.fileWriteUnknown)
                }
                try stimulusImageData.write(to: folderURL.appending(component: stimulus.uuid))
                stimulusList.append(stimulus.uuid)
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
