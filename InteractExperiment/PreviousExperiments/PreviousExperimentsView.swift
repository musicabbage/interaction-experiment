//
//  PreviousExperimentsView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/7.
//

import SwiftUI

struct PreviousExperimentsView: View {
    
    @State private var experiments: [PreviousExperimentsModel] = []
    @State private var showLoading: Bool = false
    
    private let viewModel: PreviousExperimentsViewModelProtocol
    var useClosure: ((String) -> Void) = { _ in }
    var deleteClosure: ((String) -> Void) = { _ in }
    var exportClosure: ((URL) -> Void) = { _ in }
    
    init(viewModel: PreviousExperimentsViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Experiments (\(experiments.count))")
                    .padding([.bottom], 2)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(experiments) { experiment in
                            PreviousExperimentItemView(experiment: experiment)
                                .onTapAction(perform: { action in
                                    switch action {
                                    case .use:
                                        useClosure(experiment.configurationURL.path())
                                    case .delete:
                                        viewModel.deleteExperiment(id: experiment.id)
                                    case .export:                                        
                                        showLoading = true
                                        exportExperiment(experiment)
                                    }
                                })
                        }
                    }
                    .padding(22)
                }
            }
            if showLoading {
                LoadingView()
            }
        }
        .onReceive(viewModel.viewState) { viewState in
            switch viewState {
            case let .loadExperiments(experiments):
                self.experiments = experiments
            default:
                break
            }
        }
    }
}

extension PreviousExperimentsView {
    func onUseConfiguration(perform action: @escaping(String) -> Void) -> Self {
        var copy = self
        copy.useClosure = action
        return copy
    }
    
    func onDeleteExperiment(perform action: @escaping(String) -> Void) -> Self {
        var copy = self
        copy.deleteClosure = action
        return copy
    }
    
    func onExportExperiment(perform action: @escaping(URL) -> Void) -> Self {
        var copy = self
        copy.exportClosure = action
        return copy
    }
}

private extension PreviousExperimentsView {
    func exportExperiment(_ experiment: PreviousExperimentsModel) {
        DispatchQueue.global(qos: .background).async {
            //https://recoursive.com/2021/02/25/create_zip_archive_using_only_foundation/
            // this will hold the URL of the zip file
            var archiveUrl: URL?
            // if we encounter an error, store it here
            var error: NSError?

            let coordinator = NSFileCoordinator()
            // zip up the documents directory
            // this method is synchronous and the block will be executed before it returns
            // if the method fails, the block will not be executed though
            // if you expect the archiving process to take long, execute it on another queue
            coordinator.coordinate(readingItemAt: experiment.folderURL, options: [.forUploading], error: &error) { (zipUrl) in
                // zipUrl points to the zip file created by the coordinator
                // zipUrl is valid only until the end of this block, so we move the file to a temporary folder
                let tmpUrl = try! FileManager.default.url(
                    for: .itemReplacementDirectory,
                    in: .userDomainMask,
                    appropriateFor: zipUrl,
                    create: true
                ).appendingPathComponent("experiment_log_\(experiment.participantId).zip")
                try? FileManager.default.moveItem(at: zipUrl, to: tmpUrl)
                print(tmpUrl)
                // store the URL so we can use it outside the block
                archiveUrl = tmpUrl
            }

            if let archiveUrl {
                // bring up the share sheet so we can send the archive with AirDrop for example
                print(archiveUrl)
                DispatchQueue.main.async {
                    showLoading = false
                    exportClosure(archiveUrl)
                }
            } else {
                print(error)
            }
        }
    }
}

struct PreviousExperimentsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousExperimentsView(viewModel: PreviousExperimentsViewModel.mock)
    }
}
