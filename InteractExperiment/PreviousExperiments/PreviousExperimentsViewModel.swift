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
    
    func deleteExperiment(id: String)
}

class PreviousExperimentsViewModel: PreviousExperimentsViewModelProtocol {
    enum ViewState {
        case loadExperiments([PreviousExperimentsModel])
        case error(String)
    }
    
    private let viewStateSubject: PassthroughSubject<ViewState, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    private var experiments: [PreviousExperimentsModel] = []
    private var configurations: [ConfigurationModel] = []
    private var configurationsMapping: [String: [String]] = [:] //configuration id: experiment id list
    
    let viewState: AnyPublisher<ViewState, Never>
    
    init() {
        viewState = viewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        
        Task {
            do {
                try await loadExperiments()
                viewStateSubject.send(.loadExperiments(experiments))
            } catch {
                viewStateSubject.send(.error("load experiments error"))
            }
        }
    }
    
    func deleteExperiment(id: String) {
        guard let deleteIndex = experiments.firstIndex(where: { $0.id == id }) else { return }
        let deleteExperiment = experiments.remove(at: deleteIndex)
        for (configuration, experimentIds) in configurationsMapping {
            guard let index = experimentIds.firstIndex(where: { $0 == id }) else { continue }
            var experimentIds = experimentIds
            experimentIds.remove(at: index)
            do {
                if experimentIds.isEmpty,
                   let configurationIndex = configurations.firstIndex(where: { $0.id == configuration }) {
                    //delete configuration folder
                    let deleteConfig = configurations.remove(at: configurationIndex)
                    try FileManager.default.removeItem(at: deleteConfig.folderURL)
                } else if !experiments.isEmpty {
                    configurationsMapping[configuration] = experimentIds
                }
                try FileManager.default.removeItem(at: deleteExperiment.folderURL)
                viewStateSubject.send(.loadExperiments(experiments))
            } catch {
                viewStateSubject.send(.error("delete failed"))
            }
            break
        }
    }
}

private extension PreviousExperimentsViewModel {
    func loadExperiments() async throws {
        //get all configurations
        let configsPaths = try FileManager.default.contentsOfDirectory(at: FileManager.configsDirectory, includingPropertiesForKeys: nil)
        configurations = []
        let configs = configsPaths.reduce(into: [String: ConfigurationModel]()) { result, url in
            guard let configData = try? Data(contentsOf: url.appending(path: ConfigurationModel.configFilename)),
                  let config = try? JSONDecoder().decode(ConfigurationModel.self, from: configData) else {
                      return
                  }
            result[config.id] = config
            configurations.append(config)
        }
        
        //get all experiments
        let experimentFiles = try FileManager.default.contentsOfDirectory(at: FileManager.experimentsDirectory, includingPropertiesForKeys: nil)
        let results = experimentFiles.reduce(into: [(InteractLogModel, ConfigurationModel)]()) { partialResult, url in
            guard let experimentData = try? Data(contentsOf: url.appending(path: InteractLogModel.filename)),
                  let experiment = try? JSONDecoder().decode(InteractLogModel.self, from: experimentData),
            let config = configs[experiment.configId] else {
                return
            }
            partialResult.append((experiment, config))
        }
        
        experiments = results.reduce(into: [PreviousExperimentsModel]()) { partialResult, experiment in
            partialResult.append(.init(experiment: experiment.0, configurations: experiment.1))
        }
        experiments.sort(by: { lhs, rhs in
            guard let lhsDate = lhs.date, let rhsDate = rhs.date else {
                return true
            }
            return lhsDate.timeIntervalSince1970 > rhsDate.timeIntervalSince1970
        })
        
        configurationsMapping = results.reduce(into: [String: [String]]()) { partialResult, models in
            //models = (InteractLogModel, ConfigurationModel)
            let configurationId = models.1.id
            let experimentId = models.0.id
            if var experimentIds = partialResult[configurationId] {
                experimentIds.append(experimentId)
                partialResult[configurationId] = experimentIds
            } else {
                partialResult[configurationId] = [experimentId]
            }
        }
    }
}

extension PreviousExperimentsViewModel {
    static var mock: PreviousExperimentsViewModel {
        .init()
    }
}
