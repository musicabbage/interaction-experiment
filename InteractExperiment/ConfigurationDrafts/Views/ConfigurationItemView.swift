//
//  ConfigurationItemView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/8/27.
//

import SwiftUI

struct ConfigurationItemView: View {
    enum Action {
        case use, edit
    }
    
    @State private var phases: [[String: [UIImage]]]?
    
    private let dateFormatter: DateFormatter = .ReadableDateFormatter_ddMMYYYY_HHmm
    private let configuration: ConfigurationModel
    private var actionClosure: ((Action) -> Void) = { _ in }
    
    init(configuration: ConfigurationModel) {
        self.configuration = configuration
        let phases = configuration.phases.reduce(into: [[String: [UIImage]]](), { partialResult, phase in
            let images = phase.images.reduce(into: [UIImage]()) { images, fileName in
                do {
                    let imageData = try Data(contentsOf: configuration.folderURL.appendingPathComponent(fileName))
                    if let image = UIImage(data: imageData) {
                        images.append(image)
                    }
                } catch {
                    print("get phase image error: \(error)")
                }
            }
            partialResult.append([phase.name: images])
        })
        _phases = .init(initialValue: phases)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if configuration.isDraft {
                        Text("DRAFT")
                        .padding(.init(top: 2, leading: 4, bottom: 2, trailing: 4))
                        .font(.callout)
                        .background(Color.background.lightRed)
                        .foregroundColor(Color.button.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    if let date = configuration.date {
                        Text("\(dateFormatter.string(from: date))")
                            .font(.callout)
                    }
                }
                
                if let phases {
                    ForEach(0..<phases.count, id: \.self) { index in
                        PreviousExperimentImageListView(title: phases[index].first!.key, images: phases[index].first!.value)
                            .padding([.vertical], 2)
                    }
                }
            }
            .clipped()
            
            VStack(alignment: .trailing) {
                HStack {
                    Button("continue editing", action: {
                        actionClosure(.edit)
                    })
                    .actionButtonStyle()
                }
            }
            .frame(width: 220)
        }
        .padding(16)
        .background(Color.background.lightgray)
        .cornerRadius(15)
    }
}

extension ConfigurationItemView {
    func onTapAction(perform action: @escaping(Action) -> Void) -> Self {
        var copy = self
        copy.actionClosure = action
        return copy
    }
}

struct ConfigurationItemView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationItemView(configuration: .mock)
    }
}
