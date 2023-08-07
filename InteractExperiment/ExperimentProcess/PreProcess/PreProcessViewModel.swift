//
//  PreProcessViewModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/20.
//

import Foundation
import Combine

protocol PreProcessViewModelProtocol {
    var consentFormPDF: URL { get }
    var questionnaireURL: URL { get }
    var viewState: AnyPublisher<PreProcessViewModel.ViewState, Never> { get }
    
    func saveConsentFormFromData(dataURL: URL)
    
}

class PreProcessViewModel: PreProcessViewModelProtocol {
    enum ViewState {
        case loading(Bool)
        case savePDFSuccess
        case error(String)
    }
    
    private let configurations: ConfigurationModel
    private let experiment: InteractLogModel
    private let viewStateSubject: PassthroughSubject<ViewState, Never> = .init()
    
    let consentFormPDF: URL = Bundle.main.url(forResource: "PIS_and_Consent_form_v3", withExtension: "pdf")!
    let questionnaireURL: URL = URL(string: "https://www.surveymonkey.co.uk/r/5ZV2MMW")!
    let viewState: AnyPublisher<ViewState, Never>
    
    init(configurations: ConfigurationModel, experiment: InteractLogModel) {
        self.configurations = configurations
        self.experiment = experiment
        self.viewState = viewStateSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func saveConsentFormFromData(dataURL: URL) {
        viewStateSubject.send(.loading(true))
        do {
            let folderURL = experiment.folderURL
            var isDirectory = ObjCBool(false)
            let fileExisted = FileManager.default.fileExists(atPath: folderURL.path(), isDirectory: &isDirectory)
            if !(fileExisted && isDirectory.boolValue) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
            
            try FileManager.default.moveItem(at: dataURL, to: folderURL.appending(path: "consent_form.pdf"))
            print("saveConsentFormFromData > \(folderURL)")
            viewStateSubject.send(.savePDFSuccess)
        } catch {
            viewStateSubject.send(.error("save PDF error..."))
        }
    }
}

extension PreProcessViewModel {
    static var mock: PreProcessViewModel {
        PreProcessViewModel(configurations: .mock, experiment: .mock)
    }
}
