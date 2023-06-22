//
//  NavigationModel.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/16.
//

import SwiftUI
import Combine

enum Category: Int, Hashable, CaseIterable, Identifiable, Codable {
    case dessert
    case pancake
    case salad
    case sandwich

    var id: Int { rawValue }

    var localizedName: LocalizedStringKey {
        switch self {
        case .dessert:
            return "Dessert"
        case .pancake:
            return "Pancake"
        case .salad:
            return "Salad"
        case .sandwich:
            return "Sandwich"
        }
    }
}

struct Ingredient: Hashable, Identifiable {
    let id = UUID()
    var description: String
}

struct Recipe: Hashable, Identifiable {
    let id = UUID()
    var name: String
    var category: Category
    var ingredients: [Ingredient]
    var related: [Recipe.ID] = []
    var imageName: String? = nil
}

enum ExperimentProcess: Hashable, Codable {
    case setupConfigurations
    case instruction(String)
    case familiarisation
    case stimulus
}



final class NavigationModel: ObservableObject, Codable {
    @Published var selectedCategory: Category?
    @Published var columnVisibility: NavigationSplitViewVisibility
    @Published var processPath: [ExperimentProcess]
    
    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()

    init(columnVisibility: NavigationSplitViewVisibility = .automatic,
         selectedCategory: Category? = nil,
         processPath: [ExperimentProcess] = []
    ) {
        self.columnVisibility = columnVisibility
        self.selectedCategory = selectedCategory
        self.processPath = processPath
    }

    var jsonData: Data? {
        get { try? encoder.encode(self) }
        set {
            guard let data = newValue,
                  let model = try? decoder.decode(Self.self, from: data)
            else { return }
            selectedCategory = model.selectedCategory
            columnVisibility = model.columnVisibility
        }
    }

    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedCategory = try container.decodeIfPresent(
            Category.self, forKey: .selectedCategory)
        self.columnVisibility = try container.decode(
            NavigationSplitViewVisibility.self, forKey: .columnVisibility)
        self.processPath = try container.decode([ExperimentProcess].self, forKey: .processPath)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedCategory, forKey: .selectedCategory)
        try container.encode(columnVisibility, forKey: .columnVisibility)
    }

    enum CodingKeys: String, CodingKey {
        case selectedCategory
        case recipePathIds
        case columnVisibility
        case processPath
    }
}
