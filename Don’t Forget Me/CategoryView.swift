import SwiftUI

struct CategoryView: View {
    var category: Category
    @ObservedObject var manager: ItemManager
    @State private var newItem = ""
    @State private var showAlert = false
    @State private var uncheckedItems: [String] = []
    
    // Reminder picker state
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
                // Per‑category reminder button
                Button(action: {
                    showCategoryTimePicker.toggle()
                }) {
                    Label("Change Category Reminder Time", systemImage: "clock")
                }
                
                .padding()
                
                // Per‑category reminder picker
                if showCategoryTimePicker {
                    DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
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
                                    body: "Check that you marked all your items in -\(manager.categories[index].name)",
                                    identifier: manager.categories[index].id.uuidString
                                )
                            }
                        }
                }
                
                // Add new item
                HStack {
                    TextField("Add New Item", text: $newItem)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        if !newItem.isEmpty {
                            manager.addItem(to: category, named: newItem)
                            newItem = ""
                        }
                    }
                }
                .padding()
                
                // Leave‑home check button
                Button(action: {
                    if let index = manager.categories.firstIndex(where: { $0.id == category.id }) {
                        let items = manager.categories[index].items
                        uncheckedItems = items.filter { !$0.isChecked }.map { $0.name }
                        showAlert = !uncheckedItems.isEmpty
                    }
                }) {
                    Text("I Left the House!")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Forgot Something!"),
                        message: Text("You didn't mark:\n" + uncheckedItems.joined(separator: "\n")),
                        dismissButton: .default(Text("OK"))
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

