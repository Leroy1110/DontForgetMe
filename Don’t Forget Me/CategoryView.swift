import SwiftUI

struct CategoryView: View {
    var category: Category
    @ObservedObject var manager: ItemManager
    @State private var newItem = ""
    @State private var showAlert = false
    @State private var uncheckedItems: [String] = []
    @State private var selectedTime: Date = Date()
    @State private var showCategoryTimePicker = false

    var body: some View {
        VStack {
            List {
                if let index = manager.categories.firstIndex(where: { $0.id == category.id }) {
                    ForEach($manager.categories[index].items) { $item in
                        Toggle(isOn: $item.isChecked) {
                            Text(item.name)
                        }
                    }
                    .onDelete { offsets in
                        manager.removeItem(from: category, at: offsets)
                    }
                }
                Button(action: {
                    showCategoryTimePicker.toggle()
                }) {
                    Label("שנה שעת תזכורת לקטגוריה", systemImage: "clock")
                }
                
                .padding()

                if showCategoryTimePicker {
                    DatePicker("בחר שעה", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: selectedTime) { newValue in
                            if let index = manager.categories.firstIndex(where: { $0.id == category.id }) {
                                let calendar = Calendar.current
                                manager.categories[index].notificationHour = calendar.component(.hour, from: newValue)
                                manager.categories[index].notificationMinute = calendar.component(.minute, from: newValue)

                                NotificationManager.instance.scheduleDailyNotification(
                                    at: manager.categories[index].notificationHour,
                                    minute: manager.categories[index].notificationMinute,
                                    title: "Don't Forget \(manager.categories[index].name)!",
                                    body: "בדוק אם סימנת את כל הפריטים שלך ב-\(manager.categories[index].name)",
                                    identifier: manager.categories[index].id.uuidString
                                )
                            }
                        }
                }

                HStack {
                    TextField("הוסף פריט חדש", text: $newItem)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("הוסף") {
                        if !newItem.isEmpty {
                            manager.addItem(to: category, named: newItem)
                            newItem = ""
                        }
                    }
                }
                .padding()

                Button(action: {
                    if let index = manager.categories.firstIndex(where: { $0.id == category.id }) {
                        let items = manager.categories[index].items
                        uncheckedItems = items.filter { !$0.isChecked }.map { $0.name }
                        showAlert = !uncheckedItems.isEmpty
                    }
                }) {
                    Text("יצאתי מהבית!")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("שכחת משהו!"),
                        message: Text("לא סימנת את:\n" + uncheckedItems.joined(separator: "\n")),
                        dismissButton: .default(Text("בסדר"))
                    )
                }
            }
            .navigationTitle(category.name)
            .onAppear {
                if let index = manager.categories.firstIndex(where: { $0.id == category.id }) {
                    let hour = manager.categories[index].notificationHour
                    let minute = manager.categories[index].notificationMinute
                    selectedTime = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
                }
            }
        }
    }
}

