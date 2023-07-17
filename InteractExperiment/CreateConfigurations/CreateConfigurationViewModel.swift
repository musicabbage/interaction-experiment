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

protocol CreateConfigurationViewModelProtocol {
    var configurations: ConfigurationModel { get }
    var viewState: AnyPublisher<CreateConfigurationViewModel.ViewState, Never> { get }
    var currentViewState: CreateConfigurationViewModel.ViewState { get }
    
    func appendPhase(images: [ImageInfo], phaseName: String)
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
            case .savedAndContinue, .draftSaved:
                return "Save success"
            case let .error(message):
                return message
            default:
                return ""
            }
        }
    }
    
    private var phaseImages: [String: [ImageInfo]] = [:]
    private(set) var configurations: ConfigurationModel
    
    private let viewStateSubject: CurrentValueSubject<CreateConfigurationViewModel.ViewState, Never> = .init(.none)
    let viewState: AnyPublisher<ViewState, Never>
    var currentViewState: ViewState { viewStateSubject.value }
    
    init(configurations: ConfigurationModel) {
        self.configurations = configurations
        self.viewState = viewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    convenience init() {
        self.init(configurations: .init())
    }
    
    func appendPhase(images: [ImageInfo], phaseName: String) {
        self.phaseImages[phaseName] = images
        if !configurations.phases.contains(where: { $0.name == phaseName }) {
            let phase = ConfigurationModel.PhaseModel(name: phaseName)
            configurations.phases.append(phase)
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
            
            for phaseName in phaseImages.keys {
                guard let phaseImages = phaseImages[phaseName],
                      let phaseIndex = configurations.phases.firstIndex(where: { $0.name == phaseName }) else { continue }
                
                for image in phaseImages {
                    guard let imageData = image.image.pngData() else {
                        throw CocoaError(.fileWriteUnknown)
                    }
                    
                    try imageData.write(to: folderURL.appending(component: image.imageName))
                }
                configurations.phases[phaseIndex].images = phaseImages.map(\.imageName)
            }
            
            //encode configurations
            let configurationData = try JSONEncoder().encode(configurations)
            try configurationData.write(to: configurations.configURL)
            
            viewStateSubject.send(isDraft ? .draftSaved : .savedAndContinue)
        } catch {
            viewStateSubject.send(.error("\(error)"))
        }
    }
}
