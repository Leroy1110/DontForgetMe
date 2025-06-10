import Foundation

/// Item represents a single checklist entry inside a category.
struct Item: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isChecked: Bool
}
