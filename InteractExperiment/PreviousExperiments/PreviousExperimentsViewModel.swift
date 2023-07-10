//
//  PreviousExperimentsViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/8.
//

import Combine
import Foundation

protocol PreviousExperimentsViewModelProtocol {
    var viewState: AnyPublisher<PreviousExperimentsViewModel.ViewState, Never> { get }
}

class PreviousExperimentsViewModel: PreviousExperimentsViewModelProtocol {
    enum ViewState {
        case loadExperiments([PreviousExperimentsModel])
        case error(String)
    }
    
    private let viewStateSubject: PassthroughSubject<ViewState, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    let viewState: AnyPublisher<ViewState, Never>
    
    init() {
        viewState = viewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        
        Task {
            do {
                let previousExperiments = try await loadExperiments()
                viewStateSubject.send(.loadExperiments(previousExperiments))
            } catch {
                viewStateSubject.send(.error("load experiments error"))
            }
        }
    }
}

private extension PreviousExperimentsViewModel {
    func loadExperiments() async throws -> [PreviousExperimentsModel] {
        let configsPaths = try FileManager.default.contentsOfDirectory(at: FileManager.configsDirectory, includingPropertiesForKeys: nil)
        let configs = configsPaths.reduce(into: [String: ConfigurationModel]()) { result, url in
            guard let configData = try? Data(contentsOf: url.appending(path: ConfigurationModel.configFilename)),
                  let config = try? JSONDecoder().decode(ConfigurationModel.self, from: configData) else {
                      return
                  }
            result[config.id] = config
        }
        let experiments = try FileManager.default.contentsOfDirectory(at: FileManager.experimentsDirectory, includingPropertiesForKeys: nil)
        let results = experiments.reduce(into: [(InteractLogModel, ConfigurationModel)]()) { partialResult, url in
            guard let experimentData = try? Data(contentsOf: url.appending(path: InteractLogModel.filename)),
                  let experiment = try? JSONDecoder().decode(InteractLogModel.self, from: experimentData),
            let config = configs[experiment.configId] else {
                return
            }
            partialResult.append((experiment, config))
        }
        
        let previousExperiments = results.reduce(into: [PreviousExperimentsModel]()) { partialResult, experiment in
            partialResult.append(.init(experiment: experiment.0, configurations: experiment.1))
        }
        return previousExperiments
    }
}

extension PreviousExperimentsViewModel {
    static var mock: PreviousExperimentsViewModel {
        .init()
    }
}
