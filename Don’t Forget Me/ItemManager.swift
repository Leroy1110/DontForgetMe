import Foundation

class ItemManager: ObservableObject {
    @Published var categories: [Category] = [] {
        didSet {
            saveData() // Persist any mutation automatically.
        }
    }

    let key = "saved_categories"

    init() {
        loadData()
    }
    
    // Adds a new empty category
    func addCategory(named name: String) {
        categories.append(Category(name: name))
    }
    
    // Adds an item inside the given category
    func addItem(to category: Category, named itemName: String) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].items.append(Item(name: itemName, isChecked: false))
        }
    }
    
    // Removes items from given category at offsets (for swipe‑to‑delete)
    func removeItem(from category: Category, at offsets: IndexSet) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].items.remove(atOffsets: offsets)
        }
    }

    func saveData() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        }
    }
}

