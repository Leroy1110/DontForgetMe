import Foundation

struct Category: Identifiable, Codable {
    var id = UUID()
    var name: String
    var items: [Item]
    var notificationHour: Int
    var notificationMinute: Int

    init(name: String, items: [Item] = [], notificationHour: Int = 7, notificationMinute: Int = 30) {
        self.name = name
        self.items = items
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
    }
}

