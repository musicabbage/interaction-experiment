//
//  ConfigurationDraftsViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/8/27.
//

import Foundation
import Combine

protocol ConfigurationDraftsViewModelProtocol {
    var viewState: AnyPublisher<ConfigurationDraftsViewModel.ViewState, Never> { get }
}

class ConfigurationDraftsViewModel: ConfigurationDraftsViewModelProtocol {
    enum ViewState {
        case loadDrafts([ConfigurationModel])
    }
    
    private let viewStateSubject: PassthroughSubject<ViewState, Never> = .init()
    private var configurations: [ConfigurationModel] = []
    
    let viewState: AnyPublisher<ViewState, Never>
    
    init() {
        viewState = viewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        Task {
            do {
                try await loadConfigurations()
            } catch {
                print(error)
            }
        }
    }
    
}

private extension ConfigurationDraftsViewModel {
    func loadConfigurations() async throws {
        //get all configurations
        let configsPaths = try FileManager.default.contentsOfDirectory(at: FileManager.configDraftsDirectory, includingPropertiesForKeys: nil)
        configurations = []
        for path in configsPaths {
            let fullPath = path.appending(path: ConfigurationModel.configFilename)
            guard FileManager.default.fileExists(atPath: fullPath.path) else { continue }
            let configData = try Data(contentsOf: fullPath)
            let config = try JSONDecoder().decode(ConfigurationModel.self, from: configData)
            configurations.append(config)
        }
        
        viewStateSubject.send(.loadDrafts(configurations))
    }
}

extension ConfigurationDraftsViewModel {
    static var mock: ConfigurationDraftsViewModel {
        .init()
    }
}
